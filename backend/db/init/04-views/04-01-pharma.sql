-- ====================
-- PHARMACEUTICAL VIEWS
-- ====================

-- Drug Variations View with Pricing
CREATE OR REPLACE VIEW pharma.v_drug_variations AS
WITH drug_concentrations AS (
    SELECT
        d.id AS drug_id,
        d.name AS drug_name,
        d.type,
        d.nature,
        d.commercialization,
        f.name AS form_name,
        ARRAY_AGG(p.concentration ORDER BY p.concentration) AS concentrations,
        -- Add price array that corresponds to concentrations
        ARRAY_AGG(
            COALESCE(mp.unit_price, NULL)::numeric
            ORDER BY p.concentration
        ) AS prices,
        ARRAY_AGG(DISTINCT ar.name) AS administration_routes,
        ARRAY_AGG(DISTINCT uc.name) AS usage_considerations
    FROM pharma.drug d
    JOIN pharma.pharmaceutical p ON d.id = p.drug_id
    JOIN pharma.form f ON p.form_id = f.id
    -- Join with management.products to get pricing
    LEFT JOIN management.products mp ON p.id = mp.pharma_product_id
    -- Get administration routes for this form
    LEFT JOIN pharma.form_administration_route far ON f.id = far.form_id
    LEFT JOIN pharma.administration_route ar ON far.route_id = ar.id
    -- Get usage considerations for this form
    LEFT JOIN pharma.form_usage_consideration fuc ON f.id = fuc.form_id
    LEFT JOIN pharma.usage_consideration uc ON fuc.consideration_id = uc.id
    GROUP BY
        d.id, d.name, d.type, d.nature, d.commercialization,
        f.name, f.description
)
SELECT
    drug_id,
    drug_name,
    type,
    nature,
    commercialization,
    form_name,
    concentrations,
    prices,  -- New column for prices
    administration_routes,
    usage_considerations,
    -- Add pathologies for this drug
    (SELECT ARRAY_AGG(DISTINCT p.name)
     FROM pharma.drug_pathology dp
     JOIN pharma.pathology p ON dp.pathology_id = p.id
     WHERE dp.drug_id = dc.drug_id) AS pathologies
    -- Add a JSON array combining concentrations and prices for easier consumption
FROM drug_concentrations dc
ORDER BY drug_name, form_name;

-- Update the view comment to reflect the new pricing information
COMMENT ON VIEW pharma.v_drug_variations IS
'Provides a comprehensive view of drug variations including:
- Basic drug information (name, type, nature, commercialization)
- Available forms and their descriptions
- Array of concentrations for each drug-form combination
- Array of prices corresponding to each concentration
- JSON array of concentration-price pairs for easier consumption
- Associated administration routes and usage considerations
- Related pathologies
Used for inventory management, prescription filling, and product listings.';


-- Generic Alternatives View
-- Shows generic alternatives for patent drugs
-- Useful for: Cost-effective prescribing and insurance purposes
CREATE OR REPLACE VIEW pharma.v_generic_alternatives AS
SELECT 
    d1.id AS patent_drug_id,
    d1.name AS patent_drug_name,
    d2.id AS generic_drug_id,
    d2.name AS generic_drug_name,
    p.name AS pathology,
    d2.commercialization
FROM pharma.drug d1
JOIN pharma.drug_pathology dp1 ON d1.id = dp1.drug_id
JOIN pharma.pathology p ON dp1.pathology_id = p.id
JOIN pharma.drug_pathology dp2 ON p.id = dp2.pathology_id
JOIN pharma.drug d2 ON dp2.drug_id = d2.id
WHERE d1.type = 'Patent' 
AND d2.type = 'Generic'
AND d1.id != d2.id;

COMMENT ON VIEW pharma.v_generic_alternatives IS 
'Identifies generic alternatives for patent drugs based on shared pathologies. 
Important for cost-effective prescribing and insurance requirements.';


-- Create a view for pharmaceutical products with pricing info
CREATE OR REPLACE VIEW management.v_pharma_products AS
SELECT
    p.product_id,
    p.sku,
    p.name as product_name,
    p.unit_price,
    ph.concentration,
    d.name as drug_name,
    d.type as drug_type,
    f.name as form_name,
    ch.path as category_path,
    COALESCE(SUM(b.quantity_remaining), 0) as stock_available
FROM 
    management.products p
    JOIN pharma.pharmaceutical ph ON p.pharma_product_id = ph.id
    JOIN pharma.drug d ON ph.drug_id = d.id
    JOIN pharma.form f ON ph.form_id = f.id
    LEFT JOIN management.categories c ON p.category_id = c.category_id
    LEFT JOIN management.v_category_hierarchy ch ON c.category_id = ch.category_id
    LEFT JOIN management.batches b ON p.product_id = b.product_id
GROUP BY 
    p.product_id, p.sku, p.name, p.unit_price, 
    ph.concentration, d.name, d.type, f.name, ch.path
;