-- Function to help create categories with parent relationships
CREATE OR REPLACE FUNCTION management.create_category(
    p_name VARCHAR,
    p_parent_name VARCHAR DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_category_id UUID;
    v_parent_id UUID;
BEGIN
    IF p_parent_name IS NOT NULL THEN
        SELECT category_id INTO v_parent_id
        FROM management.categories
        WHERE name = p_parent_name;
    END IF;

    INSERT INTO management.categories (category_id, name, parent_category_id)
    VALUES (gen_random_uuid(), p_name, v_parent_id)
    RETURNING category_id INTO v_category_id;

    RETURN v_category_id;
END;
$$ LANGUAGE plpgsql;

-- Main Categories
DO $$ 
DECLARE
    v_category_id UUID;
BEGIN
    -- 1. Medicamentos (Medications)
    PERFORM management.create_category('Medicamentos');
        PERFORM management.create_category('Medicamentos de Prescripción', 'Medicamentos');
            -- Prescription Medications Subcategories
            PERFORM management.create_category('Cardiovasculares', 'Medicamentos de Prescripción');
            PERFORM management.create_category('Antidiabéticos', 'Medicamentos de Prescripción');
            PERFORM management.create_category('Sistema Nervioso', 'Medicamentos de Prescripción');
            PERFORM management.create_category('Antibióticos', 'Medicamentos de Prescripción');
            PERFORM management.create_category('Antiinflamatorios', 'Medicamentos de Prescripción');
        PERFORM management.create_category('Medicamentos OTC', 'Medicamentos');
            -- OTC Medications Subcategories
            PERFORM management.create_category('Analgésicos', 'Medicamentos OTC');
            PERFORM management.create_category('Antiácidos', 'Medicamentos OTC');
            PERFORM management.create_category('Antigripales', 'Medicamentos OTC');
            PERFORM management.create_category('Antialérgicos', 'Medicamentos OTC');
        PERFORM management.create_category('Medicamentos Controlados', 'Medicamentos');
        PERFORM management.create_category('Suplementos Médicos', 'Medicamentos');

    -- 2. Cuidado Personal (Personal Care)
    PERFORM management.create_category('Cuidado Personal');
        PERFORM management.create_category('Cuidado de la Piel', 'Cuidado Personal');
            -- Skin Care Subcategories
            PERFORM management.create_category('Cremas Hidratantes', 'Cuidado de la Piel');
            PERFORM management.create_category('Tratamientos Antiacné', 'Cuidado de la Piel');
            PERFORM management.create_category('Cuidado Corporal', 'Cuidado de la Piel');
            PERFORM management.create_category('Antisépticos Tópicos', 'Cuidado de la Piel');
        PERFORM management.create_category('Cuidado del Cabello', 'Cuidado Personal');
        PERFORM management.create_category('Higiene Bucal', 'Cuidado Personal');
        PERFORM management.create_category('Cuidado Facial', 'Cuidado Personal');
        PERFORM management.create_category('Protección Solar', 'Cuidado Personal');

    -- 3. Equipo Médico (Medical Equipment)
    PERFORM management.create_category('Equipo Médico');
        PERFORM management.create_category('Dispositivos de Medición', 'Equipo Médico');
            -- Measurement Devices Subcategories
            PERFORM management.create_category('Glucómetros', 'Dispositivos de Medición');
            PERFORM management.create_category('Tensiómetros', 'Dispositivos de Medición');
            PERFORM management.create_category('Termómetros', 'Dispositivos de Medición');
            PERFORM management.create_category('Oxímetros', 'Dispositivos de Medición');
        PERFORM management.create_category('Ayudas para Movilidad', 'Equipo Médico');
        PERFORM management.create_category('Equipos de Rehabilitación', 'Equipo Médico');
        PERFORM management.create_category('Suministros Médicos', 'Equipo Médico');

    -- 4. Vitaminas y Suplementos (Vitamins & Supplements)
    PERFORM management.create_category('Vitaminas y Suplementos');
        PERFORM management.create_category('Vitaminas', 'Vitaminas y Suplementos');
        PERFORM management.create_category('Minerales', 'Vitaminas y Suplementos');
        PERFORM management.create_category('Suplementos Deportivos', 'Vitaminas y Suplementos');
        PERFORM management.create_category('Suplementos Herbales', 'Vitaminas y Suplementos');

    -- 5. Salud Sexual (Sexual Health)
    PERFORM management.create_category('Salud Sexual');
        PERFORM management.create_category('Anticonceptivos', 'Salud Sexual');
        PERFORM management.create_category('Higiene Íntima', 'Salud Sexual');
        PERFORM management.create_category('Pruebas de Embarazo', 'Salud Sexual');

    -- 6. Cuidado de Bebé (Baby Care)
    PERFORM management.create_category('Cuidado de Bebé');
        PERFORM management.create_category('Alimentación Infantil', 'Cuidado de Bebé');
        PERFORM management.create_category('Pañales e Higiene', 'Cuidado de Bebé');
        PERFORM management.create_category('Cuidado de la Piel Bebé', 'Cuidado de Bebé');

    -- 7. Primeros Auxilios (First Aid)
    PERFORM management.create_category('Primeros Auxilios');
        PERFORM management.create_category('Vendajes y Gasas', 'Primeros Auxilios');
        PERFORM management.create_category('Antisépticos', 'Primeros Auxilios');
        PERFORM management.create_category('Botiquines', 'Primeros Auxilios');

    -- 8. Ortopedia (Orthopedics)
    PERFORM management.create_category('Ortopedia');
        PERFORM management.create_category('Soportes y Férulas', 'Ortopedia');
        PERFORM management.create_category('Medias de Compresión', 'Ortopedia');
        PERFORM management.create_category('Plantillas y Correctores', 'Ortopedia');

END $$;
