INSERT INTO management.suppliers
(supplier_id, name, contact_person, email, phone, address, is_pharma_manufacturer)
VALUES
    -- Major Pharmaceutical Manufacturers
    (gen_random_uuid(), 'PharmaGen Laboratories', 'Dr. Carlos Ruiz', 'cruiz@pharmagen.com', '+52-555-123-4567', 'Av. Industria Farmacéutica 100, CDMX', true),
    (gen_random_uuid(), 'MediLab Industries', 'Dra. Ana Martínez', 'amartinez@medilab.com', '+52-555-234-5678', 'Blvd. Salud 200, Monterrey', true),
    (gen_random_uuid(), 'BioSyntex México', 'Dr. Ricardo Vega', 'rvega@biosyntex.com', '+52-555-345-6789', 'Calle Innovación 300, Guadalajara', true),

    -- Generic Medication Manufacturers
    (gen_random_uuid(), 'Genéricos Nacionales', 'Lic. María González', 'mgonzalez@gennac.com', '+52-555-456-7890', 'Av. Medicina 400, Puebla', true),
    (gen_random_uuid(), 'Farmacéutica del Norte', 'Ing. Roberto Sánchez', 'rsanchez@fnorte.com', '+52-555-567-8901', 'Carretera Industrial 500, Tijuana', true),

    -- Distributors
    (gen_random_uuid(), 'Distribuidora Médica Central', 'Lic. Patricia Luna', 'pluna@dimec.com', '+52-555-678-9012', 'Calle Distribuición 600, CDMX', false),
    (gen_random_uuid(), 'Grupo Farmacéutico Nacional', 'Ing. Jorge Torres', 'jtorres@gfn.com', '+52-555-789-0123', 'Av. Comercio 700, Mérida', false),

    -- Specialty Medication Suppliers
    (gen_random_uuid(), 'BioTech Specialties', 'Dr. Fernando Rojas', 'frojas@biotech.com', '+52-555-890-1234', 'Paseo Innovación 800, Querétaro', true),
    (gen_random_uuid(), 'Especialidades Farmacéuticas', 'Dra. Laura Campos', 'lcampos@espfarm.com', '+52-555-901-2345', 'Blvd. Tecnológico 900, León', true)
;


-- First, make sure we can handle dates properly in the generate_batch_number function
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

-- Fixed create_purchase_order function with proper date handling
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

-- Fixed add_purchase_items function
CREATE OR REPLACE FUNCTION management.add_purchase_items(
    p_purchase_id UUID,
    p_product_id UUID,
    p_quantity INTEGER,
    p_unit_price NUMERIC,
    p_expiration_date DATE DEFAULT NULL
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
        COALESCE(p_expiration_date, v_purchase_date + INTERVAL '2 years'),
        v_batch_number
    );

    -- Create or update batch record
    INSERT INTO management.batches (
        batch_id,
        product_id,
        batch_number,
        expiration_date,
        quantity_received,
        quantity_remaining
    ) VALUES (
        gen_random_uuid(),
        p_product_id,
        v_batch_number,
        COALESCE(p_expiration_date, v_purchase_date + INTERVAL '2 years'),
        p_quantity,
        p_quantity
    )
    ON CONFLICT (product_id, batch_number) DO UPDATE
    SET quantity_received = management.batches.quantity_received + EXCLUDED.quantity_received,
        quantity_remaining = management.batches.quantity_remaining + EXCLUDED.quantity_received;

    RAISE NOTICE 'Added purchase item: Product %, Batch %, Quantity %',
                 v_product_name, v_batch_number, p_quantity;
END;
$$ LANGUAGE plpgsql;

-- Now let's create the sample purchase data with better error handling
-- Modify the sample data creation with explicit date handling
DO $$
DECLARE
    v_supplier_id UUID;
    v_purchase_id UUID;
    v_product_cursor CURSOR FOR
        SELECT product_id, unit_price
        FROM management.products
        ORDER BY RANDOM();
    v_product_record RECORD;
    v_base_date DATE := CURRENT_DATE - INTERVAL '6 months';
    v_purchase_date DATE;
BEGIN
    -- For each supplier
    FOR v_supplier_id IN SELECT supplier_id FROM management.suppliers
    LOOP
        RAISE NOTICE 'Processing supplier: %', v_supplier_id;

        -- Create multiple purchases over the last 3 months
        FOR i IN 1..3 LOOP
            v_purchase_date := (v_base_date + (i * INTERVAL '1 month'))::DATE;

            -- Create purchase order
            v_purchase_id := management.create_purchase_order(
                v_supplier_id,
                v_purchase_date
            );

            RAISE NOTICE 'Created purchase order: % for date: %', v_purchase_id, v_purchase_date;

            -- Add random products to the purchase
            OPEN v_product_cursor;
            FOR j IN 1..FLOOR(RANDOM() * 4 + 2)::INT LOOP
                FETCH v_product_cursor INTO v_product_record;
                EXIT WHEN NOT FOUND;

                -- Add items with some price variation
                BEGIN
                    PERFORM management.add_purchase_items(
                        v_purchase_id,
                        v_product_record.product_id,
                        FLOOR(RANDOM() * 50 + 10)::INT,
                        ROUND((v_product_record.unit_price * (0.7 + RANDOM() * 0.1))::numeric, 2),
                        (v_purchase_date + INTERVAL '2 years')::DATE
                    );
                EXCEPTION WHEN OTHERS THEN
                    RAISE NOTICE 'Error adding purchase item: % (Product ID: %)', SQLERRM, v_product_record.product_id;
                END;
            END LOOP;
            CLOSE v_product_cursor;
        END LOOP;
    END LOOP;
END;
$$;
