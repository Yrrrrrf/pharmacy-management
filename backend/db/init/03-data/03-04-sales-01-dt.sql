/**
 * Generates random sales data for testing purposes
 * Returns the sale_id of the created sale
 */
CREATE OR REPLACE FUNCTION management.fn_rand_sale(p_sale_date TIMESTAMP)
RETURNS UUID AS $$
DECLARE
    v_sale_id UUID;
    v_requires_prescription BOOLEAN;
    -- Modified cursor to only select products with stock
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
        HAVING COALESCE(SUM(b.quantity_remaining), 0) > 0  -- Only products with stock
        ORDER BY RANDOM();
    v_product_record RECORD;
    -- Arrays for random data generation
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
    -- Verify that there are products with stock before proceeding
    PERFORM 1
    FROM management.products p
    JOIN management.batches b ON b.product_id = p.product_id
    WHERE b.quantity_remaining > 0
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No products available in stock';
    END IF;

    -- Select random payment method
    v_selected_payment := v_payment_methods[1 + floor(random() * array_length(v_payment_methods, 1))];

    -- Randomly decide if this will be a prescription sale (20% chance)
    IF random() < 0.2 THEN
        -- Create sale with prescription
        v_sale_id := management.create_sale(
            p_payment_method := v_selected_payment,
            p_prescriber_name := v_doctor_names[1 + floor(random() * array_length(v_doctor_names, 1))],
            p_prescription_date := p_sale_date::date,
            p_patient_name := v_patient_names[1 + floor(random() * array_length(v_patient_names, 1))]
        );
        v_requires_prescription := true;
    ELSE
        -- Create regular sale
        v_sale_id := management.create_sale(v_selected_payment);
        v_requires_prescription := false;
    END IF;

    RAISE NOTICE 'Created sale: % on date: % (Prescription: %)',
        v_sale_id, p_sale_date, v_requires_prescription;

    -- Add random products to the sale
    OPEN v_product_cursor;
    WHILE v_products_added < FLOOR(RANDOM() * 3 + 1)::INT AND v_attempts < v_max_attempts LOOP
        FETCH v_product_cursor INTO v_product_record;

        -- Exit if no more products available
        IF NOT FOUND THEN
            EXIT;
        END IF;

        -- Skip if product requires prescription but sale doesn't have one
        IF v_product_record.needs_prescription AND NOT v_requires_prescription THEN
            v_attempts := v_attempts + 1;
            CONTINUE;
        END IF;

        BEGIN
            -- Calculate random quantity (considering available stock)
            DECLARE
                v_rand_quantity INTEGER;
            BEGIN
                -- For prescription items, usually 1 or 2 units
                IF v_product_record.needs_prescription THEN
                    v_rand_quantity := 1 + floor(random())::INTEGER;
                ELSE
                    -- For non-prescription items, 1 to 5 units
                    v_rand_quantity := 1 + floor(random() * 4)::INTEGER;
                END IF;

                -- Ensure we don't exceed available stock
                v_rand_quantity := LEAST(v_rand_quantity, v_product_record.available_stock);

                IF v_rand_quantity > 0 THEN
                    -- Add sale item
                    PERFORM management.add_sale_item(
                        v_sale_id,
                        v_product_record.product_id,
                        v_rand_quantity
                    );

                    v_products_added := v_products_added + 1;

                    RAISE NOTICE 'Added item: % (Quantity: % out of % available) to sale %',
                        v_product_record.name,
                        v_rand_quantity,
                        v_product_record.available_stock,
                        v_sale_id;
                END IF;
            END;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Error adding product % to sale: %',
                    v_product_record.name, SQLERRM;
                v_attempts := v_attempts + 1;
        END;
    END LOOP;
    CLOSE v_product_cursor;

    -- Verify that at least one product was added
    IF v_products_added = 0 THEN
        -- If no products were added, roll back the sale
        DELETE FROM management.sales WHERE sale_id = v_sale_id;
        RAISE EXCEPTION 'Could not add any products to sale';
    END IF;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;


