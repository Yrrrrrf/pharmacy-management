-- Helper function to check if product requires prescription
CREATE OR REPLACE FUNCTION management.requires_prescription(p_product_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_commercialization pharma.commercialization;
BEGIN
    SELECT d.commercialization INTO v_commercialization
    FROM management.products p
    JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
    JOIN pharma.drug d ON ph.drug_id = d.id
    WHERE p.product_id = p_product_id;

    RETURN v_commercialization >= 'III';
EXCEPTION WHEN OTHERS THEN
    -- If not a pharmaceutical product, assume no prescription needed
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function to create a sale
CREATE OR REPLACE FUNCTION management.create_sale(
    p_sale_date TIMESTAMP WITH TIME ZONE,
    p_payment_method VARCHAR DEFAULT 'Efectivo'
) RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
BEGIN
    INSERT INTO management.sales (
        sale_id,
        sale_date,
        total_amount,
        payment_method
    ) VALUES (
        gen_random_uuid(),
        p_sale_date,
        0, -- Will be updated when items are added
        p_payment_method
    ) RETURNING sale_id INTO v_sale_id;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;





-- Function to create a prescription for a sale
CREATE OR REPLACE FUNCTION management.create_prescription(
    p_sale_id UUID,
    p_prescriber_name VARCHAR,
    p_patient_name VARCHAR,
    p_prescription_date DATE DEFAULT CURRENT_DATE
) RETURNS UUID AS $$
DECLARE
    v_prescription_id UUID;
BEGIN
    INSERT INTO management.prescriptions (
        prescription_id,
        sale_id,
        prescriber_name,
        prescription_date,
        patient_name
    ) VALUES (
        gen_random_uuid(),
        p_sale_id,
        p_prescriber_name,
        p_prescription_date,
        p_patient_name
    ) RETURNING prescription_id INTO v_prescription_id;

    RETURN v_prescription_id;
END;
$$ LANGUAGE plpgsql;


-- Fixed add_sale_item function
CREATE OR REPLACE FUNCTION management.add_sale_item(
    p_sale_id UUID,
    p_product_id UUID,
    p_quantity INTEGER,
    p_unit_price NUMERIC(10,2) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_batch_id UUID;
    v_remaining INTEGER;
    v_to_take INTEGER;
    v_actual_unit_price NUMERIC(10,2);
    v_requires_prescription BOOLEAN;
    v_already_has_prescription BOOLEAN;
    v_last_sale_item_id UUID;
BEGIN
    -- Get the actual unit price if not provided
    SELECT COALESCE(p_unit_price, unit_price) INTO v_actual_unit_price
    FROM management.products
    WHERE product_id = p_product_id;

    -- Check if product requires prescription
    v_requires_prescription := management.requires_prescription(p_product_id);

    IF v_requires_prescription THEN
        -- Check if sale already has a prescription
        SELECT EXISTS (
            SELECT 1 FROM management.prescriptions
            WHERE sale_id = p_sale_id
        ) INTO v_already_has_prescription;

        IF NOT v_already_has_prescription THEN
            RAISE EXCEPTION 'Product requires prescription but none is attached to sale';
        END IF;
    END IF;

    v_remaining := p_quantity;

    -- Find available batches ordered by expiration date (FEFO - First Expired, First Out)
    FOR v_batch_id, v_to_take IN
        SELECT
            batch_id,
            LEAST(quantity_remaining, v_remaining) as to_take
        FROM management.batches
        WHERE product_id = p_product_id
            AND quantity_remaining > 0
            AND expiration_date > CURRENT_DATE
        ORDER BY expiration_date ASC
    LOOP
        -- Generate new sale_item_id for each batch entry
        v_last_sale_item_id := gen_random_uuid();

        -- Insert sale item
        INSERT INTO management.sale_items (
            sale_item_id,
            sale_id,
            product_id,
            batch_id,
            quantity,
            unit_price,
            total_price
        ) VALUES (
            v_last_sale_item_id,
            p_sale_id,
            p_product_id,
            v_batch_id,
            v_to_take,
            v_actual_unit_price,
            (v_to_take * v_actual_unit_price)::NUMERIC(10,2)
        );

        -- Update batch quantity
        UPDATE management.batches
        SET quantity_remaining = quantity_remaining - v_to_take
        WHERE batch_id = v_batch_id;

        RAISE NOTICE 'Added % units from batch % for product %',
                    v_to_take, v_batch_id, p_product_id;

        v_remaining := v_remaining - v_to_take;

        EXIT WHEN v_remaining <= 0;
    END LOOP;

    IF v_remaining > 0 THEN
        RAISE EXCEPTION 'Insufficient stock for product %', p_product_id;
    END IF;

    -- Update sale total
    UPDATE management.sales
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0)
        FROM management.sale_items
        WHERE sale_id = p_sale_id
    )
    WHERE sale_id = p_sale_id;

    RETURN v_last_sale_item_id;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    v_sale_id UUID;
    v_base_date TIMESTAMP WITH TIME ZONE;
    v_sale_date TIMESTAMP WITH TIME ZONE;
    v_payment_methods VARCHAR[] := ARRAY['Efectivo', 'Tarjeta', 'Transferencia'];
    v_doctors VARCHAR[] := ARRAY[
        'Dr. Juan Pérez',
        'Dra. María García',
        'Dr. Roberto López',
        'Dra. Ana Martínez',
        'Dr. Carlos Ruiz'
    ];
    v_patients VARCHAR[] := ARRAY[
        'Pedro Sánchez',
        'Laura Torres',
        'Miguel Ángel Ramírez',
        'Carmen Ortiz',
        'José Luis Hernández'
    ];
    v_product_record RECORD;
    v_needs_prescription BOOLEAN;
    v_calculated_price NUMERIC(10,2);
    v_sales_count INTEGER := 0;
    v_items_count INTEGER := 0;
