CREATE OR REPLACE FUNCTION management.create_purchase_order(
    p_supplier_id UUID,
    p_purchase_date DATE,  -- Changed to explicitly use DATE type
    p_reference VARCHAR DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_purchase_id UUID;
    v_supplier_name VARCHAR;
    v_is_pharma_manufacturer BOOLEAN;
BEGIN
    -- Get supplier info
    SELECT name, is_pharma_manufacturer
    INTO v_supplier_name, v_is_pharma_manufacturer
    FROM management.suppliers
    WHERE supplier_id = p_supplier_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Supplier with ID % not found', p_supplier_id;
    END IF;

    -- Generate reference if not provided
    IF p_reference IS NULL THEN
        p_reference := 'PO-' || TO_CHAR(p_purchase_date, 'YYYYMM') || '-' ||
                      LPAD(FLOOR(RANDOM() * 1000)::TEXT, 3, '0');
    END IF;

    -- Create purchase record
    INSERT INTO management.purchases (purchase_id, supplier_id, purchase_date, reference)
    VALUES (gen_random_uuid(), p_supplier_id, p_purchase_date, p_reference)
    RETURNING purchase_id INTO v_purchase_id;

    RETURN v_purchase_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_batch_number(
    manufacturer_prefix TEXT,
    product_code TEXT,
    batch_date DATE
) RETURNS TEXT AS $$
BEGIN
    RETURN UPPER(manufacturer_prefix) || '-' ||
           UPPER(product_code) || '-' ||
           TO_CHAR(batch_date, 'YYMM') || '-' ||
           LPAD(FLOOR(RANDOM() * 1000)::TEXT, 3, '0');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION management.add_purchase_items(
    p_purchase_id UUID,
    p_product_id UUID,
    p_quantity INTEGER,
    p_unit_price NUMERIC,
    p_expiration_date TIMESTAMP
) RETURNS VOID AS $$
DECLARE
    v_batch_number VARCHAR;
    v_product_name VARCHAR;
    v_supplier_prefix VARCHAR;
    v_purchase_date DATE;
BEGIN
    -- Validate purchase exists and get purchase date
    SELECT purchase_date INTO v_purchase_date
    FROM management.purchases
    WHERE purchase_id = p_purchase_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase with ID % not found', p_purchase_id;
    END IF;

    -- Get product name
    SELECT name INTO v_product_name
    FROM management.products
    WHERE product_id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with ID % not found', p_product_id;
    END IF;

    -- Get supplier prefix from purchase
    SELECT UPPER(LEFT(s.name, 3)) INTO v_supplier_prefix
    FROM management.purchases p
    JOIN management.suppliers s ON p.supplier_id = s.supplier_id
    WHERE p.purchase_id = p_purchase_id;

    -- Generate batch number
    v_batch_number := generate_batch_number(
        v_supplier_prefix,
        SUBSTRING(v_product_name FROM 1 FOR 3),
        v_purchase_date
    );

    -- Create purchase detail
    INSERT INTO management.purchase_details (
        purchase_id,
        product_id,
        quantity,
        unit_price,
        expiration_date,
        batch_number
    ) VALUES (
        p_purchase_id,
        p_product_id,
        p_quantity,
        p_unit_price,
        p_expiration_date::DATE, -- Explicitly cast to DATE
        v_batch_number
    );

    -- Create or update batch record
    INSERT INTO management.batches (
        batch_id,
        product_id,
        purchase_detail_id,
        batch_number,
        quantity_remaining
    ) VALUES (
        gen_random_uuid(),
        p_product_id,
        p_purchase_id,
        v_batch_number,
        p_quantity
    )
    ON CONFLICT (product_id, purchase_detail_id, batch_number) DO UPDATE
    SET quantity_remaining = management.batches.quantity_remaining + EXCLUDED.quantity_remaining;

    RAISE NOTICE 'Added purchase item: Product %, Batch %, Quantity %',
                 v_product_name, v_batch_number, p_quantity;
END;
$$ LANGUAGE plpgsql;
