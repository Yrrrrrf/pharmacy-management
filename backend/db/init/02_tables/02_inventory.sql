-- File: 02_inventory.sql
-- Defines the table structure for the inventory schema

CREATE SCHEMA IF NOT EXISTS inventory;

-- Product Categories
CREATE TABLE inventory.categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id UUID REFERENCES inventory.categories(category_id)
);

COMMENT ON COLUMN inventory.categories.category_id IS 'Unique identifier for the category';
COMMENT ON COLUMN inventory.categories.name IS 'Name of the category, must be unique';
COMMENT ON COLUMN inventory.categories.parent_category_id IS 'Reference to parent category, allowing for hierarchical structure';

-- Products
CREATE TABLE inventory.products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    category_id UUID REFERENCES inventory.categories(category_id),
    unit_price NUMERIC(10, 2) NOT NULL,
    image_url VARCHAR(255)  -- todo: add some image validation!
);

COMMENT ON COLUMN inventory.products.product_id IS 'Unique identifier for the product';
COMMENT ON COLUMN inventory.products.sku IS 'Stock Keeping Unit, unique identifier for inventory management';
COMMENT ON COLUMN inventory.products.name IS 'Name of the product';
COMMENT ON COLUMN inventory.products.description IS 'Brief description of the product';
COMMENT ON COLUMN inventory.products.category_id IS 'Reference to the product category';
COMMENT ON COLUMN inventory.products.unit_price IS 'Selling price per unit of the product';
COMMENT ON COLUMN inventory.products.image_url IS 'URL to the product image';

-- Suppliers
CREATE TABLE inventory.suppliers (
    supplier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT
);

COMMENT ON COLUMN inventory.suppliers.supplier_id IS 'Unique identifier for the supplier';
COMMENT ON COLUMN inventory.suppliers.name IS 'Name of the supplier company';
COMMENT ON COLUMN inventory.suppliers.contact_person IS 'Name of the primary contact person at the supplier';
COMMENT ON COLUMN inventory.suppliers.email IS 'Email address for the supplier';
COMMENT ON COLUMN inventory.suppliers.phone IS 'Phone number for the supplier';
COMMENT ON COLUMN inventory.suppliers.address IS 'Physical address of the supplier';

-- Purchases
CREATE TABLE inventory.purchases (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID REFERENCES inventory.suppliers(supplier_id),
    purchase_date DATE NOT NULL,
    reference VARCHAR(255)
);

COMMENT ON COLUMN inventory.purchases.purchase_id IS 'Unique identifier for the purchase';
COMMENT ON COLUMN inventory.purchases.supplier_id IS 'Reference to the supplier from whom the purchase was made';
COMMENT ON COLUMN inventory.purchases.purchase_date IS 'Date when the purchase was made';
COMMENT ON COLUMN inventory.purchases.reference IS 'Reference number or code for the purchase';

-- Purchase Details
CREATE TABLE inventory.purchase_details (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID REFERENCES inventory.purchases(purchase_id),
    product_id UUID REFERENCES inventory.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    expiration_date DATE,
    batch_number VARCHAR(50)
);

COMMENT ON COLUMN inventory.purchase_details.purchase_id IS 'Reference to the purchase this detail belongs to';
COMMENT ON COLUMN inventory.purchase_details.product_id IS 'Reference to the product purchased';
COMMENT ON COLUMN inventory.purchase_details.quantity IS 'Quantity of the product purchased';
COMMENT ON COLUMN inventory.purchase_details.unit_price IS 'Price per unit of the product at the time of purchase';
COMMENT ON COLUMN inventory.purchase_details.expiration_date IS 'Expiration date of the product batch';
COMMENT ON COLUMN inventory.purchase_details.batch_number IS 'Batch or lot number for traceability';


-- Indexes for better query performance
CREATE INDEX idx_products_category ON inventory.products(category_id);
CREATE INDEX idx_purchases_supplier ON inventory.purchases(supplier_id);
CREATE INDEX idx_purchase_details_purchase ON inventory.purchase_details(purchase_id);
CREATE INDEX idx_purchase_details_product ON inventory.purchase_details(product_id);



-- ** Views **
-- todo: Move this to it's own view file...

-- Create a view to calculate current stock levels
CREATE OR REPLACE VIEW inventory.stock_view AS
SELECT
    p.product_id,
    p.sku,
    p.name AS product_name,
    p.description,
    p.unit_price AS selling_price,
    c.category_id,
    c.name AS category_name,
    COALESCE(SUM(pd.quantity), 0) AS total_purchased,
    COALESCE(SUM(pd.quantity), 0) AS current_stock
FROM
    inventory.products p
LEFT JOIN
    inventory.categories c ON p.category_id = c.category_id
LEFT JOIN
    inventory.purchase_details pd ON p.product_id = pd.product_id
GROUP BY
    p.product_id, p.sku, p.name, p.description, p.unit_price,
    c.category_id, c.name;

-- Add comments to the view
COMMENT ON VIEW inventory.stock_view IS 'View that calculates current stock levels based on purchases';
COMMENT ON COLUMN inventory.stock_view.product_id IS 'Unique identifier for the product';
COMMENT ON COLUMN inventory.stock_view.sku IS 'Stock Keeping Unit, unique identifier for inventory management';
COMMENT ON COLUMN inventory.stock_view.product_name IS 'Name of the product';
COMMENT ON COLUMN inventory.stock_view.description IS 'Brief description of the product';
COMMENT ON COLUMN inventory.stock_view.selling_price IS 'Selling price per unit of the product';
COMMENT ON COLUMN inventory.stock_view.category_id IS 'Identifier for the product category';
COMMENT ON COLUMN inventory.stock_view.category_name IS 'Name of the product category';
COMMENT ON COLUMN inventory.stock_view.total_purchased IS 'Total quantity of the product purchased';
COMMENT ON COLUMN inventory.stock_view.current_stock IS 'Current stock level of the product (same as total_purchased without sales data)';

-- Create indexes to improve query performance on the view
CREATE INDEX IF NOT EXISTS idx_products_category ON inventory.products(category_id);
CREATE INDEX IF NOT EXISTS idx_purchase_details_product ON inventory.purchase_details(product_id);