BEGIN
    -- Start from 3 months ago
    v_base_date := CURRENT_TIMESTAMP - INTERVAL '3 months';

    -- Create sales for each day
    FOR i IN 0..90 LOOP -- 3 months of sales
        RAISE NOTICE 'Processing day % of 90', i;

        -- Create 3-8 sales per day
        FOR j IN 1..FLOOR(RANDOM() * 6 + 3)::INT LOOP
            -- Generate sale time (between 9 AM and 8 PM)
            v_sale_date := v_base_date + i * INTERVAL '1 day' +
                          (9 * 60 + FLOOR(RANDOM() * (11 * 60))::INT) * INTERVAL '1 minute';

            -- Create sale
            v_sale_id := management.create_sale(
                v_sale_date,
                v_payment_methods[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_payment_methods, 1))::INT]
            );

            v_sales_count := v_sales_count + 1;

            -- Add 1-5 products to the sale
            FOR v_product_record IN (
                SELECT DISTINCT ON (p.product_id) p.*, b.quantity_remaining
                FROM management.products p
                JOIN management.batches b ON p.product_id = b.product_id
                WHERE b.quantity_remaining > 0
                    AND b.expiration_date > CURRENT_DATE
                ORDER BY p.product_id, RANDOM()
                LIMIT FLOOR(RANDOM() * 5 + 1)::INT
            ) LOOP
                BEGIN
                    -- Check if product needs prescription
                    v_needs_prescription := management.requires_prescription(v_product_record.product_id);

                    -- Create prescription if needed
                    IF v_needs_prescription THEN
                        PERFORM management.create_prescription(
                            v_sale_id,
                            v_doctors[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_doctors, 1))::INT],
                            v_patients[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_patients, 1))::INT],
                            v_sale_date::DATE
                        );
                    END IF;

                    -- Calculate price with markup
                    v_calculated_price := (v_product_record.unit_price * (1 + (RANDOM() * 0.1)))::NUMERIC(10,2);

                    -- Add sale item
                    PERFORM management.add_sale_item(
                        v_sale_id,
                        v_product_record.product_id,
                        LEAST(
                            FLOOR(RANDOM() * 3 + 1)::INT,
                            v_product_record.quantity_remaining
                        ),
                        v_calculated_price
                    );

                    v_items_count := v_items_count + 1;

                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Error adding sale item: % (Product: %)', SQLERRM, v_product_record.product_id;
                END;
            END LOOP;

            -- Clean up empty sales
            DELETE FROM management.sales
            WHERE sale_id = v_sale_id
              AND NOT EXISTS (SELECT 1 FROM management.sale_items WHERE sale_id = v_sale_id);
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Simulation completed: Created % sales with % items', v_sales_count, v_items_count;

    -- Final statistics
    RAISE NOTICE 'Final statistics:';
    RAISE NOTICE 'Total sales amount: %', (SELECT SUM(total_amount) FROM management.sales);
    RAISE NOTICE 'Average sale amount: %', (SELECT AVG(total_amount) FROM management.sales);
    RAISE NOTICE 'Number of sales: %', (SELECT COUNT(*) FROM management.sales);
    RAISE NOTICE 'Number of sale items: %', (SELECT COUNT(*) FROM management.sale_items);
END;
$$;
