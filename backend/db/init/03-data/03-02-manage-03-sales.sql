-- Helper function to generate a random doctor name
CREATE OR REPLACE FUNCTION management.generate_doctor_name()
RETURNS TEXT AS $$
DECLARE
    v_first_names TEXT[] := ARRAY['Juan', 'Ana', 'Carlos', 'María', 'José', 'Laura', 'Ricardo', 'Patricia'];
    v_last_names TEXT[] := ARRAY['García', 'Rodríguez', 'Martínez', 'López', 'Pérez', 'González', 'Sánchez', 'Ramírez'];
BEGIN
    RETURN 'Dr. ' || v_first_names[1 + floor(random() * array_length(v_first_names, 1))] || ' ' ||
           v_last_names[1 + floor(random() * array_length(v_last_names, 1))];
END;
$$ LANGUAGE plpgsql;

-- Helper function to generate a random patient name
CREATE OR REPLACE FUNCTION management.generate_patient_name()
RETURNS TEXT AS $$
DECLARE
    v_first_names TEXT[] := ARRAY['Antonio', 'María', 'Juan', 'Isabel', 'Pedro', 'Carmen', 'Luis', 'Rosa',
                                 'Francisco', 'Teresa', 'Miguel', 'Elena', 'José', 'Ana', 'Manuel', 'Sofia'];
    v_last_names TEXT[] := ARRAY['García', 'Rodríguez', 'González', 'Fernández', 'López', 'Martínez',
                                'Sánchez', 'Pérez', 'Gómez', 'Martin', 'Jiménez', 'Ruiz'];
BEGIN
    RETURN v_first_names[1 + floor(random() * array_length(v_first_names, 1))] || ' ' ||
           v_last_names[1 + floor(random() * array_length(v_last_names, 1))];
END;
$$ LANGUAGE plpgsql;

-- Function to create a sale
CREATE OR REPLACE FUNCTION management.create_sale(
    p_sale_date TIMESTAMP,
    p_payment_method TEXT
) RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
BEGIN
    v_sale_id := gen_random_uuid();

    INSERT INTO management.sales (
        sale_id,
        sale_date,
        payment_method,
        total_amount
    ) VALUES (
        v_sale_id,
        p_sale_date,
        p_payment_method,
        0  -- Will be updated after adding items
    );

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- Function to add an item to a sale
CREATE OR REPLACE FUNCTION management.add_sale_item(
    p_sale_id UUID,
    p_product_id UUID,
    p_quantity INTEGER
) RETURNS UUID AS $$
DECLARE
    v_sale_item_id UUID;
    v_batch_id UUID;
    v_unit_price NUMERIC(10,2);
    v_total_price NUMERIC(10,2);
BEGIN
    -- Get unit price from products table
    SELECT unit_price INTO v_unit_price
    FROM management.products
    WHERE product_id = p_product_id;

    -- Find available batch
    SELECT batch_id INTO v_batch_id
    FROM management.batches
    WHERE product_id = p_product_id
    AND quantity_remaining >= p_quantity
    AND expiration_date > CURRENT_DATE
    ORDER BY expiration_date ASC
    LIMIT 1;

    IF v_batch_id IS NULL THEN
        RAISE EXCEPTION 'No available batch found for product %', p_product_id;
    END IF;

    -- Calculate total price
    v_total_price := v_unit_price * p_quantity;

    -- Create sale item
    v_sale_item_id := gen_random_uuid();
    INSERT INTO management.sale_items (
        sale_item_id,
        sale_id,
        product_id,
        batch_id,
        quantity,
        unit_price,
        total_price
    ) VALUES (
        v_sale_item_id,
        p_sale_id,
        p_product_id,
        v_batch_id,
        p_quantity,
        v_unit_price,
        v_total_price
    );

    -- Update batch quantity
    UPDATE management.batches
    SET quantity_remaining = quantity_remaining - p_quantity
    WHERE batch_id = v_batch_id;

    -- Update sale total
    UPDATE management.sales
    SET total_amount = total_amount + v_total_price
    WHERE sale_id = p_sale_id;

    RETURN v_sale_item_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create a prescription
