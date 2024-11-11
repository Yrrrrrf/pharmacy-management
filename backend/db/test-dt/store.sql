-- Get basic product information
SELECT * FROM management.v_base_products;

-- Get pharmaceutical products for a specific pathology
SELECT * FROM management.v_pharmaceutical_products 
WHERE pathologies @> ARRAY['Hipertensión'];

-- Get all variations of a specific drug
SELECT * FROM management.v_drug_variations_summary 
WHERE drug_name = 'Ibuprofeno';

-- Get products that need restocking
SELECT p.product_name, i.current_stock, i.nearest_expiration, s.units_sold_last_30_days
FROM management.v_base_products p
JOIN management.v_inventory_status i ON i.product_id = p.product_id
JOIN management.v_product_statistics s ON s.product_id = p.product_id
WHERE i.stock_status IN ('Out of Stock', 'Low Stock');

-- Get comprehensive product information
SELECT 
    b.*,
    ph.drug_name,
    ph.pathologies,
    i.current_stock,
    i.stock_status,
    s.units_sold_last_30_days
FROM management.v_base_products b
LEFT JOIN management.v_pharmaceutical_products ph ON ph.product_id = b.product_id
LEFT JOIN management.v_inventory_status i ON i.product_id = b.product_id
LEFT JOIN management.v_product_statistics s ON s.product_id = b.product_id;
