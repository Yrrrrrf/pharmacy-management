CREATE OR REPLACE VIEW pharma.v_pharma_details AS
WITH pharma_variants AS (
    -- Group variants by drug with simplified information
    SELECT
        ph.drug_id,
        -- Direct array of variants without wrapper
        jsonb_agg(
            jsonb_build_object(
                'id', ph.id,
                'form', f.name,
                'concentration', ph.concentration
            ) ORDER BY f.name, ph.concentration
        ) AS variants
    FROM
        pharma.pharmaceutical ph
        JOIN pharma.form f ON ph.form_id = f.id
    GROUP BY ph.drug_id
)
SELECT
    -- Drug base information
    d.id AS drug_id,
    d.name AS drug_name,
    d.type AS drug_type,
    d.nature AS drug_nature,
    d.commercialization,
    -- Prescription requirement
    CASE
        WHEN d.commercialization >= 'III' THEN true
        ELSE false
    END AS requires_prescription,
    -- Pathologies as array
    ARRAY(
        SELECT pat.name
        FROM pharma.drug_pathology dp
        JOIN pharma.pathology pat ON pat.id = dp.pathology_id
        WHERE dp.drug_id = d.id
        ORDER BY pat.name
    ) AS pathologies,
    -- Usage considerations common to all forms
    ARRAY(
        SELECT DISTINCT uc.name
        FROM pharma.form_usage_consideration fuc
        JOIN pharma.usage_consideration uc ON uc.id = fuc.consideration_id
        JOIN pharma.pharmaceutical ph ON ph.form_id = fuc.form_id
        WHERE ph.drug_id = d.id
        ORDER BY uc.name
    ) AS usage_considerations,
    -- Direct variants array without wrapper
    pv.variants AS variants
FROM
    pharma.drug d
    JOIN pharma_variants pv ON pv.drug_id = d.id;

COMMENT ON VIEW pharma.v_pharma_details IS
'Optimized view of pharmaceutical details with direct variant array structure';


CREATE OR REPLACE VIEW management.v_product_details AS
SELECT
    p.product_id,
    p.sku,
    p.name AS product_name,
    p.description,
    p.unit_price,
    p.category_id,
    p.pharma_product_id,
    COALESCE(SUM(b.quantity_remaining), 0) AS total_stock,
    MAX(pd.expiration_date) AS latest_expiration
FROM
    management.products p
    LEFT JOIN management.batches b ON p.product_id = b.product_id
    LEFT JOIN management.purchase_details pd ON
        b.product_id = pd.product_id AND
        b.purchase_detail_id = pd.purchase_id AND
        b.batch_number = pd.batch_number
GROUP BY
    p.product_id,
    p.sku,
    p.name,
    p.description,
    p.unit_price,
    p.category_id,
    p.pharma_product_id;

COMMENT ON VIEW management.v_product_details IS
'Provides a summary view of products including current stock levels and latest expiration dates.
Stock levels are calculated from batches and expiration dates are retrieved from purchase details.';

-- Add an index to improve view performance
CREATE INDEX IF NOT EXISTS idx_purchase_details_expiration ON management.purchase_details(product_id, expiration_date);
