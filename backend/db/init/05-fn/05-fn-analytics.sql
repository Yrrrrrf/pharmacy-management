CREATE SCHEMA IF NOT EXISTS analytics;

-- Function to get total sales amount
CREATE OR REPLACE FUNCTION analytics.get_total_sales(
    p_since_date DATE DEFAULT NULL
) RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE((
        SELECT SUM(total_amount)
        FROM management.sales
        WHERE p_since_date IS NULL OR sale_date::DATE >= p_since_date
    ), 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get inventory items count
CREATE OR REPLACE FUNCTION analytics.get_inventory_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM management.products p
        WHERE EXISTS (
            SELECT 1
            FROM management.batches b
            WHERE b.product_id = p.product_id
            AND b.quantity_remaining > 0
        )
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get total number of sales transactions
CREATE OR REPLACE FUNCTION analytics.get_sales_count(
    p_since_date DATE DEFAULT NULL
) RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM management.sales
        WHERE p_since_date IS NULL OR sale_date::DATE >= p_since_date
    );
END;
$$ LANGUAGE plpgsql;

-- Function to get prescriptions count
CREATE OR REPLACE FUNCTION analytics.get_prescriptions_count(
    p_since_date DATE DEFAULT NULL
) RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM management.prescriptions p
        JOIN management.sales s ON s.sale_id = p.sale_id
        WHERE p_since_date IS NULL OR s.sale_date::DATE >= p_since_date
    );
END;
$$ LANGUAGE plpgsql;


-- crate a view that returns the same as the get_dashboard_metrics function
CREATE OR REPLACE VIEW analytics.v_dashboard_metrics AS
SELECT
    analytics.get_total_sales() AS total_sales,
    analytics.get_inventory_count() AS inventory_items,
    analytics.get_sales_count() AS sales_count,
    analytics.get_prescriptions_count() AS prescriptions_count
;

SELECT * FROM analytics.v_dashboard_metrics;


-- Enhanced view with total sales amount
CREATE OR REPLACE VIEW analytics.v_daily_sales_summary AS
SELECT
    DATE_TRUNC('day', sale_date) AS sale_day,
    COUNT(*) AS sales_count,
    SUM(total_amount) AS total_sales_amount
FROM management.sales
GROUP BY DATE_TRUNC('day', sale_date)
ORDER BY sale_day;

SELECT * FROM analytics.v_daily_sales_summary;
