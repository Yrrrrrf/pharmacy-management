-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION management.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a trigger to automatically update the updated_at column
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON management.products
    FOR EACH ROW
    EXECUTE FUNCTION management.update_updated_at_column();
