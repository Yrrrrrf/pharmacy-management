/**
 * Generates random sales data for testing purposes
 * Returns the sale_id of the created sale
 */
CREATE OR REPLACE FUNCTION management.fn_rand_sale(p_sale_date TIMESTAMP)
RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
    v_requires_prescription BOOLEAN;
    v_product_cursor CURSOR FOR
        SELECT
            p.product_id,
            p.name,
            p.unit_price,
            management.product_requires_prescription(p.product_id) as needs_prescription,
            COALESCE(SUM(b.quantity_remaining), 0) as available_stock
        FROM management.products p
        LEFT JOIN management.batches b ON b.product_id = p.product_id
        GROUP BY p.product_id, p.name, p.unit_price
        HAVING COALESCE(SUM(b.quantity_remaining), 0) > 0
        ORDER BY RANDOM();
    v_product_record RECORD;
    v_payment_methods VARCHAR[] := ARRAY['CASH', 'CREDIT_CARD', 'DEBIT_CARD', 'TRANSFER'];
    v_doctor_names VARCHAR[] := ARRAY[
        'Dr. García', 'Dr. Rodríguez', 'Dra. López', 'Dr. Martínez',
        'Dra. Sánchez', 'Dr. González', 'Dra. Pérez', 'Dr. Ramírez'
    ];
    v_patient_names VARCHAR[] := ARRAY[
        'Juan Pérez', 'María García', 'Carlos López', 'Ana Martínez',
        'Roberto Sánchez', 'Laura Torres', 'José González', 'Carmen Ruiz'
    ];
    v_selected_payment VARCHAR;
    v_products_added INTEGER := 0;
    v_max_attempts INTEGER := 5;
    v_attempts INTEGER := 0;
BEGIN
    -- Verify provided timestamp
    IF p_sale_date IS NULL THEN
        RAISE EXCEPTION 'Sale date cannot be null';
    END IF;

    -- Select random payment method
    v_selected_payment := v_payment_methods[1 + floor(random() * array_length(v_payment_methods, 1))];

    -- Create the sale record WITH THE PROVIDED TIMESTAMP
    INSERT INTO management.sales (
        sale_id,
        sale_date,
        total_amount,
        payment_method
    ) VALUES (
        gen_random_uuid(),
        p_sale_date,  -- Use the provided timestamp
        0,
        v_selected_payment
    ) RETURNING sale_id INTO v_sale_id;

    -- Randomly decide if this will be a prescription sale (20% chance)
    IF random() < 0.2 THEN
        -- Create prescription with the same timestamp
        INSERT INTO management.prescriptions (
            prescription_id,
            sale_id,
            prescriber_name,
            prescription_date,
            patient_name
        ) VALUES (
            gen_random_uuid(),
            v_sale_id,
            v_doctor_names[1 + floor(random() * array_length(v_doctor_names, 1))],
            p_sale_date::date,  -- Use the provided date
            v_patient_names[1 + floor(random() * array_length(v_patient_names, 1))]
        );
        v_requires_prescription := true;
    ELSE
        v_requires_prescription := false;
    END IF;

    -- Add products to the sale
    OPEN v_product_cursor;
    WHILE v_products_added < FLOOR(RANDOM() * 3 + 1)::INT AND v_attempts < v_max_attempts LOOP
        FETCH v_product_cursor INTO v_product_record;

        IF NOT FOUND THEN
            EXIT;
        END IF;

        -- Skip if product requires prescription but sale doesn't have one
        IF v_product_record.needs_prescription AND NOT v_requires_prescription THEN
            v_attempts := v_attempts + 1;
            CONTINUE;
        END IF;

        BEGIN
            DECLARE
                v_rand_quantity INTEGER;
            BEGIN
                -- Calculate random quantity
                IF v_product_record.needs_prescription THEN
                    v_rand_quantity := 1 + floor(random())::INTEGER;
                ELSE
                    v_rand_quantity := 1 + floor(random() * 4)::INTEGER;
                END IF;

                -- Ensure we don't exceed available stock
                v_rand_quantity := LEAST(v_rand_quantity, v_product_record.available_stock);

                IF v_rand_quantity > 0 THEN
                    PERFORM management.add_sale_item(
                        v_sale_id,
                        v_product_record.product_id,
                        v_rand_quantity
                    );
                    v_products_added := v_products_added + 1;
                END IF;
            END;
        EXCEPTION
            WHEN OTHERS THEN
                v_attempts := v_attempts + 1;
        END;
    END LOOP;
    CLOSE v_product_cursor;

    -- If no products were added, delete the sale
    IF v_products_added = 0 THEN
        DELETE FROM management.sales WHERE sale_id = v_sale_id;
        RETURN NULL;
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;