-- Generate sample sales data for the last 6 months
DO $$
DECLARE
    v_start_date TIMESTAMP := CURRENT_TIMESTAMP - INTERVAL '2 months';
    v_end_date TIMESTAMP := CURRENT_TIMESTAMP;
    v_current_date TIMESTAMP;  -- Current date being processed
    v_sales_for_day INTEGER;  -- Number of sales to generate for the day
    v_hour INTEGER;  -- Hour of the day for the sale
    v_sale_time TIMESTAMP;  -- Final sale timestamp
    v_new_sale_id UUID;  -- Sale ID generated by fn_rand_sale()
    -- Business parameters
    v_min_sales_per_day CONSTANT INTEGER := 3;  -- min sales per day
    v_max_sales_per_day CONSTANT INTEGER := 8;  -- max sales per day
    v_business_hour_start CONSTANT INTEGER := 9;  -- 9 AM
    v_business_hour_end CONSTANT INTEGER := 20;   -- 8 PM
    -- Weekend adjustment factors
    v_weekend_multiplier NUMERIC;
BEGIN
    v_current_date := v_start_date;

    WHILE v_current_date <= v_end_date LOOP
        -- Adjust number of sales based on weekend (more sales on weekends)
        v_weekend_multiplier := CASE
            WHEN EXTRACT(DOW FROM v_current_date) IN (0, 6) THEN 1.5 -- Weekend multiplier
            ELSE 1.0
        END;

        -- Calculate number of sales for this day
        v_sales_for_day := FLOOR(
            (v_min_sales_per_day + floor(random() * (v_max_sales_per_day - v_min_sales_per_day + 1))::INTEGER)
            * v_weekend_multiplier
        )::INTEGER;

        RAISE NOTICE 'Generating % sales for %', v_sales_for_day, v_current_date::date;

        -- Create sales for this day
        FOR i IN 1..v_sales_for_day LOOP
            BEGIN
                -- Generate random hour based on typical business patterns
                IF random() < 0.7 THEN
                    -- 70% of sales during peak hours (11:00-14:00 and 16:00-19:00)
                    v_hour := CASE
                        WHEN random() < 0.5 THEN
                            11 + floor(random() * 3)::INTEGER  -- Morning peak
                        ELSE
                            16 + floor(random() * 3)::INTEGER  -- Afternoon peak
                    END;
                ELSE
                    -- 30% of sales during other business hours
                    v_hour := v_business_hour_start + floor(random() *
                        (v_business_hour_end - v_business_hour_start))::INTEGER;
                END IF;

                -- Generate final sale timestamp
                v_sale_time := v_current_date +
                              (v_hour || ' hours')::INTERVAL +
                              (floor(random() * 60) || ' minutes')::INTERVAL +
                              (floor(random() * 60) || ' seconds')::INTERVAL;

                -- Create the sale
                v_new_sale_id := management.fn_rand_sale(v_sale_time);

                -- Log success with different detail levels based on sale characteristics
                IF EXISTS (
                    SELECT 1 FROM management.prescriptions
                    WHERE sale_id = v_new_sale_id
                ) THEN
                    RAISE NOTICE 'Created prescription sale: % at %', v_new_sale_id, v_sale_time;
                ELSE
                    RAISE NOTICE 'Created regular sale: % at %', v_new_sale_id, v_sale_time;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    RAISE WARNING 'Error creating sale at %: %', v_sale_time, SQLERRM;
                    -- Continue with next iteration despite error
                    CONTINUE;
            END;

            -- Add small delay between sales to prevent exact same timestamps
            PERFORM pg_sleep(0.01);
        END LOOP;

        v_current_date := v_current_date + INTERVAL '1 day';
    END LOOP;

    -- Final summary
    RAISE NOTICE 'Completed generating sales from % to %', v_start_date::date, v_end_date::date;
END;
$$;