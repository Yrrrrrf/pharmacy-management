-- Update the batch quantities calculation function
-- Update the batch quantities calculation function
CREATE OR REPLACE FUNCTION management.update_batch_quantities(
    p_product_id UUID,
    p_batch_number VARCHAR DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
    v_batch RECORD;
    v_purchased INTEGER;
    v_sold INTEGER;
BEGIN
    -- Loop through each batch of the product
    FOR v_batch IN (
        SELECT
            b.batch_id,
            b.batch_number,
            pd.quantity as purchased_quantity,
            p.purchase_date  -- Get purchase date from purchases table
        FROM management.batches b
        JOIN management.purchase_details pd ON
            pd.product_id = b.product_id AND
            pd.batch_number = b.batch_number
        JOIN management.purchases p ON  -- Join with purchases to get the date
            p.purchase_id = pd.purchase_id
        WHERE b.product_id = p_product_id
        AND (p_batch_number IS NULL OR b.batch_number = p_batch_number)
        ORDER BY p.purchase_date ASC -- FIFO order
    ) LOOP
        -- Get total sold quantity for this batch
        SELECT COALESCE(SUM(si.quantity), 0) INTO v_sold
        FROM management.sale_items si
        WHERE si.batch_id = v_batch.batch_id;

        -- Update remaining quantity (removed updated_at timestamp)
        UPDATE management.batches
        SET quantity_remaining = v_batch.purchased_quantity - v_sold
        WHERE batch_id = v_batch.batch_id;

        RAISE NOTICE 'Updated batch % quantity (purchased on %): Purchased %, Sold %, Remaining %',
            v_batch.batch_number,
            v_batch.purchase_date,
            v_batch.purchased_quantity,
            v_sold,
            (v_batch.purchased_quantity - v_sold);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION management.reconcile_all_batch_quantities()
RETURNS TABLE (
    product_id UUID,
    product_name VARCHAR,
    batches_updated INTEGER,
    total_purchased INTEGER,
    total_sold INTEGER,
    current_stock INTEGER
) AS $$
DECLARE
    v_rec RECORD;
    v_batches_updated INTEGER;
    v_total_purchased INTEGER;
    v_total_sold INTEGER;
BEGIN
    -- Loop through products with batches
    FOR v_rec IN (
        SELECT DISTINCT
            p.product_id,
            p.name as product_name
        FROM management.products p
        JOIN management.batches b ON b.product_id = p.product_id
    ) LOOP
        -- Get number of batches for this product
        SELECT COUNT(*) INTO v_batches_updated
        FROM management.batches b
        WHERE b.product_id = v_rec.product_id;

        -- Get total purchased quantity
        SELECT COALESCE(SUM(pd.quantity), 0) INTO v_total_purchased
        FROM management.purchase_details pd
        WHERE pd.product_id = v_rec.product_id;

        -- Get total sold quantity
        SELECT COALESCE(SUM(si.quantity), 0) INTO v_total_sold
        FROM management.sale_items si
        WHERE si.product_id = v_rec.product_id;

        -- Update batch quantities
        PERFORM management.update_batch_quantities(v_rec.product_id);

        -- Return summary row
        RETURN QUERY
        SELECT
            v_rec.product_id,
            v_rec.product_name,
            v_batches_updated,
            v_total_purchased,
            v_total_sold,
            (v_total_purchased - v_total_sold);
    END LOOP;

    -- If no products found, raise notice
    IF NOT FOUND THEN
        RAISE NOTICE 'No products with batches found';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function for purchase_details
CREATE OR REPLACE FUNCTION management.trg_purchase_details_update_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- For new purchases, update the batch quantities
        PERFORM management.update_batch_quantities(NEW.product_id, NEW.batch_number);
    ELSIF TG_OP = 'UPDATE' THEN
        -- For updates, recalculate both old and new batch if they're different
        PERFORM management.update_batch_quantities(OLD.product_id, OLD.batch_number);
        IF NEW.batch_number <> OLD.batch_number OR NEW.product_id <> OLD.product_id THEN
            PERFORM management.update_batch_quantities(NEW.product_id, NEW.batch_number);
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        -- For deletions, update the old batch
        PERFORM management.update_batch_quantities(OLD.product_id, OLD.batch_number);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function for sale_items
CREATE OR REPLACE FUNCTION management.trg_sale_items_update_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_batch_number VARCHAR;
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Get batch number for new sale item
        SELECT batch_number INTO v_batch_number
        FROM management.batches
        WHERE batch_id = NEW.batch_id;

        -- Update quantities for the affected batch
        PERFORM management.update_batch_quantities(NEW.product_id, v_batch_number);
    END IF;

    IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND OLD.batch_id <> NEW.batch_id) THEN
        -- Get batch number for old sale item
        SELECT batch_number INTO v_batch_number
        FROM management.batches
        WHERE batch_id = OLD.batch_id;

        -- Update quantities for the old batch
        PERFORM management.update_batch_quantities(OLD.product_id, v_batch_number);
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for purchase_details
DROP TRIGGER IF EXISTS trg_purchase_details_stock ON management.purchase_details;
CREATE TRIGGER trg_purchase_details_stock
    AFTER INSERT OR UPDATE OR DELETE ON management.purchase_details
    FOR EACH ROW EXECUTE FUNCTION management.trg_purchase_details_update_stock();

-- Create triggers for sale_items
DROP TRIGGER IF EXISTS trg_sale_items_stock ON management.sale_items;
CREATE TRIGGER trg_sale_items_stock
    AFTER INSERT OR UPDATE OR DELETE ON management.sale_items
    FOR EACH ROW EXECUTE FUNCTION management.trg_sale_items_update_stock();


-- Reconcile all batches
SELECT management.reconcile_all_batch_quantities();