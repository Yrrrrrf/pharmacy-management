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


-- ? This fn is just for testing purposes, it's not a real-world scenario...
CREATE OR REPLACE FUNCTION management.fn_rand_purchase(p_purchase_date DATE)
RETURNS UUID AS $$
DECLARE
    v_supplier_id UUID;
    v_purchase_id UUID;
    v_product_cursor CURSOR FOR
        SELECT product_id, unit_price
        FROM management.products
        ORDER BY RANDOM();
    v_product_record RECORD;
BEGIN
    -- Select a random supplier
    SELECT supplier_id INTO v_supplier_id
    FROM management.suppliers
    ORDER BY RANDOM()
    LIMIT 1;

    IF v_supplier_id IS NULL THEN
        RAISE EXCEPTION 'No suppliers found in the database';
    END IF;

    -- Create the purchase order
    INSERT INTO management.purchases (supplier_id, purchase_date, reference)
    VALUES (v_supplier_id, p_purchase_date, CONCAT('PO-', gen_random_uuid()))
    RETURNING purchase_id INTO v_purchase_id;

    RAISE NOTICE 'Created purchase order: % for supplier: % on date: %', v_purchase_id, v_supplier_id, p_purchase_date;

    -- Add random products to the purchase order
    OPEN v_product_cursor;
    FOR i IN 1..FLOOR(RANDOM() * 5 + 2)::INT LOOP -- Random number of products (2 to 6)
        FETCH v_product_cursor INTO v_product_record;
        EXIT WHEN NOT FOUND;

        BEGIN
            -- Add purchase items with random quantity and price variation
            PERFORM management.add_purchase_items(
                v_purchase_id,
                v_product_record.product_id,
                FLOOR(RANDOM() * 40 + 10)::INT, -- Quantity: 10 to 60
                ROUND((v_product_record.unit_price * (0.7 + RANDOM() * 0.3))::NUMERIC, 2), -- Price: 70%-100% of original
                p_purchase_date + INTERVAL '2 years' -- Expiration date
            );
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error adding product to purchase: % (Product ID: %)', SQLERRM, v_product_record.product_id;
        END;
    END LOOP;
    CLOSE v_product_cursor;

    RETURN v_purchase_id;
END;
$$ LANGUAGE plpgsql;


-- Create random purchases for the last 6 months...
DO $$
DECLARE
    v_start_date DATE := CURRENT_DATE - INTERVAL '6 months';
    v_end_date DATE := CURRENT_DATE;
    v_purchase_date DATE := v_start_date;
    v_new_purchase_id UUID;
BEGIN
    WHILE v_purchase_date <= v_end_date LOOP
        -- Simulate a few purchases for random days in the range
            BEGIN
                v_new_purchase_id := management.fn_rand_purchase(v_purchase_date);
                RAISE NOTICE 'Created random purchase: % on date: %', v_new_purchase_id, v_purchase_date;
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Error creating purchase for date: % - %', v_purchase_date, SQLERRM;
            END;

        -- Increment the date
        v_purchase_date := v_purchase_date + INTERVAL '5 day';
    END LOOP;
END;
$$;
