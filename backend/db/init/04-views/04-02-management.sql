-- Base Products View
-- Provides a comprehensive view of all products with additional pharmaceutical information when available
CREATE OR REPLACE VIEW management.v_base_products AS
SELECT
    p.product_id,
    p.sku,
    p.name AS product_name,
    p.description,
    p.unit_price,
    c.name AS category_name,
    -- Pharmaceutical information
    ph.id AS pharma_id,
    d.id AS drug_id,
    p.created_at,
    p.updated_at
FROM
    management.products p
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
    LEFT JOIN pharma.drug d ON ph.drug_id = d.id;

COMMENT ON VIEW management.v_base_products IS
'Comprehensive view of all products including pharmaceutical details when available.
Useful for inventory management and product listings.';

-- Inventory Status View
CREATE OR REPLACE VIEW management.v_inventory_status AS
WITH stock_movements AS (
    -- Calculate recent sales velocity (last 30 days)
    SELECT
        si.product_id,
        COALESCE(SUM(si.quantity), 0) as quantity_sold,
        COALESCE(ROUND(SUM(si.quantity)::numeric / 30, 2), 0) as daily_sales_rate
    FROM management.sale_items si
    JOIN management.sales s ON si.sale_id = s.sale_id
    WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY si.product_id
)
SELECT
    p.product_id,
    p.sku,
    p.name AS product_name,
    c.name AS category_name,
    -- Stock Information
    COALESCE(SUM(b.quantity_remaining), 0) as total_stock,
    COUNT(DISTINCT b.batch_id) as active_batches,
    -- Batch Details
    jsonb_agg(
        jsonb_build_object(
            'batch_number', b.batch_number,
            'quantity', b.quantity_remaining,
            'expiration_date', b.expiration_date,
            'days_until_expiry',
            CASE
                WHEN b.expiration_date IS NOT NULL
                THEN (b.expiration_date - CURRENT_DATE)
                ELSE NULL
            END
        ) ORDER BY b.expiration_date ASC
    ) FILTER (WHERE b.batch_id IS NOT NULL) as batch_details,
    -- Sales Velocity
    COALESCE(sm.quantity_sold, 0) as units_sold_30_days,
    ROUND(COALESCE(sm.daily_sales_rate, 0)::numeric, 2) as daily_sales_rate,
    -- Stock Duration Estimate
    CASE
        WHEN COALESCE(sm.daily_sales_rate, 0) > 0
        THEN ROUND((SUM(b.quantity_remaining) / NULLIF(sm.daily_sales_rate, 0))::numeric, 0)
        ELSE NULL
    END as estimated_days_until_stockout,
    -- Additional Pharma Information
    ph.concentration as pharma_concentration,
    d.name as drug_name,
    f.name as form_name
FROM management.products p
LEFT JOIN management.categories c ON p.category_id = c.category_id
LEFT JOIN management.batches b ON p.product_id = b.product_id
LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
-- Pharmaceutical information
LEFT JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
LEFT JOIN pharma.drug d ON ph.drug_id = d.id
LEFT JOIN pharma.form f ON ph.form_id = f.id
GROUP BY
    p.product_id, p.sku, p.name, c.name, sm.quantity_sold, sm.daily_sales_rate,
    ph.concentration, d.name, f.name;
