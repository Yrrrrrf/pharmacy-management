-- 1. First, create product categories
INSERT INTO management.categories (category_id, name, parent_category_id) VALUES
    -- Main categories
    (gen_random_uuid(), 'Medications', NULL),
    (gen_random_uuid(), 'Personal Care', NULL),
    (gen_random_uuid(), 'Medical Supplies', NULL),
    (gen_random_uuid(), 'Vitamins & Supplements', NULL);

-- Add some subcategories (we'll need to do this in PL/pgSQL due to UUID references)
DO $$
DECLARE
    v_medications_id UUID;
    v_personal_care_id UUID;
    v_medical_supplies_id UUID;
    v_vitamins_id UUID;
BEGIN
    -- Get main category IDs
    SELECT category_id INTO v_medications_id FROM management.categories WHERE name = 'Medications';
    SELECT category_id INTO v_personal_care_id FROM management.categories WHERE name = 'Personal Care';
    SELECT category_id INTO v_medical_supplies_id FROM management.categories WHERE name = 'Medical Supplies';
    SELECT category_id INTO v_vitamins_id FROM management.categories WHERE name = 'Vitamins & Supplements';

    -- Insert subcategories
    INSERT INTO management.categories (category_id, name, parent_category_id) VALUES
        (gen_random_uuid(), 'Prescription Medications', v_medications_id),
        (gen_random_uuid(), 'Over-the-Counter', v_medications_id),
        (gen_random_uuid(), 'Skincare', v_personal_care_id),
        (gen_random_uuid(), 'Dental Care', v_personal_care_id),
        (gen_random_uuid(), 'First Aid', v_medical_supplies_id),
        (gen_random_uuid(), 'Daily Vitamins', v_vitamins_id),
        (gen_random_uuid(), 'Minerals', v_vitamins_id);
END $$;

-- 2. Create suppliers
INSERT INTO management.suppliers (supplier_id, name, contact_person, email, phone, address, is_pharma_manufacturer) VALUES
    (gen_random_uuid(), 'PharmaCorp Industries', 'John Smith', 'contact@pharmacorp.com', '+1234567890', '123 Pharma Street, Medical District', TRUE),
    (gen_random_uuid(), 'MediSupply Co.', 'Maria Garcia', 'sales@medisupply.com', '+1234567891', '456 Supply Ave, Business Park', FALSE),
    (gen_random_uuid(), 'HealthCare Distributors', 'David Wong', 'orders@healthcaredist.com', '+1234567892', '789 Health Boulevard', TRUE),
    (gen_random_uuid(), 'Local Medical Supplies', 'Sarah Johnson', 'info@localmedi.com', '+1234567893', '321 Local Street', FALSE);

-- 3. Create products (linking with pharmaceutical products where applicable)
DO $$
DECLARE
    v_otc_category_id UUID;
    v_prescription_category_id UUID;
    v_first_aid_category_id UUID;
    v_pharma_product_id UUID;
BEGIN
    -- Get category IDs
    SELECT category_id INTO v_otc_category_id FROM management.categories WHERE name = 'Over-the-Counter';
    SELECT category_id INTO v_prescription_category_id FROM management.categories WHERE name = 'Prescription Medications';
    SELECT category_id INTO v_first_aid_category_id FROM management.categories WHERE name = 'First Aid';

    -- Get a pharmaceutical product ID for reference (e.g., Ibuprofen)
    SELECT id INTO v_pharma_product_id FROM pharma.pharmaceutical LIMIT 1;

    -- Insert products
    INSERT INTO management.products (product_id, pharma_product_id, sku, name, description, unit_price, category_id, concentration) VALUES
        -- Pharmaceutical products
        (gen_random_uuid(), v_pharma_product_id, 'MED001', 'Ibuprofen 200mg Tablets', 'Pain relief medication', 9.99, v_otc_category_id, '200mg'),
        (gen_random_uuid(), v_pharma_product_id, 'MED002', 'Acetaminophen 500mg', 'Fever reducer', 7.99, v_otc_category_id, '500mg'),
        -- Non-pharmaceutical products
        (gen_random_uuid(), NULL, 'FAK001', 'First Aid Kit Basic', 'Basic first aid supplies', 24.99, v_first_aid_category_id, NULL),
        (gen_random_uuid(), NULL, 'BAN001', 'Adhesive Bandages 100pc', 'Standard size bandages', 5.99, v_first_aid_category_id, NULL);
END $$;

-- 4. Create purchases and purchase details
DO $$
DECLARE
    v_supplier_id UUID;
    v_product_id UUID;
    v_purchase_id UUID;
BEGIN
    -- Get a supplier ID
    SELECT supplier_id INTO v_supplier_id FROM management.suppliers LIMIT 1;
    
    -- Create a purchase
    INSERT INTO management.purchases (purchase_id, supplier_id, purchase_date, reference)
    VALUES (gen_random_uuid(), v_supplier_id, CURRENT_DATE, 'PO-2024-001')
    RETURNING purchase_id INTO v_purchase_id;

    -- Get a product ID
    SELECT product_id INTO v_product_id FROM management.products LIMIT 1;

    -- Create purchase details
    INSERT INTO management.purchase_details (purchase_id, product_id, quantity, unit_price, expiration_date, batch_number)
    VALUES
        (v_purchase_id, v_product_id, 100, 8.50, CURRENT_DATE + INTERVAL '2 years', 'BATCH001'),
        (v_purchase_id, v_product_id, 50, 7.50, CURRENT_DATE + INTERVAL '2 years', 'BATCH002');
END $$;

-- 5. Create batches based on purchases
DO $$
DECLARE
    v_product_id UUID;
BEGIN
    -- Get a product ID
    SELECT product_id INTO v_product_id FROM management.products LIMIT 1;

    -- Create batches
    INSERT INTO management.batches (batch_id, product_id, batch_number, expiration_date, quantity_received, quantity_remaining)
    VALUES
        (gen_random_uuid(), v_product_id, 'BATCH001', CURRENT_DATE + INTERVAL '2 years', 100, 100),
        (gen_random_uuid(), v_product_id, 'BATCH002', CURRENT_DATE + INTERVAL '2 years', 50, 50);
END $$;

-- 6. Create sales and sale items
DO $$
DECLARE
    v_sale_id UUID;
    v_product_id UUID;
    v_batch_id UUID;
BEGIN
    -- Create a sale
    INSERT INTO management.sales (sale_id, sale_date, total_amount, payment_method)
    VALUES (gen_random_uuid(), CURRENT_TIMESTAMP, 29.97, 'Credit Card')
    RETURNING sale_id INTO v_sale_id;

    -- Get product and batch IDs
    SELECT product_id INTO v_product_id FROM management.products LIMIT 1;
    SELECT batch_id INTO v_batch_id FROM management.batches LIMIT 1;

    -- Create sale items
    INSERT INTO management.sale_items (sale_item_id, sale_id, product_id, batch_id, quantity, unit_price, total_price)
    VALUES
        (gen_random_uuid(), v_sale_id, v_product_id, v_batch_id, 3, 9.99, 29.97);

    -- Create a prescription for the sale
    INSERT INTO management.prescriptions (prescription_id, sale_id, prescriber_name, prescription_date, patient_name)
    VALUES
        (gen_random_uuid(), v_sale_id, 'Dr. Jane Smith', CURRENT_DATE, 'John Doe');
END $$;
