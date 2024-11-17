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




CREATE OR REPLACE VIEW management.v_product_details
            (product_id, sku, product_name, description, unit_price, category_id, pharma_product_id, total_stock,
             latest_expiration)
as
SELECT p.product_id,
       p.sku,
       p.name                                         AS product_name,
       p.description,
       p.unit_price,
       p.category_id,
       p.pharma_product_id,
       COALESCE(sum(b.quantity_remaining), 0::bigint) AS total_stock,
       max(b.expiration_date)                         AS latest_expiration
FROM management.products p
         LEFT JOIN management.batches b ON p.product_id = b.product_id
GROUP BY p.product_id, p.sku, p.name, p.description, p.unit_price, p.category_id, p.pharma_product_id;

comment on view management.v_product_details is 'Base view for product information including stock levels and categorization';

alter table management.v_product_details
    owner to pharmacy_management_owner;

grant delete, insert, references, select, trigger, truncate, update on management.v_product_details to some_admin;

