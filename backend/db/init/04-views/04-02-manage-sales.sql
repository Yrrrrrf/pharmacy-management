
-- Create view for sales analysis
CREATE OR REPLACE VIEW management.v_sales_analysis AS
SELECT
    s.sale_id,
    s.sale_date,
    s.payment_method,
    COUNT(DISTINCT si.product_id) as items_count,
    SUM(si.quantity) as total_items,
    s.total_amount,
    COUNT(DISTINCT p.prescription_id) as prescription_count,
    STRING_AGG(DISTINCT c.name, ', ') as categories_sold
FROM
    management.sales s
    LEFT JOIN management.sale_items si ON s.sale_id = si.sale_id
    LEFT JOIN management.products pr ON si.product_id = pr.product_id
    LEFT JOIN management.categories c ON pr.category_id = c.category_id
    LEFT JOIN management.prescriptions p ON s.sale_id = p.sale_id
GROUP BY
    s.sale_id, s.sale_date, s.payment_method, s.total_amount
ORDER BY
    s.sale_date DESC;

-- Create view for product sales performance
CREATE OR REPLACE VIEW management.v_product_sales_performance AS
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    c.name as category,
    COUNT(DISTINCT s.sale_id) as number_of_sales,
    SUM(si.quantity) as total_units_sold,
    SUM(si.total_price) as total_revenue,
    AVG(si.unit_price) as average_sale_price,
    MIN(s.sale_date) as first_sale,
    MAX(s.sale_date) as last_sale,
    CASE
        WHEN p.pharma_product_id IS NOT NULL THEN 'Pharmaceutical'
        ELSE 'Non-Pharmaceutical'
    END as product_type
FROM
    management.products p
    LEFT JOIN management.sale_items si ON p.product_id = si.product_id
    LEFT JOIN management.sales s ON si.sale_id = s.sale_id
    LEFT JOIN management.categories c ON p.category_id = c.category_id
GROUP BY
    p.product_id, p.sku, p.name, c.name, p.pharma_product_id
ORDER BY
    total_revenue DESC NULLS LAST;



-- Create analysis views
-- Sales Analysis View
CREATE OR REPLACE VIEW management.v_sales_analysis AS
WITH sale_categories AS (
    SELECT
        s.sale_id,
        string_agg(DISTINCT c.name, ', ') as categories_sold,
        COUNT(DISTINCT CASE WHEN p.pharma_product_id IS NOT NULL THEN si.product_id END) as pharma_products,
        COUNT(DISTINCT CASE WHEN p.pharma_product_id IS NULL THEN si.product_id END) as non_pharma_products
    FROM management.sales s
    JOIN management.sale_items si ON s.sale_id = si.sale_id
    JOIN management.products p ON si.product_id = p.product_id
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    GROUP BY s.sale_id
)
SELECT
    s.sale_id,
    s.sale_date,
    s.payment_method,
    s.total_amount,
    COUNT(DISTINCT si.sale_item_id) as total_items,
    SUM(si.quantity) as total_units,
    sc.categories_sold,
    sc.pharma_products,
    sc.non_pharma_products,
    COUNT(DISTINCT p.prescription_id) as prescription_count
FROM
    management.sales s
    LEFT JOIN sale_categories sc ON s.sale_id = sc.sale_id
    LEFT JOIN management.sale_items si ON s.sale_id = si.sale_id
    LEFT JOIN management.prescriptions p ON s.sale_id = p.sale_id
GROUP BY
    s.sale_id, s.sale_date, s.payment_method, s.total_amount,
    sc.categories_sold, sc.pharma_products, sc.non_pharma_products;

-- Product Performance View
CREATE OR REPLACE VIEW management.v_product_performance AS
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    c.name as category_name,
    CASE WHEN p.pharma_product_id IS NOT NULL THEN 'Pharmaceutical' ELSE 'Non-Pharmaceutical' END as product_type,
    COUNT(DISTINCT si.sale_id) as total_sales,
    SUM(si.quantity) as units_sold,
    SUM(si.total_price) as total_revenue,
    AVG(si.unit_price) as avg_selling_price,
    MIN(s.sale_date) as first_sale_date,
    MAX(s.sale_date) as last_sale_date,
    COALESCE(SUM(b.quantity_remaining), 0) as current_stock
FROM
    management.products p
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN management.sale_items si ON p.product_id = si.product_id
    LEFT JOIN management.sales s ON si.sale_id = s.sale_id
    LEFT JOIN management.batches b ON p.product_id = b.product_id
GROUP BY
    p.product_id, p.sku, p.name, c.name, p.pharma_product_id;
