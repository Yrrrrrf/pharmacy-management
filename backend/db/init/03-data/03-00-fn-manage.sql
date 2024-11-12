-- Function to help create categories with parent relationships
CREATE OR REPLACE FUNCTION management.create_category(
    p_name VARCHAR,
    p_parent_name VARCHAR DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_category_id UUID;
    v_parent_id UUID;
BEGIN
    IF p_parent_name IS NOT NULL THEN
        SELECT category_id INTO v_parent_id
        FROM management.categories
        WHERE name = p_parent_name;
    END IF;

    INSERT INTO management.categories (category_id, name, parent_category_id)
    VALUES (gen_random_uuid(), p_name, v_parent_id)
    RETURNING category_id INTO v_category_id;

    RETURN v_category_id;
END;
$$ LANGUAGE plpgsql;

-- Create a function to generate realistic batch numbers
CREATE OR REPLACE FUNCTION generate_batch_number(
    manufacturer_prefix TEXT,
    product_code TEXT,
    batch_date DATE
) RETURNS TEXT AS $$
BEGIN
    RETURN manufacturer_prefix || '-' ||
           product_code || '-' ||
           TO_CHAR(batch_date, 'YYMM') || '-' ||
           LPAD(FLOOR(RANDOM() * 1000)::TEXT, 3, '0');
END;
$$ LANGUAGE plpgsql;