CREATE OR REPLACE FUNCTION management.create_prescription(
    p_sale_id UUID,
    p_prescriber_name TEXT DEFAULT NULL,
    p_patient_name TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_prescription_id UUID;
BEGIN
    v_prescription_id := gen_random_uuid();

    INSERT INTO management.prescriptions (
        prescription_id,
        sale_id,
        prescriber_name,
        prescription_date,
        patient_name
    ) VALUES (
        v_prescription_id,
        p_sale_id,
        COALESCE(p_prescriber_name, management.generate_doctor_name()),
        CURRENT_DATE - (floor(random() * 5))::integer,
        COALESCE(p_patient_name, management.generate_patient_name())
    );

    RETURN v_prescription_id;
END;
$$ LANGUAGE plpgsql;

-- Function to create a complete sale with multiple items
CREATE OR REPLACE FUNCTION management.create_complete_sale(
    p_items JSON,
    p_needs_prescription BOOLEAN DEFAULT FALSE,
    p_sale_date TIMESTAMP DEFAULT NULL,
    p_payment_method TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
    v_item RECORD;
    v_payment_methods TEXT[] := ARRAY['Credit Card', 'Cash', 'Debit Card', 'Mobile Payment'];
    v_sale_date TIMESTAMP;
BEGIN
    -- Set sale date and payment method if not provided
    v_sale_date := COALESCE(
        p_sale_date,
        CURRENT_TIMESTAMP - (random() * interval '30 days')
    );

    -- Create the sale
    v_sale_id := management.create_sale(
        v_sale_date,
        COALESCE(
            p_payment_method,
            v_payment_methods[1 + floor(random() * array_length(v_payment_methods, 1))]
        )
    );

    -- Add items to the sale
    FOR v_item IN
        SELECT * FROM json_to_recordset(p_items)
        AS items(product_id UUID, quantity INTEGER)
    LOOP
        PERFORM management.add_sale_item(
            v_sale_id,
            v_item.product_id,
            v_item.quantity
        );
    END LOOP;

    -- Create prescription if needed
    IF p_needs_prescription THEN
        PERFORM management.create_prescription(v_sale_id);
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- Create sample sales data
DO $$
DECLARE
    v_sale_id UUID;
    v_current_date TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    -- Sale 1: Diabetes monitoring kit with prescription
    PERFORM management.create_complete_sale(
        '[
            {"product_id": "9110989b-7da4-4065-85ee-5d84751892aa", "quantity": 1},
            {"product_id": "ff2b770e-16dc-4ead-bd07-c93e2494b964", "quantity": 1},
            {"product_id": "f2f3812d-7c88-4100-98df-62238359c16d", "quantity": 2}
        ]'::JSON,
        TRUE,
        v_current_date - interval '2 days',
        'Credit Card'
    );

    -- Sale 2: Cardiovascular medications with prescription
    PERFORM management.create_complete_sale(
        '[
            {"product_id": "9325f2be-d7ac-4434-aae4-fd075eb2bdb4", "quantity": 1},
            {"product_id": "dca7ffed-a32e-4805-b1a7-91ebb99f44fd", "quantity": 1}
        ]'::JSON,
        TRUE,
        v_current_date - interval '3 days',
        'Cash'
    );

    -- Sale 3: Personal care items
    PERFORM management.create_complete_sale(
        '[
            {"product_id": "7c95fe91-4241-45d3-8bfd-9bfd21298027", "quantity": 2},
            {"product_id": "f1761bf2-808b-47ef-b917-07f53bf8bb4b", "quantity": 1}
        ]'::JSON,
        FALSE,
        v_current_date - interval '4 days',
        'Debit Card'
    );

    -- Continue with more sample sales...
    -- Add at least 17 more varied sales scenarios

    -- Example of batch creation for random sales:
    FOR i IN 1..17 LOOP
        PERFORM management.create_complete_sale(
            (
                SELECT json_agg(json_build_object(
                    'product_id', product_id,
                    'quantity', 1 + floor(random() * 3)
                ))
                FROM (
                    SELECT product_id
                    FROM management.products
                    WHERE random() < 0.3
                    LIMIT 1 + floor(random() * 3)
                ) p
            ),
            random() < 0.3,  -- 30% chance of prescription
            v_current_date - (random() * interval '30 days')
        );
    END LOOP;
END $$;
