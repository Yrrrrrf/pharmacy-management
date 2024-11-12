-- Create views for purchase analysis
CREATE OR REPLACE VIEW management.v_purchase_summary AS
SELECT
    p.purchase_id,
    p.purchase_date,
    s.name as supplier_name,
    COUNT(pd.product_id) as total_products,
    SUM(pd.quantity) as total_units,
    SUM(pd.quantity * pd.unit_price) as total_amount,
    MIN(pd.expiration_date) as earliest_expiration,
    MAX(pd.expiration_date) as latest_expiration
FROM
    management.purchases p
    JOIN management.suppliers s ON p.supplier_id = s.supplier_id
    JOIN management.purchase_details pd ON p.purchase_id = pd.purchase_id
GROUP BY
    p.purchase_id, p.purchase_date, s.name;

-- View for inventory value
CREATE OR REPLACE VIEW management.v_inventory_value AS
SELECT
    p.category_id,
    c.name as category_name,
    COUNT(DISTINCT p.product_id) as unique_products,
    SUM(b.quantity_remaining) as total_units,
    SUM(b.quantity_remaining * p.unit_price) as total_value,
    MIN(b.expiration_date) as earliest_expiration,
    COUNT(DISTINCT CASE
        WHEN b.expiration_date <= CURRENT_DATE + INTERVAL '6 months'
        THEN b.batch_id
    END) as batches_expiring_soon
FROM
    management.products p
    JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN management.batches b ON p.product_id = b.product_id
WHERE
    b.quantity_remaining > 0
GROUP BY
    p.category_id, c.name;

-- View for batch tracking
CREATE OR REPLACE VIEW management.v_batch_tracking AS
SELECT
    b.batch_id,
    p.sku,
    p.name as product_name,
    b.batch_number,
    b.expiration_date,
    b.quantity_received,
    b.quantity_remaining,
    pd.unit_price as purchase_price,
    pur.purchase_date,
    s.name as supplier_name,
    CASE
        WHEN b.expiration_date <= CURRENT_DATE THEN 'Expired'
        WHEN b.expiration_date <= CURRENT_DATE + INTERVAL '6 months' THEN 'Expiring Soon'
        ELSE 'Valid'
    END as status
FROM
    management.batches b
    JOIN management.products p ON b.product_id = p.product_id
    JOIN management.purchase_details pd ON b.batch_number = pd.batch_number
    JOIN management.purchases pur ON pd.purchase_id = pur.purchase_id
    JOIN management.suppliers s ON pur.supplier_id = s.supplier_id
WHERE
    b.quantity_remaining > 0;