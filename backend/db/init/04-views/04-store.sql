-- View for Purchase Orders History
CREATE OR REPLACE VIEW management.v_purchase_orders AS
WITH batch_summary AS (
    -- Summarize batch information for each purchase detail
    SELECT
        pd.purchase_id,
        pd.product_id,
        COUNT(b.batch_id) as total_batches,
        SUM(b.quantity_remaining) as total_remaining,
        MIN(b.batch_number) as earliest_batch,
        STRING_AGG(DISTINCT b.batch_number, ', ') as batch_numbers
    FROM management.purchase_details pd
    LEFT JOIN management.batches b ON
        b.product_id = pd.product_id AND
        b.purchase_detail_id = pd.purchase_id AND
        b.batch_number = pd.batch_number
    GROUP BY pd.purchase_id, pd.product_id
)
SELECT
    p.purchase_id,
    p.purchase_date,
    p.reference as purchase_reference,
    s.supplier_id,
    s.name as supplier_name,
    s.is_pharma_manufacturer,
    pd.product_id,
    pr.name as product_name,
    pr.sku,
    pd.batch_number,
    pd.quantity as purchased_quantity,
    pd.unit_price as purchase_unit_price,
    (pd.quantity * pd.unit_price)::NUMERIC(10,2) as purchase_total,
    bs.total_batches,
    bs.total_remaining,
    bs.earliest_batch,
    bs.batch_numbers,
    -- Useful calculated fields
    CASE
        WHEN bs.total_remaining > 0 THEN
            ROUND((bs.total_remaining::FLOAT / NULLIF(pd.quantity, 0) * 100)::NUMERIC, 2)
        ELSE 0
    END as stock_remaining_percentage,
    CASE
        WHEN pd.expiration_date < CURRENT_DATE THEN 'Expired'
        WHEN pd.expiration_date < CURRENT_DATE + INTERVAL '90 days' THEN 'Near Expiration'
        ELSE 'Valid'
    END as expiration_status
FROM
    management.purchases p
    INNER JOIN management.suppliers s ON p.supplier_id = s.supplier_id
    INNER JOIN management.purchase_details pd ON p.purchase_id = pd.purchase_id
    INNER JOIN management.products pr ON pd.product_id = pr.product_id
    LEFT JOIN batch_summary bs ON p.purchase_id = bs.purchase_id AND pd.product_id = bs.product_id
ORDER BY
    p.purchase_date DESC;

COMMENT ON VIEW management.v_purchase_orders IS
'Updated view of purchase history with batch tracking aligned to the new schema.';


CREATE OR REPLACE VIEW management.v_stock_history AS
WITH sale_summary AS (
    -- Summarize sale information for each product
    SELECT
        si.product_id,
        DATE_TRUNC('month', s.sale_date) as sale_month,
        COUNT(DISTINCT s.sale_id) as total_sales,
        SUM(si.quantity) as total_quantity_sold,
        SUM(si.total_price) as total_revenue,
        AVG(si.unit_price)::NUMERIC(10,2) as avg_unit_price,
        COUNT(DISTINCT b.batch_id) as batches_used,
        STRING_AGG(DISTINCT b.batch_number, ', ') as batch_numbers_used
    FROM
        management.sales s
        INNER JOIN management.sale_items si ON s.sale_id = si.sale_id
        LEFT JOIN management.batches b ON si.batch_id = b.batch_id
    GROUP BY
        si.product_id, DATE_TRUNC('month', s.sale_date)
)
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    p.unit_price as current_price,
    c.name as category_name,
    -- Current stock information
    COALESCE(SUM(b.quantity_remaining), 0) as current_stock,
    COUNT(DISTINCT b.batch_id) as active_batches,
    -- Sales history
    ss.sale_month,
    ss.total_sales,
    ss.total_quantity_sold,
    ss.total_revenue,
    ss.avg_unit_price,
    ss.batches_used,
    -- Calculated metrics
    ROUND((ss.total_revenue / NULLIF(ss.total_quantity_sold, 0))::NUMERIC, 2) as avg_sale_price,
    ROUND(((ss.avg_unit_price - p.unit_price) / NULLIF(p.unit_price, 0) * 100)::NUMERIC, 2) as price_variation_percentage,
    -- Product type
    CASE
        WHEN ph.id IS NOT NULL THEN 'Pharmaceutical'
        ELSE 'Regular'
    END as product_type,
    -- Prescription information
    COUNT(DISTINCT pr.prescription_id) as prescriptions_count,
    -- Stock status indicators
    CASE
        WHEN COALESCE(SUM(b.quantity_remaining), 0) = 0 THEN 'Out of Stock'
        WHEN COALESCE(SUM(b.quantity_remaining), 0) < ss.total_quantity_sold THEN 'Low Stock'
        ELSE 'In Stock'
    END as stock_status
