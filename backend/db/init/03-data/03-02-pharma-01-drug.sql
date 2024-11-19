-- Populate Pathology table
INSERT INTO pharma.pathology (id, name, description) VALUES
    (gen_random_uuid(), 'Hipertensión', 'Presión arterial alta sostenida'),
    (gen_random_uuid(), 'Diabetes Tipo 2', 'Alteración en el metabolismo de la glucosa'),
    (gen_random_uuid(), 'Migraña', 'Dolor de cabeza intenso y recurrente'),
    (gen_random_uuid(), 'Artritis', 'Inflamación de las articulaciones'),
    (gen_random_uuid(), 'Asma', 'Enfermedad inflamatoria de las vías respiratorias'),
    (gen_random_uuid(), 'Colesterol Alto', 'Niveles elevados de colesterol en sangre'),
    (gen_random_uuid(), 'Insuficiencia Cardíaca', 'Fallo en la función de bombeo del corazón'),
    (gen_random_uuid(), 'Rinitis Alérgica', 'Inflamación de la mucosa nasal por alergias'),
    (gen_random_uuid(), 'Dolor Crónico', 'Dolor persistente por más de 3 meses'),
    (gen_random_uuid(), 'Dolor Neuropático', 'Dolor causado por daño al sistema nervioso'),
    (gen_random_uuid(), 'Fibromialgia', 'Dolor musculoesquelético generalizado crónico'),
    (gen_random_uuid(), 'Reflujo Gastroesofágico', 'Retorno del contenido estomacal al esófago'),
    (gen_random_uuid(), 'Úlcera Péptica', 'Lesión en la mucosa del estómago o duodeno'),
    (gen_random_uuid(), 'Náusea', 'Sensación de malestar digestivo con deseos de vomitar'),
    (gen_random_uuid(), 'Vómito', 'Expulsión del contenido estomacal'),
    (gen_random_uuid(), 'Depresión', 'Trastorno del estado de ánimo'),
    (gen_random_uuid(), 'Ansiedad', 'Trastorno emocional caracterizado por preocupación excesiva'),
    (gen_random_uuid(), 'Esquizofrenia', 'Trastorno mental que afecta la percepción de la realidad'),
    (gen_random_uuid(), 'Trastorno Bipolar', 'Trastorno del estado de ánimo con cambios extremos'),
    (gen_random_uuid(), 'Infecciones Bacterianas', 'Infecciones causadas por bacterias'),
    (gen_random_uuid(), 'Urticaria', 'Reacción alérgica cutánea'),
    (gen_random_uuid(), 'Hipotiroidismo', 'Producción insuficiente de hormonas tiroideas'),
    (gen_random_uuid(), 'Artritis Reumatoide', 'Enfermedad autoinmune que afecta las articulaciones'),
    (gen_random_uuid(), 'Psoriasis', 'Enfermedad inflamatoria crónica de la piel')
;

-- Populate Effect table
INSERT INTO pharma.effect (id, name, description) VALUES
    (gen_random_uuid(), 'Antihipertensivo', 'Reduce la presión arterial'),
    (gen_random_uuid(), 'Hipoglucemiante', 'Disminuye los niveles de glucosa en sangre'),
    (gen_random_uuid(), 'Antiinflamatorio', 'Reduce la inflamación'),
    (gen_random_uuid(), 'Analgésico', 'Alivia el dolor'),
    (gen_random_uuid(), 'Broncodilatador', 'Dilata los bronquios');

-- Populate Form table
INSERT INTO pharma.form (id, name, code, description) VALUES
    (gen_random_uuid(), 'Tableta', 'TAB', 'Forma farmacéutica sólida'),
    (gen_random_uuid(), 'Cápsula', 'CAPS', 'Cubierta de gelatina con medicamento'),
    (gen_random_uuid(), 'Jarabe', 'JAR', 'Forma farmacéutica líquida'),
    (gen_random_uuid(), 'Inhalador', 'INH', 'Dispositivo para administración pulmonar'),
    (gen_random_uuid(), 'Suspensión', 'SUS', 'Forma farmacéutica líquida con partículas'),
    (gen_random_uuid(), 'Inyección', 'INY', 'Administración por vía intramuscular'),
    (gen_random_uuid(), 'Gel', 'GEL', 'Forma farmacéutica semisólida'),
    (gen_random_uuid(), 'Crema', 'CRE', 'Forma farmacéutica semisólida'),
    (gen_random_uuid(), 'Gotas', 'GOT', 'Forma farmacéutica líquida'),
    (gen_random_uuid(), 'Tableta Masticable', 'TAM', 'Tableta que se desintegra en la boca')
;

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
    (gen_random_uuid(), 'Mantener refrigerado', 'Conservar entre 2-8°C'),
    (gen_random_uuid(), 'Requiere Receta', 'Medicamento que requiere prescripción médica'),
    (gen_random_uuid(), 'Uso Hospitalario', 'Para uso exclusivo en hospitales'),
    (gen_random_uuid(), 'Conservar Congelado', 'Mantener a temperatura bajo cero'),
    (gen_random_uuid(), 'No Triturar', 'No romper ni triturar la tableta')
;


--
-- -- Link drugs with pathologies (you'll need to get the actual UUIDs)
-- DO $$
-- DECLARE
--     v_drug_id UUID;
--     v_pathology_id UUID;
-- BEGIN
--     -- Get IDs for Losartán and Hipertensión
--     SELECT id INTO v_drug_id FROM pharma.drug WHERE name = 'Losartán' LIMIT 1;
--     SELECT id INTO v_pathology_id FROM pharma.pathology WHERE name = 'Hipertensión' LIMIT 1;
--     INSERT INTO pharma.drug_pathology (drug_id, pathology_id)
--     VALUES (v_drug_id, v_pathology_id);
--
--     -- Get IDs for Metformina and Diabetes
--     SELECT id INTO v_drug_id FROM pharma.drug WHERE name = 'Metformina' LIMIT 1;
--     SELECT id INTO v_pathology_id FROM pharma.pathology WHERE name = 'Diabetes Tipo 2' LIMIT 1;
--     INSERT INTO pharma.drug_pathology (drug_id, pathology_id)
--     VALUES (v_drug_id, v_pathology_id);
--
--     -- Continue for other relationships...
-- END $$;
