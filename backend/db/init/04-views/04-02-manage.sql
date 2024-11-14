-- Create v_products view with pharmaceutical details
CREATE OR REPLACE VIEW management.v_products AS
SELECT
    -- Base product information
    p.product_id,
    p.sku,
    p.name AS product_name,
    p.description AS product_description,
    p.unit_price,
    p.category_id,
    c.name AS category_name,
    p.pharma_product_id,

    -- Pharmaceutical information (if available)
    ph.concentration AS pharma_concentration,
    f.name AS pharma_form,
    f.code AS pharma_form_code,

    -- Drug information (if available)
    d.name AS drug_name,
    d.type AS drug_type,
    d.nature AS drug_nature,
    d.commercialization,

    -- Calculate if product requires prescription
    CASE
        WHEN d.commercialization >= 'III' THEN true
        ELSE false
    END AS requires_prescription,

    -- Stock information
    COALESCE(SUM(b.quantity_remaining), 0) AS total_stock,

    -- Additional category hierarchy information
    pc.name AS parent_category_name,

    -- Metadata
    CASE
        WHEN p.pharma_product_id IS NOT NULL THEN 'Pharmaceutical'
        ELSE 'Regular'
    END AS product_type

FROM
    management.products p
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN management.categories pc ON c.parent_category_id = pc.category_id
    LEFT JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
    LEFT JOIN pharma.form f ON ph.form_id = f.id
    LEFT JOIN pharma.drug d ON ph.drug_id = d.id
    LEFT JOIN management.batches b ON p.product_id = b.product_id
GROUP BY
    p.product_id,
    p.sku,
    p.name,
    p.description,
    p.unit_price,
    p.category_id,
    c.name,
    p.pharma_product_id,
    ph.concentration,
    f.name,
    f.code,
    d.name,
    d.type,
    d.nature,
    d.commercialization,
    pc.name;

-- Add helpful comments to the view
COMMENT ON VIEW management.v_products IS 'Comprehensive view of products including pharmaceutical details when available';

COMMENT ON COLUMN management.v_products.product_id IS 'Unique identifier for the product';
COMMENT ON COLUMN management.v_products.sku IS 'Stock Keeping Unit - unique product identifier';
COMMENT ON COLUMN management.v_products.product_name IS 'Name of the product';
COMMENT ON COLUMN management.v_products.product_description IS 'Description of the product';
COMMENT ON COLUMN management.v_products.unit_price IS 'Current selling price per unit';
COMMENT ON COLUMN management.v_products.category_name IS 'Name of the product category';
COMMENT ON COLUMN management.v_products.parent_category_name IS 'Name of the parent category';
COMMENT ON COLUMN management.v_products.pharma_concentration IS 'Concentration of the pharmaceutical product';
COMMENT ON COLUMN management.v_products.pharma_form IS 'Pharmaceutical form (e.g., tablet, capsule)';
COMMENT ON COLUMN management.v_products.pharma_form_code IS 'Code for the pharmaceutical form';
COMMENT ON COLUMN management.v_products.drug_name IS 'Name of the base drug';
COMMENT ON COLUMN management.v_products.drug_type IS 'Type of drug (Patent or Generic)';
COMMENT ON COLUMN management.v_products.drug_nature IS 'Nature of drug (Allopathic or Homeopathic)';
COMMENT ON COLUMN management.v_products.commercialization IS 'Commercialization category';
COMMENT ON COLUMN management.v_products.requires_prescription IS 'Whether the product requires a prescription';
COMMENT ON COLUMN management.v_products.total_stock IS 'Current total stock across all batches';
COMMENT ON COLUMN management.v_products.product_type IS 'Type of product (Pharmaceutical or Regular)';




-- Get all prescription medications with low stock
SELECT * FROM management.v_products
WHERE
--     requires_prescription = true
-- AND
    total_stock < 10
ORDER BY product_type
;

-- Get all products by category with stock levels
SELECT  category_name,
    COUNT(*) as product_count,
    SUM(total_stock) as total_stock,
    AVG(unit_price) as avg_price
FROM management.v_products
    GROUP BY category_name
    ORDER BY product_count DESC
;

-- Get pharmaceutical products by form
SELECT pharma_form,
    COUNT(*) as product_count,
    STRING_AGG(product_name, ', ') as products
FROM management.v_products
    WHERE product_type = 'Pharmaceutical'
    GROUP BY pharma_form
;
