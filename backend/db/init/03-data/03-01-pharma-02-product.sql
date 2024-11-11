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