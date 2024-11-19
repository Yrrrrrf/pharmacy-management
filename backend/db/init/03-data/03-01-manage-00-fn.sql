/**
 * Checks if there's enough stock available for a product
 * Returns available quantity or raises an exception if insufficient
 */
CREATE OR REPLACE FUNCTION management.check_product_stock(
    p_product_id UUID,
    p_quantity INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_product_name VARCHAR;
    v_purchased INTEGER;
    v_sold INTEGER;
    v_available INTEGER;
BEGIN
    -- Verify product exists and get name
    SELECT name INTO v_product_name
    FROM management.products
    WHERE product_id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with ID % not found', p_product_id;
    END IF;

    -- Calculate total purchased quantity
    SELECT COALESCE(SUM(pd.quantity), 0) INTO v_purchased
    FROM management.purchase_details pd
    WHERE pd.product_id = p_product_id;

    -- Calculate total sold quantity
    SELECT COALESCE(SUM(si.quantity), 0) INTO v_sold
    FROM management.sale_items si
    WHERE si.product_id = p_product_id;

    -- Calculate available stock
    v_available := v_purchased - v_sold;

    RAISE NOTICE 'Stock check for %: Purchased: %, Sold: %, Available: %',
        v_product_name, v_purchased, v_sold, v_available;

    IF v_available < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %: Required %, Available % (Total purchased: %, Total sold: %)',
            v_product_name, p_quantity, v_available, v_purchased, v_sold;
    END IF;

    -- Add a warning if stock is low (less than 20% of total purchased)
    IF v_purchased > 0 AND v_available <= (v_purchased * 0.2) THEN
        RAISE WARNING 'Low stock alert for %: Only % units remaining (%.2f%% of total purchased)',
            v_product_name, v_available, (v_available::float / v_purchased * 100);
    END IF;

    -- Add a warning if the product has never been purchased
    IF v_purchased = 0 THEN
        RAISE WARNING 'Product % has never been purchased', v_product_name;
    END IF;

    -- Add a warning if the product has never been sold
    IF v_sold = 0 THEN
        RAISE WARNING 'Product % has never been sold', v_product_name;
    END IF;

    RETURN v_available;

EXCEPTION
    WHEN OTHERS THEN
        -- Add context to the error
        RAISE EXCEPTION 'Error checking stock for product % (%): %',
            v_product_name, p_product_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;


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
