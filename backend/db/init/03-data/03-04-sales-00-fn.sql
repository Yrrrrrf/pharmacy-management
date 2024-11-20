/**
 * Creates a new sale record with optional prescription
 * Returns the sale_id
 */
CREATE OR REPLACE FUNCTION management.create_sale(
    p_payment_method VARCHAR,
    p_prescriber_name VARCHAR DEFAULT NULL,
    p_prescription_date DATE DEFAULT NULL,
    p_patient_name VARCHAR DEFAULT NULL,
    p_sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
    v_prescription_id UUID;
BEGIN
    -- Create the sale record
    INSERT INTO management.sales (
        sale_id,
        sale_date,
        total_amount,
        payment_method
    ) VALUES (
        gen_random_uuid(),
        p_sale_date,
        0,  -- Initial total amount, will be updated as items are added
        p_payment_method
    ) RETURNING sale_id INTO v_sale_id;

    -- If prescription data is provided, create prescription record
    IF p_prescriber_name IS NOT NULL AND p_prescription_date IS NOT NULL AND p_patient_name IS NOT NULL THEN
        INSERT INTO management.prescriptions (
            prescription_id,
            sale_id,
            prescriber_name,
            prescription_date,
            patient_name
        ) VALUES (
            gen_random_uuid(),
            v_sale_id,
            p_prescriber_name,
            p_prescription_date,
            p_patient_name
        )
        RETURNING prescription_id INTO v_prescription_id;

        RAISE NOTICE 'Created prescription % for sale %', v_prescription_id, v_sale_id;
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

/**
 * Adds an item to a sale, handling stock management and prescription validation
 * Returns the sale_item_id
 */
CREATE OR REPLACE FUNCTION management.add_sale_item(
    p_sale_id UUID,
    p_product_id UUID,
    p_quantity INTEGER
) RETURNS UUID AS $$
DECLARE
    v_sale_item_id UUID;
    v_product_price NUMERIC(10,2);
    v_total_price NUMERIC(10,2);
    v_requires_prescription BOOLEAN;
    v_has_prescription BOOLEAN;
    v_batch_record RECORD;
    v_remaining_quantity INTEGER;
BEGIN
    -- Validate sale exists
    IF NOT EXISTS (SELECT 1 FROM management.sales WHERE sale_id = p_sale_id) THEN
        RAISE EXCEPTION 'Sale with ID % not found', p_sale_id;
    END IF;

    -- Check if product requires prescription
    v_requires_prescription := management.product_requires_prescription(p_product_id);

    -- Check if sale has associated prescription
    IF v_requires_prescription THEN
        SELECT EXISTS (
            SELECT 1 FROM management.prescriptions
            WHERE sale_id = p_sale_id
        ) INTO v_has_prescription;

        IF NOT v_has_prescription THEN
            RAISE EXCEPTION 'Product requires prescription but no prescription is associated with sale %', p_sale_id;
        END IF;
    END IF;

    -- Check stock availability
    PERFORM management.check_product_stock(p_product_id, p_quantity);

    -- Get product price
    SELECT unit_price INTO v_product_price
    FROM management.products
    WHERE product_id = p_product_id;

    v_total_price := v_product_price * p_quantity;
    v_remaining_quantity := p_quantity;

    -- Create sale item
    INSERT INTO management.sale_items (
        sale_item_id,
        sale_id,
        product_id,
        quantity,
        unit_price,
        total_price
    ) VALUES (
        gen_random_uuid(),
        p_sale_id,
        p_product_id,
        p_quantity,
        v_product_price,
        v_total_price
    ) RETURNING sale_item_id INTO v_sale_item_id;

    -- Update batches using FIFO method
    FOR v_batch_record IN (
        SELECT batch_id, quantity_remaining
        FROM management.batches
        WHERE product_id = p_product_id
          AND quantity_remaining > 0
        ORDER BY purchase_detail_id ASC -- FIFO order
    ) LOOP
        DECLARE
            v_quantity_to_take INTEGER;
        BEGIN
            v_quantity_to_take := LEAST(v_remaining_quantity, v_batch_record.quantity_remaining);

            -- Update batch quantity
            UPDATE management.batches
            SET quantity_remaining = quantity_remaining - v_quantity_to_take
            WHERE batch_id = v_batch_record.batch_id;

            -- Update sale item with batch reference
            UPDATE management.sale_items
            SET batch_id = v_batch_record.batch_id
            WHERE sale_item_id = v_sale_item_id;

            v_remaining_quantity := v_remaining_quantity - v_quantity_to_take;

            EXIT WHEN v_remaining_quantity <= 0;
        END;
    END LOOP;

    -- Update sale total
    UPDATE management.sales
    SET total_amount = total_amount + v_total_price
    WHERE sale_id = p_sale_id;

    RETURN v_sale_item_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in add_sale_item: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;
