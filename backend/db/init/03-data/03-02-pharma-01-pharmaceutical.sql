-- 1. Antidepressant Example
SELECT pharma.create_pharma_product(
    'Sertralina',           -- Drug name
    'Generic',              -- Type
    'Allopathic',          -- Nature
    'III',                 -- Commercialization (III = prescription required)
    ARRAY[
        ('Tableta', '50mg', 29.99),
        ('Tableta', '100mg', 49.99),
        ('Cápsula', '50mg', 31.99),
        ('Cápsula', '100mg', 52.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Depresión', 'Ansiedad', 'Trastorno de Pánico']  -- Pathologies
);

-- 2. Antibiotic with Multiple Forms
SELECT pharma.create_pharma_product(
    'Amoxicilina',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '500mg', 15.99),
        ('Tableta', '875mg', 22.99),
        ('Suspensión', '250mg/5ml', 18.99),
        ('Suspensión', '500mg/5ml', 25.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Infecciones Bacterianas']
);

-- 3. Patent Drug Example (More Expensive)
SELECT pharma.create_pharma_product(
    'Apixaban',
    'Patent',
    'Allopathic',
    'IV',
    ARRAY[
        ('Tableta', '2.5mg', 89.99),
        ('Tableta', '5mg', 129.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Trombosis', 'Prevención de Embolismo']
);

-- 4. Common Pain Medication
SELECT pharma.create_pharma_product(
    'Naproxeno',
    'Generic',
    'Allopathic',
    'I',
    ARRAY[
        ('Tableta', '250mg', 12.99),
        ('Tableta', '500mg', 18.99),
        ('Suspensión', '125mg/5ml', 15.99),
        ('Gel', '10%', 14.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Dolor', 'Inflamación', 'Artritis']
);

-- 5. Specialized Treatment (High Cost)
SELECT pharma.create_pharma_product(
    'Adalimumab',
    'Patent',
    'Allopathic',
    'VI',
    ARRAY[
        ('Inyección', '40mg/0.4ml', 899.99),
        ('Inyección', '40mg/0.8ml', 899.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Artritis Reumatoide', 'Psoriasis', 'Enfermedad de Crohn']
);

-- 6. Cardiovascular Medication
SELECT pharma.create_pharma_product(
    'Valsartán',
    'Generic',
    'Allopathic',
    'II',
    ARRAY[
        ('Tableta', '80mg', 25.99),
        ('Tableta', '160mg', 35.99),
        ('Tableta', '320mg', 45.99),
        ('Cápsula', '160mg', 37.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Hipertensión', 'Insuficiencia Cardíaca']
);

-- 7. Homeopathic Example
SELECT pharma.create_pharma_product(
    'Árnica Montana',
    'Generic',
    'Homeopathic',
    'I',
    ARRAY[
        ('Tableta', '30CH', 8.99),
        ('Gotas', '30CH', 12.99),
        ('Gel', '30CH', 15.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Dolor Muscular', 'Contusiones', 'Inflamación']
);

-- 8. Respiratory Treatment
SELECT pharma.create_pharma_product(
    'Montelukast',
    'Generic',
    'Allopathic',
    'III',
    ARRAY[
        ('Tableta', '4mg', 29.99),
        ('Tableta', '5mg', 34.99),
        ('Tableta', '10mg', 39.99),
        ('Tableta Masticable', '4mg', 31.99),
        ('Tableta Masticable', '5mg', 36.99)
    ]::pharma.pharma_product_variation[],
    ARRAY['Asma', 'Rinitis Alérgica']
);
