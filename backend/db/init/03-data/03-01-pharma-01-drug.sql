-- Populate Pathology table
INSERT INTO pharma.pathology (id, name, description) VALUES
    (gen_random_uuid(), 'Hipertensión', 'Presión arterial alta sostenida'),
    (gen_random_uuid(), 'Diabetes Tipo 2', 'Alteración en el metabolismo de la glucosa'),
    (gen_random_uuid(), 'Migraña', 'Dolor de cabeza intenso y recurrente'),
    (gen_random_uuid(), 'Artritis', 'Inflamación de las articulaciones'),
    (gen_random_uuid(), 'Asma', 'Enfermedad inflamatoria de las vías respiratorias');

-- Populate Effect table
INSERT INTO pharma.effect (id, name, description) VALUES
    (gen_random_uuid(), 'Antihipertensivo', 'Reduce la presión arterial'),
    (gen_random_uuid(), 'Hipoglucemiante', 'Disminuye los niveles de glucosa en sangre'),
    (gen_random_uuid(), 'Antiinflamatorio', 'Reduce la inflamación'),
    (gen_random_uuid(), 'Analgésico', 'Alivia el dolor'),
    (gen_random_uuid(), 'Broncodilatador', 'Dilata los bronquios');

-- Populate Drug table
INSERT INTO pharma.drug (id, name, type, nature, commercialization) VALUES
    (gen_random_uuid(), 'Losartán', 'Generic', 'Allopathic', 'I'),
    (gen_random_uuid(), 'Metformina', 'Generic', 'Allopathic', 'II'),
    (gen_random_uuid(), 'Sumatriptán', 'Patent', 'Allopathic', 'III'),
    (gen_random_uuid(), 'Ibuprofeno', 'Generic', 'Allopathic', 'I'),
    (gen_random_uuid(), 'Salbutamol', 'Generic', 'Allopathic', 'II');

-- Populate Form table
INSERT INTO pharma.form (id, name, description) VALUES
    (gen_random_uuid(), 'Tableta', 'Forma farmacéutica sólida'),
    (gen_random_uuid(), 'Cápsula', 'Cubierta de gelatina con medicamento'),
    (gen_random_uuid(), 'Jarabe', 'Forma farmacéutica líquida'),
    (gen_random_uuid(), 'Inhalador', 'Dispositivo para administración pulmonar'),
    (gen_random_uuid(), 'Suspensión', 'Forma farmacéutica líquida con partículas');

-- Populate Administration Route table
INSERT INTO pharma.administration_route (id, name, description) VALUES
    (gen_random_uuid(), 'Oral', 'Administración por boca'),
    (gen_random_uuid(), 'Inhalación', 'Administración por vías respiratorias'),
    (gen_random_uuid(), 'Sublingual', 'Administración bajo la lengua'),
    (gen_random_uuid(), 'Tópica', 'Aplicación sobre la piel'),
    (gen_random_uuid(), 'Intranasal', 'Administración por la nariz');

-- Populate Usage Consideration table
INSERT INTO pharma.usage_consideration (id, name, description) VALUES
    (gen_random_uuid(), 'Tomar con alimentos', 'Debe administrarse junto con las comidas'),
    (gen_random_uuid(), 'Evitar alcohol', 'No consumir bebidas alcohólicas durante el tratamiento'),
    (gen_random_uuid(), 'No conducir', 'Puede causar somnolencia'),
    (gen_random_uuid(), 'Proteger de la luz', 'Mantener en envase opaco'),
    (gen_random_uuid(), 'Mantener refrigerado', 'Conservar entre 2-8°C');




-- Link drugs with pathologies (you'll need to get the actual UUIDs)
DO $$
DECLARE
    v_drug_id UUID;
    v_pathology_id UUID;
BEGIN
    -- Get IDs for Losartán and Hipertensión
    SELECT id INTO v_drug_id FROM pharma.drug WHERE name = 'Losartán' LIMIT 1;
    SELECT id INTO v_pathology_id FROM pharma.pathology WHERE name = 'Hipertensión' LIMIT 1;
    INSERT INTO pharma.drug_pathology (drug_id, pathology_id)
    VALUES (v_drug_id, v_pathology_id);

    -- Get IDs for Metformina and Diabetes
    SELECT id INTO v_drug_id FROM pharma.drug WHERE name = 'Metformina' LIMIT 1;
    SELECT id INTO v_pathology_id FROM pharma.pathology WHERE name = 'Diabetes Tipo 2' LIMIT 1;
    INSERT INTO pharma.drug_pathology (drug_id, pathology_id)
    VALUES (v_drug_id, v_pathology_id);

    -- Continue for other relationships...
END $$;