FROM
    management.products p
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN management.batches b ON
        p.product_id = b.product_id AND
        b.quantity_remaining > 0
    LEFT JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
    LEFT JOIN sale_summary ss ON p.product_id = ss.product_id
    LEFT JOIN management.sale_items si ON p.product_id = si.product_id
    LEFT JOIN management.sales s ON si.sale_id = s.sale_id
    LEFT JOIN management.prescriptions pr ON s.sale_id = pr.sale_id
GROUP BY
    p.product_id,
    p.sku,
    p.name,
    p.unit_price,
    c.name,
    ph.id,
    ss.sale_month,
    ss.total_sales,
    ss.total_quantity_sold,
    ss.total_revenue,
    ss.avg_unit_price,
    ss.batches_used
ORDER BY
    p.name, ss.sale_month DESC;

COMMENT ON VIEW management.v_stock_history IS
'Updated view of product sales history and current stock levels aligned to the new schema.';


CREATE OR REPLACE VIEW management.v_purchase_batches_and_status AS
SELECT
    -- Purchase Information
    p.purchase_id,
    p.purchase_date,
    p.reference as purchase_reference,
    -- Product Information
    pr.product_id,
    pr.name as product_name,
    pr.sku,
    -- Supplier Information
    s.supplier_id,
    s.name as supplier_name,
    -- Purchase Details
    pd.quantity as ordered_quantity,
    pd.unit_price as purchase_unit_price,
    (pd.quantity * pd.unit_price)::NUMERIC(10,2) as total_cost,
    pd.batch_number,
    pd.expiration_date,
    -- Batch Information
    b.batch_id,
    b.quantity_remaining,
    -- Calculated Fields
    CASE
        WHEN pd.expiration_date < CURRENT_DATE THEN 'Expired'
        WHEN pd.expiration_date < CURRENT_DATE + INTERVAL '90 days' THEN 'Near Expiration'
        ELSE 'Valid'
    END as batch_status,
    -- Stock Status
    CASE
        WHEN b.quantity_remaining = 0 THEN 'Depleted'
        WHEN b.quantity_remaining < (pd.quantity * 0.1) THEN 'Critical Low'
        WHEN b.quantity_remaining < (pd.quantity * 0.2) THEN 'Low'
        ELSE 'Available'
    END as stock_status,
    -- Usage Percentage
    ROUND(((pd.quantity - COALESCE(b.quantity_remaining, 0))::DECIMAL / NULLIF(pd.quantity, 0) * 100), 2) as usage_percentage
FROM
    management.purchases p
    INNER JOIN management.purchase_details pd ON p.purchase_id = pd.purchase_id
    INNER JOIN management.products pr ON pd.product_id = pr.product_id
    INNER JOIN management.suppliers s ON p.supplier_id = s.supplier_id
    LEFT JOIN management.batches b ON
        pd.product_id = b.product_id AND
        pd.purchase_id = b.purchase_detail_id AND
        pd.batch_number = b.batch_number;

COMMENT ON VIEW management.v_purchase_batches_and_status IS 'Provides a comprehensive history of product purchases,
    batch tracking, and current stock levels. Links purchase details with their corresponding
    batches while tracking stock levels, expiration status, and usage statistics.';


-- View for Weekly Sales Summary
CREATE OR REPLACE VIEW management.v_weekly_sales AS
SELECT
    DATE_TRUNC('week', sale_date::date) AS week,
    SUM(total_amount) AS total_sales,
    COUNT(s.sale_id) AS total_sales_count,
    COUNT(p.prescription_id) AS prescription_sales_count
FROM management.sales s
LEFT JOIN management.prescriptions p ON s.sale_id = p.sale_id
GROUP BY DATE_TRUNC('week', sale_date::date)
ORDER BY week;

SELECT * FROM management.v_weekly_sales;
