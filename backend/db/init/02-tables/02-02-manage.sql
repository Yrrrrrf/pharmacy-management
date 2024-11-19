-- Product Categories
-- Represents product categories, may be used for non-pharmaceutical items
CREATE TABLE management.categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id UUID REFERENCES management.categories(category_id)
);

COMMENT ON COLUMN management.categories.category_id IS 'Unique identifier for the category';
COMMENT ON COLUMN management.categories.name IS 'Name of the category';
COMMENT ON COLUMN management.categories.parent_category_id IS 'Reference to parent category for hierarchical structure';

-- Products
-- Inventory products, linked to pharmaceutical products when applicable
CREATE TABLE management.products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pharma_product_id UUID REFERENCES pharma.pharmaceutical(id),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    unit_price NUMERIC(10, 2) NOT NULL,
    category_id UUID REFERENCES management.categories(category_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an index to improve performance on common queries
CREATE INDEX IF NOT EXISTS idx_products_stock_status
    ON management.products USING btree (category_id)
    WHERE category_id IS NOT NULL;

COMMENT ON COLUMN management.products.product_id IS 'Unique identifier for the product';
COMMENT ON COLUMN management.products.pharma_product_id IS 'Reference to the pharmaceutical product, if applicable';
COMMENT ON COLUMN management.products.sku IS 'Stock Keeping Unit, unique product identifier';
COMMENT ON COLUMN management.products.name IS 'Name of the product';
COMMENT ON COLUMN management.products.description IS 'Brief description of the product';
COMMENT ON COLUMN management.products.unit_price IS 'Price per unit of the product';
COMMENT ON COLUMN management.products.category_id IS 'Reference to the product category';

-- Suppliers
-- Suppliers of products, potentially including pharmaceutical manufacturers
CREATE TABLE management.suppliers (
    supplier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    is_pharma_manufacturer BOOLEAN DEFAULT FALSE
);

COMMENT ON COLUMN management.suppliers.supplier_id IS 'Unique identifier for the supplier';
COMMENT ON COLUMN management.suppliers.name IS 'Name of the supplier';
COMMENT ON COLUMN management.suppliers.contact_person IS 'Name of the primary contact person';
COMMENT ON COLUMN management.suppliers.email IS 'Email address of the supplier';
COMMENT ON COLUMN management.suppliers.phone IS 'Phone number of the supplier';
COMMENT ON COLUMN management.suppliers.address IS 'Physical address of the supplier';
COMMENT ON COLUMN management.suppliers.is_pharma_manufacturer IS 'Indicates if the supplier is a pharmaceutical manufacturer';

-- Purchases
-- Records of product purchases from suppliers
CREATE TABLE management.purchases (
    purchase_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID REFERENCES management.suppliers(supplier_id),
    purchase_date DATE NOT NULL,
    reference VARCHAR(255)
);

COMMENT ON COLUMN management.purchases.purchase_id IS 'Unique identifier for the purchase';
COMMENT ON COLUMN management.purchases.supplier_id IS 'Reference to the supplier';
COMMENT ON COLUMN management.purchases.purchase_date IS 'Date of the purchase';
COMMENT ON COLUMN management.purchases.reference IS 'Reference number or code for the purchase';


-- Purchase Details
-- Details of purchases, including batch information for traceability
CREATE TABLE management.purchase_details (
    purchase_id UUID REFERENCES management.purchases(purchase_id),
    product_id UUID REFERENCES management.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    expiration_date DATE,
    batch_number VARCHAR(50) NOT NULL,
    PRIMARY KEY (purchase_id, product_id, batch_number)
);

COMMENT ON COLUMN management.purchase_details.purchase_id IS 'Reference to the purchase';
COMMENT ON COLUMN management.purchase_details.product_id IS 'Reference to the product';
COMMENT ON COLUMN management.purchase_details.quantity IS 'Quantity of the product purchased';
COMMENT ON COLUMN management.purchase_details.unit_price IS 'Price per unit at the time of purchase';
COMMENT ON COLUMN management.purchase_details.expiration_date IS 'Expiration date of the product batch';
COMMENT ON COLUMN management.purchase_details.batch_number IS 'Batch or lot number for traceability';

-- Inventory Batches
-- Tracks individual batches of products for precise inventory management
CREATE TABLE management.batches (
    batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    purchase_detail_id UUID NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    quantity_remaining INTEGER NOT NULL,
    FOREIGN KEY (product_id, purchase_detail_id, batch_number)
        REFERENCES management.purchase_details(product_id, purchase_id, batch_number),
    UNIQUE (product_id, purchase_detail_id, batch_number)
);


COMMENT ON COLUMN management.batches.batch_id IS 'Unique identifier for the batch';
COMMENT ON COLUMN management.batches.product_id IS 'Reference to the product';
COMMENT ON COLUMN management.batches.purchase_detail_id IS 'Reference to the purchase detail';
COMMENT ON COLUMN management.batches.batch_number IS 'Batch or lot number from purchase detail';
COMMENT ON COLUMN management.batches.quantity_remaining IS 'Current remaining quantity in this batch';

-- Create indexes for better performance
CREATE INDEX idx_batches_product_id ON management.batches(product_id);
CREATE INDEX idx_batches_purchase_detail ON management.batches(purchase_detail_id);


-- Sales
-- Records of sales transactions
CREATE TABLE management.sales (
    sale_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50)
);

COMMENT ON COLUMN management.sales.sale_id IS 'Unique identifier for the sale';
COMMENT ON COLUMN management.sales.sale_date IS 'Date and time of the sale';
COMMENT ON COLUMN management.sales.total_amount IS 'Total amount of the sale';
COMMENT ON COLUMN management.sales.payment_method IS 'Method of payment used';

-- Sale Items
-- Detailed items sold in each sale, linked to specific product batches
CREATE TABLE management.sale_items (
    sale_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID REFERENCES management.sales(sale_id),
    product_id UUID REFERENCES management.products(product_id),
    batch_id UUID REFERENCES management.batches(batch_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    CONSTRAINT positive_quantity CHECK (quantity > 0)
);

COMMENT ON COLUMN management.sale_items.sale_item_id IS 'Unique identifier for the sale item';
COMMENT ON COLUMN management.sale_items.sale_id IS 'Reference to the sale';
COMMENT ON COLUMN management.sale_items.product_id IS 'Reference to the product sold';
COMMENT ON COLUMN management.sale_items.batch_id IS 'Reference to the specific batch of the product sold';
COMMENT ON COLUMN management.sale_items.quantity IS 'Quantity of the product sold';
COMMENT ON COLUMN management.sale_items.unit_price IS 'Price per unit at the time of sale';
COMMENT ON COLUMN management.sale_items.total_price IS 'Total price for this item (quantity * unit_price)';

-- Prescriptions
-- Records prescriptions associated with sales of prescription medications
CREATE TABLE management.prescriptions (
    prescription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID REFERENCES management.sales(sale_id),
    prescriber_name VARCHAR(255) NOT NULL,
    prescription_date DATE NOT NULL,
    patient_name VARCHAR(255) NOT NULL
);

COMMENT ON COLUMN management.prescriptions.prescription_id IS 'Unique identifier for the prescription';
COMMENT ON COLUMN management.prescriptions.sale_id IS 'Reference to the associated sale';
COMMENT ON COLUMN management.prescriptions.prescriber_name IS 'Name of the prescribing doctor';
COMMENT ON COLUMN management.prescriptions.prescription_date IS 'Date the prescription was issued';
COMMENT ON COLUMN management.prescriptions.patient_name IS 'Name of the patient';