-- * remove all existing sales data before generating new data...
DELETE FROM management.prescriptions CASCADE;
DELETE FROM management.sale_items CASCADE;
DELETE FROM management.sales CASCADE;


-- Generate sample sales data for the last 6 months
DO $$
DECLARE
    -- Date declarations
    v_start_date DATE := CURRENT_DATE - INTERVAL '6 months';
    v_end_date DATE := CURRENT_DATE - INTERVAL '1 day';
    v_current_date DATE;
    v_sales_for_day INTEGER;
    v_hour INTEGER;
    v_sale_time TIMESTAMP;
    v_new_sale_id UUID;
    -- Business parameters
    v_min_sales_per_day CONSTANT INTEGER := 2;
    v_max_sales_per_day CONSTANT INTEGER := 4;
    v_business_hour_start CONSTANT INTEGER := 9;
    v_business_hour_end CONSTANT INTEGER := 20;
    v_weekend_multiplier NUMERIC;
    -- For verification
    r RECORD;
BEGIN
    -- Start from the first day
    v_current_date := v_start_date;

    WHILE v_current_date < v_end_date LOOP
        -- Adjust for weekends
        v_weekend_multiplier := CASE
            WHEN EXTRACT(DOW FROM v_current_date) IN (0, 6) THEN 1.5
            ELSE 1.0
        END;

        v_sales_for_day := FLOOR(
            (v_min_sales_per_day + floor(random() * (v_max_sales_per_day - v_min_sales_per_day + 1))::INTEGER)
            * v_weekend_multiplier
        )::INTEGER;

        RAISE NOTICE 'Creating % sales for %', v_sales_for_day, v_current_date;

        FOR i IN 1..v_sales_for_day LOOP
            BEGIN
                -- Generate hour with weighted distribution
                IF random() < 0.7 THEN
                    -- Peak hours (11-14 or 16-19)
                    v_hour := CASE
                        WHEN random() < 0.5 THEN
                            11 + floor(random() * 3)::INTEGER  -- Morning peak
                        ELSE
                            16 + floor(random() * 3)::INTEGER  -- Afternoon peak
                    END;
                ELSE
                    -- Regular hours
                    v_hour := v_business_hour_start +
                             floor(random() * (v_business_hour_end - v_business_hour_start))::INTEGER;
                END IF;

                -- Create timestamp for this specific sale
                v_sale_time := v_current_date +
                              make_interval(hours => v_hour) +
                              make_interval(mins => floor(random() * 60)::int) +
                              make_interval(secs => floor(random() * 60)::int);

                -- Verify the sale_time is within bounds
                IF v_sale_time >= (v_end_date + INTERVAL '1 day') THEN
                    RAISE NOTICE 'Skipping sale creation for time % as it exceeds end date', v_sale_time;
                    CONTINUE;
                END IF;

                -- Create the sale
                v_new_sale_id := management.fn_rand_sale(v_sale_time);

                -- Small delay to prevent timestamp collisions
                PERFORM pg_sleep(0.01);

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'Error creating sale for date % at hour %: %',
                        v_current_date, v_hour, SQLERRM;
                    CONTINUE;
            END;
        END LOOP;

        -- Move to next day
        v_current_date := v_current_date + 1;

        -- Verify we haven't exceeded the end date
        IF v_current_date > v_end_date THEN
            RAISE NOTICE 'Reached end date: %', v_end_date;
            EXIT;
        END IF;
    END LOOP;

    -- Final verification query
    RAISE NOTICE 'Sales distribution by week:';
    FOR r IN (
        SELECT
            DATE_TRUNC('week', sale_date)::date as week,
            COUNT(*) as count,
            SUM(total_amount) as total
        FROM management.sales
        WHERE sale_date >= v_start_date AND sale_date <= v_end_date
        GROUP BY DATE_TRUNC('week', sale_date)
        ORDER BY week
    ) LOOP
        RAISE NOTICE 'Week: %, Count: %, Total: %', r.week, r.count, r.total;
    END LOOP;
END;
$$;