


-- Create the fixed view with proper type casting
CREATE OR REPLACE VIEW management.v_category_hierarchy AS
WITH RECURSIVE category_tree AS (
    -- Base case: top-level categories
    SELECT
        c.category_id,
        c.name,
        c.parent_category_id,
        1 as level,
        c.name::text as path  -- Explicitly cast to text
    FROM management.categories c
    WHERE c.parent_category_id IS NULL

    UNION ALL

    -- Recursive case: categories with parents
    SELECT
        c.category_id,
        c.name,
        c.parent_category_id,
        ct.level + 1,
        (ct.path || ' > ' || c.name::text)::text  -- Ensure consistent text casting
    FROM management.categories c
    INNER JOIN category_tree ct ON c.parent_category_id = ct.category_id
)
SELECT
    category_id,
    name,
    parent_category_id,
    level,
    path
FROM category_tree
ORDER BY path;

-- Recreate the leaf categories view
DROP VIEW IF EXISTS management.v_leaf_categories;

CREATE OR REPLACE VIEW management.v_leaf_categories AS
SELECT c.*
FROM management.categories c
LEFT JOIN management.categories child ON child.parent_category_id = c.category_id
WHERE child.category_id IS NULL;

-- Recreate the category stats view
DROP VIEW IF EXISTS management.v_category_stats;

CREATE OR REPLACE VIEW management.v_category_stats AS
SELECT
    c.category_id,
    c.name,
    c.parent_category_id,
    COUNT(p.product_id) as product_count,
    COALESCE(SUM(CASE WHEN b.quantity_remaining > 0 THEN 1 ELSE 0 END), 0) as products_in_stock,
    COALESCE(SUM(b.quantity_remaining), 0) as total_items_in_stock
FROM management.categories c
LEFT JOIN management.products p ON p.category_id = c.category_id
LEFT JOIN management.batches b ON b.product_id = p.product_id
GROUP BY c.category_id, c.name, c.parent_category_id;
