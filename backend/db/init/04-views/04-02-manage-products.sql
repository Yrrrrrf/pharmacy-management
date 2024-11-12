-- Create a view to see products with their full category path
CREATE OR REPLACE VIEW management.v_product_categories AS
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    p.description,
    p.unit_price,
    ch.path as category_path
FROM
    management.products p
    LEFT JOIN management.v_category_hierarchy ch ON p.category_id = ch.category_id;

-- Create a view for product inventory status
CREATE OR REPLACE VIEW management.v_product_inventory AS
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    p.unit_price,
    COALESCE(SUM(b.quantity_remaining), 0) as total_stock,
    COUNT(DISTINCT b.batch_number) as batch_count,
    MIN(b.expiration_date) as nearest_expiration,
    MAX(b.expiration_date) as furthest_expiration
FROM
    management.products p
    LEFT JOIN management.batches b ON p.product_id = b.product_id
GROUP BY
    p.product_id, p.sku, p.name, p.unit_price;
