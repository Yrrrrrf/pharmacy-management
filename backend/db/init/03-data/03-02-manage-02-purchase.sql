-- First, let's create some pharmaceutical suppliers
INSERT INTO management.suppliers
(supplier_id, name, contact_person, email, phone, address, is_pharma_manufacturer)
VALUES
    -- Major Pharmaceutical Manufacturers
    (gen_random_uuid(), 'PharmaGen Laboratories', 'Dr. Carlos Ruiz', 'cruiz@pharmagen.com', '+52-555-123-4567', 'Av. Industria Farmacéutica 100, CDMX', true),
    (gen_random_uuid(), 'MediLab Industries', 'Dra. Ana Martínez', 'amartinez@medilab.com', '+52-555-234-5678', 'Blvd. Salud 200, Monterrey', true),
    (gen_random_uuid(), 'BioSyntex México', 'Dr. Ricardo Vega', 'rvega@biosyntex.com', '+52-555-345-6789', 'Calle Innovación 300, Guadalajara', true),

    -- Generic Medication Manufacturers
    (gen_random_uuid(), 'Genéricos Nacionales', 'Lic. María González', 'mgonzalez@gennac.com', '+52-555-456-7890', 'Av. Medicina 400, Puebla', true),
    (gen_random_uuid(), 'Farmacéutica del Norte', 'Ing. Roberto Sánchez', 'rsanchez@fnorte.com', '+52-555-567-8901', 'Carretera Industrial 500, Tijuana', true),

    -- Distributors
    (gen_random_uuid(), 'Distribuidora Médica Central', 'Lic. Patricia Luna', 'pluna@dimec.com', '+52-555-678-9012', 'Calle Distribuición 600, CDMX', false),
    (gen_random_uuid(), 'Grupo Farmacéutico Nacional', 'Ing. Jorge Torres', 'jtorres@gfn.com', '+52-555-789-0123', 'Av. Comercio 700, Mérida', false),

    -- Specialty Medication Suppliers
    (gen_random_uuid(), 'BioTech Specialties', 'Dr. Fernando Rojas', 'frojas@biotech.com', '+52-555-890-1234', 'Paseo Innovación 800, Querétaro', true),
    (gen_random_uuid(), 'Especialidades Farmacéuticas', 'Dra. Laura Campos', 'lcampos@espfarm.com', '+52-555-901-2345', 'Blvd. Tecnológico 900, León', true);

-- Now create purchases and purchase details
DO $$
DECLARE
    -- Supplier IDs
    v_pharmagen_id UUID;
    v_medilab_id UUID;
    v_biosyntex_id UUID;
    v_genericos_id UUID;
    v_farmaceutica_id UUID;
    v_biotech_id UUID;

    -- Loop variables
    v_product_record RECORD;
    v_supplier_record RECORD;
    v_purchase_id UUID;
    v_batch_number TEXT;
    v_current_date DATE := CURRENT_DATE;
    v_purchase_date DATE;
    v_expiration_date DATE;
    v_quantity INTEGER;
    v_base_price DECIMAL(10,2);
BEGIN
    -- Get supplier IDs
    SELECT supplier_id INTO v_pharmagen_id FROM management.suppliers WHERE name = 'PharmaGen Laboratories';
    SELECT supplier_id INTO v_medilab_id FROM management.suppliers WHERE name = 'MediLab Industries';
    SELECT supplier_id INTO v_biosyntex_id FROM management.suppliers WHERE name = 'BioSyntex México';
    SELECT supplier_id INTO v_genericos_id FROM management.suppliers WHERE name = 'Genéricos Nacionales';
    SELECT supplier_id INTO v_farmaceutica_id FROM management.suppliers WHERE name = 'Farmacéutica del Norte';
    SELECT supplier_id INTO v_biotech_id FROM management.suppliers WHERE name = 'BioTech Specialties';

    -- Create purchases for the last 3 months
    FOR i IN 0..3 LOOP
        v_purchase_date := v_current_date - (i * INTERVAL '1 month');

        -- Loop through each supplier
        FOR v_supplier_record IN
            SELECT supplier_id, name
            FROM management.suppliers
        LOOP
            -- Create 2-3 purchases per supplier per month
            FOR j IN 1..2 + floor(random() * 2)::int LOOP
                -- Create purchase
                v_purchase_id := gen_random_uuid();
                INSERT INTO management.purchases (
                    purchase_id,
                    supplier_id,
                    purchase_date,
                    reference
                ) VALUES (
                    v_purchase_id,
                    v_supplier_record.supplier_id,
                    v_purchase_date - (j * INTERVAL '10 days'),
                    'PO-' || TO_CHAR(v_purchase_date, 'YYYYMM') || '-' || LPAD(j::text, 3, '0')
                );

                -- Add purchase details for random products
                FOR v_product_record IN
                    SELECT
                        p.product_id,
                        p.sku,
                        p.unit_price as base_price
                    FROM management.products p
                    WHERE RANDOM() < 0.3  -- Only select ~30% of products per purchase
                LOOP
                    -- Generate expiration date (2-3 years from purchase)
                    v_expiration_date := v_purchase_date + (2 * INTERVAL '1 year') + (floor(random() * 365)::int * INTERVAL '1 day');

                    -- Generate batch number
                    v_batch_number := generate_batch_number(
                        LEFT(v_supplier_record.name, 3),
                        v_product_record.sku,
                        v_purchase_date
                    );

                    -- Generate quantity and calculate price
                    v_quantity := 40 + floor(random() * 20)::int;  -- Random quantity between 50 and 250
                    v_base_price := v_product_record.base_price * (0.9 + random() * 0.2);  -- ±10% price variation

                    -- Create purchase detail
                    INSERT INTO management.purchase_details (
                        purchase_id,
                        product_id,
                        quantity,
                        unit_price,
                        expiration_date,
                        batch_number
                    ) VALUES (
                        v_purchase_id,
                        v_product_record.product_id,
                        v_quantity,
                        v_base_price,
                        v_expiration_date,
                        v_batch_number
                    );

                    -- Create corresponding batch
                    INSERT INTO management.batches (
                        batch_id,
                        product_id,
                        batch_number,
                        expiration_date,
                        quantity_received,
                        quantity_remaining
                    ) VALUES (
                        gen_random_uuid(),
                        v_product_record.product_id,
                        v_batch_number,
                        v_expiration_date,
                        v_quantity,
                        v_quantity - floor(random() * (v_quantity * 0.7))::int  -- Random amount sold
                    );
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END $$
;