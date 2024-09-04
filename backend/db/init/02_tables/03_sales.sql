-- File: 03_sales.sql
-- Defines the table structure for the sales schema

-- Sales
CREATE TABLE sales.sales (
    sale_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- customer_id UUID REFERENCES customer.customer(customer_id),
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    status VARCHAR(50) DEFAULT 'completed'
);

COMMENT ON COLUMN sales.sales.sale_id IS 'Unique identifier for the sale';
-- COMMENT ON COLUMN sales.sales.customer_id IS 'Reference to the customer who made the purchase (can be NULL for anonymous sales)';
COMMENT ON COLUMN sales.sales.sale_date IS 'Date and time when the sale occurred';
COMMENT ON COLUMN sales.sales.total_amount IS 'Total amount of the sale';
COMMENT ON COLUMN sales.sales.payment_method IS 'Method of payment used for the sale';
COMMENT ON COLUMN sales.sales.status IS 'Current status of the sale (e.g., completed, refunded)';

-- Sale Items
CREATE TABLE sales.sale_items (
--     sale_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID REFERENCES sales.sales(sale_id),
    product_id UUID REFERENCES inventory.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    CONSTRAINT positive_quantity CHECK (quantity > 0)
);

COMMENT ON COLUMN sales.sale_items.sale_id IS 'Reference to the sale this item belongs to';
COMMENT ON COLUMN sales.sale_items.product_id IS 'Reference to the product sold';
COMMENT ON COLUMN sales.sale_items.quantity IS 'Quantity of the product sold';
COMMENT ON COLUMN sales.sale_items.unit_price IS 'Price per unit of the product at the time of sale';
COMMENT ON COLUMN sales.sale_items.total_price IS 'Total price for this item (quantity * unit_price)';

-- Indexes for better query performance
-- CREATE INDEX idx_sales_customer ON sales.sales(customer_id);
CREATE INDEX idx_sale_items_sale ON sales.sale_items(sale_id);
CREATE INDEX idx_sale_items_product ON sales.sale_items(product_id);

