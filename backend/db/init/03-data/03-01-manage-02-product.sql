-- Create non-pharmaceutical products for different categories
DO $$
DECLARE
    -- Category IDs for medical devices
    v_medical_devices_id UUID;
    v_measurement_devices_id UUID;
    v_glucometers_id UUID;
    v_thermometers_id UUID;
    
    -- Category IDs for first aid
    v_first_aid_id UUID;
    v_bandages_id UUID;
    v_antiseptics_id UUID;
    
    -- Category IDs for personal care
    v_skin_care_id UUID;
    v_oral_care_id UUID;
    v_sun_protection_id UUID;
    
    -- Category IDs for baby care
    v_baby_care_id UUID;
    v_baby_hygiene_id UUID;
    
    -- Category IDs for orthopedics
    v_orthopedics_id UUID;
    v_supports_id UUID;
BEGIN
    -- Get category IDs
    SELECT category_id INTO v_medical_devices_id FROM management.categories WHERE name = 'Equipo Médico';
    SELECT category_id INTO v_measurement_devices_id FROM management.categories WHERE name = 'Dispositivos de Medición';
    SELECT category_id INTO v_glucometers_id FROM management.categories WHERE name = 'Glucómetros';
    SELECT category_id INTO v_thermometers_id FROM management.categories WHERE name = 'Termómetros';
    
    SELECT category_id INTO v_first_aid_id FROM management.categories WHERE name = 'Primeros Auxilios';
    SELECT category_id INTO v_bandages_id FROM management.categories WHERE name = 'Vendajes y Gasas';
    SELECT category_id INTO v_antiseptics_id FROM management.categories WHERE name = 'Antisépticos';
    
    SELECT category_id INTO v_skin_care_id FROM management.categories WHERE name = 'Cuidado de la Piel';
    SELECT category_id INTO v_oral_care_id FROM management.categories WHERE name = 'Higiene Bucal';
    SELECT category_id INTO v_sun_protection_id FROM management.categories WHERE name = 'Protección Solar';
    
    SELECT category_id INTO v_baby_care_id FROM management.categories WHERE name = 'Cuidado de Bebé';
    SELECT category_id INTO v_baby_hygiene_id FROM management.categories WHERE name = 'Pañales e Higiene';
    
    SELECT category_id INTO v_orthopedics_id FROM management.categories WHERE name = 'Ortopedia';
    SELECT category_id INTO v_supports_id FROM management.categories WHERE name = 'Soportes y Férulas';

    -- Insert Medical Devices Products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        -- Measurement Devices
        (gen_random_uuid(), 'GLU001', 'Glucómetro Digital Plus', 'Medidor de glucosa en sangre con pantalla LCD', 45.99, v_glucometers_id),
        (gen_random_uuid(), 'GLU002', 'Tiras Reactivas GlucoCheck', 'Tiras para medición de glucosa (50 unidades)', 19.99, v_glucometers_id),
        (gen_random_uuid(), 'TERM001', 'Termómetro Digital Infrarrojo', 'Termómetro sin contacto con pantalla LED', 34.99, v_thermometers_id),
        (gen_random_uuid(), 'TERM002', 'Termómetro Digital Flexible', 'Termómetro axilar con punta flexible', 12.99, v_thermometers_id);

    -- Insert First Aid Products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        -- Bandages and Dressings
        (gen_random_uuid(), 'VEND001', 'Venda Elástica 10cm', 'Venda elástica de compresión', 5.99, v_bandages_id),
        (gen_random_uuid(), 'VEND002', 'Gasas Estériles 10x10cm', 'Paquete de 10 gasas estériles', 3.99, v_bandages_id),
        (gen_random_uuid(), 'BOT001', 'Botiquín Familiar Completo', 'Kit completo de primeros auxilios', 29.99, v_first_aid_id),
        -- Antiseptics
        (gen_random_uuid(), 'ANT001', 'Alcohol 70% 250ml', 'Alcohol antiséptico', 4.99, v_antiseptics_id),
        (gen_random_uuid(), 'ANT002', 'Agua Oxigenada 3% 120ml', 'Peróxido de hidrógeno', 3.49, v_antiseptics_id);

    -- Insert Personal Care Products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        -- Skin Care
        (gen_random_uuid(), 'SKIN001', 'Crema Hidratante Facial', 'Crema hidratante para todo tipo de piel', 15.99, v_skin_care_id),
        (gen_random_uuid(), 'SKIN002', 'Gel Antibacterial 500ml', 'Gel desinfectante de manos', 7.99, v_skin_care_id),
        -- Oral Care
        (gen_random_uuid(), 'ORAL001', 'Cepillo Dental Suave', 'Cepillo con cerdas suaves', 4.99, v_oral_care_id),
        (gen_random_uuid(), 'ORAL002', 'Hilo Dental Mentolado', 'Hilo dental encerado 50m', 3.99, v_oral_care_id),
        -- Sun Protection
        (gen_random_uuid(), 'SUN001', 'Protector Solar SPF50', 'Protección solar de amplio espectro', 18.99, v_sun_protection_id),
        (gen_random_uuid(), 'SUN002', 'After Sun Gel 200ml', 'Gel calmante post-solar', 12.99, v_sun_protection_id);

    -- Insert Baby Care Products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        -- Baby Hygiene
        (gen_random_uuid(), 'BABY001', 'Pañales Talla 1 (36u)', 'Pañales para recién nacido', 14.99, v_baby_hygiene_id),
        (gen_random_uuid(), 'BABY002', 'Toallitas Húmedas (100u)', 'Toallitas sin alcohol', 5.99, v_baby_hygiene_id),
        (gen_random_uuid(), 'BABY003', 'Champú Suave Bebé 250ml', 'Champú sin lágrimas', 8.99, v_baby_hygiene_id);

    -- Insert Orthopedic Products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        -- Supports and Braces
        (gen_random_uuid(), 'ORT001', 'Muñequera Elástica', 'Soporte para muñeca ajustable', 12.99, v_supports_id),
        (gen_random_uuid(), 'ORT002', 'Rodillera Deportiva', 'Soporte para rodilla con ajuste', 19.99, v_supports_id),
        (gen_random_uuid(), 'ORT003', 'Tobillera Estabilizadora', 'Soporte para tobillo con compresión', 16.99, v_supports_id);

    -- Add some specialty medical devices
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        (gen_random_uuid(), 'DEV001', 'Tensiómetro Digital', 'Monitor de presión arterial automático', 59.99, v_measurement_devices_id),
        (gen_random_uuid(), 'DEV002', 'Oxímetro de Pulso', 'Medidor de saturación de oxígeno', 39.99, v_measurement_devices_id),
        (gen_random_uuid(), 'DEV003', 'Nebulizador Ultrasónico', 'Nebulizador para uso doméstico', 49.99, v_medical_devices_id);

    -- Add some premium/professional products
    INSERT INTO management.products (product_id, sku, name, description, unit_price, category_id) VALUES
        (gen_random_uuid(), 'PRO001', 'Kit Diagnóstico Profesional', 'Incluye otoscopio y oftalmoscopio', 299.99, v_medical_devices_id),
        (gen_random_uuid(), 'PRO002', 'Estetoscopio Premium', 'Estetoscopio de doble campana', 89.99, v_medical_devices_id),
        (gen_random_uuid(), 'PRO003', 'Monitor Multiparamétrico', 'Monitor de signos vitales portátil', 499.99, v_medical_devices_id);

END $$;
