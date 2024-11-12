-- Example 1: Creating Omeprazol with its variations
SELECT pharma.create_drug_with_variations(
    'Omeprazol',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '20mg'),
        ('Tableta', '40mg'),
        ('Cápsula', '20mg')
    ]::pharma.pharma_variation[]
);

-- Example 2: Creating Metformina with variations and pathologies
SELECT pharma.create_complete_drug(
    'Metformina',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '500mg'),
        ('Tableta', '850mg'),
        ('Tableta', '1000mg')
    ]::pharma.pharma_variation[],
    ARRAY['Diabetes Tipo 2']
);

-- Example 3: Creating Amlodipino with variations and multiple pathologies
SELECT pharma.create_complete_drug(
    'Amlodipino',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '2.5mg'),
        ('Tableta', '5mg'),
        ('Tableta', '10mg')
    ]::pharma.pharma_variation[],
    ARRAY['Hipertensión']
);

-- Example 4: Creating Ibuprofeno with various forms
SELECT pharma.create_complete_drug(
    'Ibuprofeno',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '200mg'),
        ('Tableta', '400mg'),
        ('Tableta', '600mg'),
        ('Suspensión', '100mg/5ml'),
        ('Suspensión', '200mg/5ml')
    ]::pharma.pharma_variation[],
    ARRAY['Artritis', 'Migraña']
);


-- ^ SOME( NEW DT )
-- Cardiovascular Medications
SELECT pharma.create_complete_drug(
    'Atorvastatina',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '10mg'),
        ('Tableta', '20mg'),
        ('Tableta', '40mg'),
        ('Tableta', '80mg')
    ]::pharma.pharma_variation[],
    ARRAY['Hipertensión', 'Colesterol Alto']
);

SELECT pharma.create_complete_drug(
    'Valsartán',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '80mg'),
        ('Tableta', '160mg'),
        ('Tableta', '320mg'),
        ('Cápsula', '160mg')
    ]::pharma.pharma_variation[],
    ARRAY['Hipertensión', 'Insuficiencia Cardíaca']
);

SELECT pharma.create_complete_drug(
    'Carvedilol',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '6.25mg'),
        ('Tableta', '12.5mg'),
        ('Tableta', '25mg')
    ]::pharma.pharma_variation[],
    ARRAY['Hipertensión', 'Insuficiencia Cardíaca']
);

-- Antidiabetic Medications
SELECT pharma.create_complete_drug(
    'Sitagliptina',
    'Patent',
    'Allopathic',
    'III',
    ARRAY[
        ('Tableta', '25mg'),
        ('Tableta', '50mg'),
        ('Tableta', '100mg')
    ]::pharma.pharma_variation[],
    ARRAY['Diabetes Tipo 2']
);

SELECT pharma.create_complete_drug(
    'Empagliflozina',
    'Patent',
    'Allopathic',
    'IV',
    ARRAY[
        ('Tableta', '10mg'),
        ('Tableta', '25mg')
    ]::pharma.pharma_variation[],
    ARRAY['Diabetes Tipo 2', 'Insuficiencia Cardíaca']
);

-- Pain Management and Anti-inflammatory
SELECT pharma.create_complete_drug(
    'Celecoxib',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Cápsula', '100mg'),
        ('Cápsula', '200mg')
    ]::pharma.pharma_variation[],
    ARRAY['Artritis', 'Dolor Crónico']
);

SELECT pharma.create_complete_drug(
    'Pregabalina',
    'Generic',
    'Allopathic',
    'III',
    ARRAY[
        ('Cápsula', '25mg'),
        ('Cápsula', '75mg'),
        ('Cápsula', '150mg'),
        ('Cápsula', '300mg')
    ]::pharma.pharma_variation[],
    ARRAY['Dolor Neuropático', 'Fibromialgia']
);

-- Gastrointestinal Medications
SELECT pharma.create_complete_drug(
    'Pantoprazol',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '20mg'),
        ('Tableta', '40mg'),
        ('Tableta', '40mg')
    ]::pharma.pharma_variation[],
    ARRAY['Reflujo Gastroesofágico', 'Úlcera Péptica']
);

SELECT pharma.create_complete_drug(
    'Ondansetrón',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '4mg'),
        ('Tableta', '8mg')
    ]::pharma.pharma_variation[],
    ARRAY['Náusea', 'Vómito']
);

-- Mental Health Medications
SELECT pharma.create_complete_drug(
    'Escitalopram',
    'Generic',
    'Allopathic',
    'III',
    ARRAY[
        ('Tableta', '5mg'),
        ('Tableta', '10mg'),
        ('Tableta', '20mg')
    ]::pharma.pharma_variation[],
    ARRAY['Depresión', 'Ansiedad']
);

SELECT pharma.create_complete_drug(
    'Quetiapina',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '25mg'),
        ('Tableta', '100mg'),
        ('Tableta', '200mg'),
        ('Tableta', '300mg')
    ]::pharma.pharma_variation[],
    ARRAY['Esquizofrenia', 'Trastorno Bipolar']
);

-- Antibiotics
SELECT pharma.create_complete_drug(
    'Azitromicina',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '250mg'),
        ('Tableta', '500mg'),
        ('Suspensión', '200mg/5ml'),
        ('Suspensión', '100mg/5ml')
    ]::pharma.pharma_variation[],
    ARRAY['Infecciones Bacterianas']
);

SELECT pharma.create_complete_drug(
    'Amoxicilina/Clavulanato',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '500mg/125mg'),
        ('Tableta', '875mg/125mg'),
        ('Suspensión', '400mg/57mg/5ml'),
        ('Suspensión', '600mg/42.9mg/5ml')
    ]::pharma.pharma_variation[],
    ARRAY['Infecciones Bacterianas']
);

-- Allergy Medications
SELECT pharma.create_complete_drug(
    'Desloratadina',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '5mg'),
        ('Jarabe', '2.5mg/5ml')
    ]::pharma.pharma_variation[],
    ARRAY['Rinitis Alérgica', 'Urticaria']
);

-- Hormone Treatments
SELECT pharma.create_complete_drug(
    'Levotiroxina',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '25mcg'),
        ('Tableta', '50mcg'),
        ('Tableta', '75mcg'),
        ('Tableta', '100mcg'),
        ('Tableta', '125mcg')
    ]::pharma.pharma_variation[],
    ARRAY['Hipotiroidismo']
);

-- New Generation Patents
SELECT pharma.create_complete_drug(
    'Dapagliflozina',
    'Patent',
    'Allopathic',
    'V',
    ARRAY[
        ('Tableta', '5mg'),
        ('Tableta', '10mg')
    ]::pharma.pharma_variation[],
    ARRAY['Diabetes Tipo 2', 'Insuficiencia Cardíaca']
);

SELECT pharma.create_complete_drug(
    'Evolocumab',
    'Patent',
    'Allopathic',
    'VI',
    ARRAY[
        ('Inyección', '140mg/ml')
    ]::pharma.pharma_variation[],
    ARRAY['Colesterol Alto']
);

-- Specialized Treatments
SELECT pharma.create_complete_drug(
    'Adalimumab',
    'Patent',
    'Allopathic',
    'VI',
    ARRAY[
        ('Inyección', '40mg/0.4ml'),
        ('Inyección', '40mg/0.8ml')
    ]::pharma.pharma_variation[],
    ARRAY['Artritis Reumatoide', 'Psoriasis']
);
