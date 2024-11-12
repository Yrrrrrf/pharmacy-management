-- Create pharmaceutical products in the management schema
DO $$
DECLARE
    -- Category IDs
    v_prescription_meds_id UUID;
    v_otc_meds_id UUID;
    v_cardiovascular_id UUID;
    v_antidiabetics_id UUID;
    v_antibiotics_id UUID;
    v_nervous_system_id UUID;
BEGIN
    -- Get necessary category IDs
    SELECT category_id INTO v_prescription_meds_id FROM management.categories WHERE name = 'Medicamentos de Prescripción';
    SELECT category_id INTO v_otc_meds_id FROM management.categories WHERE name = 'Medicamentos OTC';
    SELECT category_id INTO v_cardiovascular_id FROM management.categories WHERE name = 'Cardiovasculares';
    SELECT category_id INTO v_antidiabetics_id FROM management.categories WHERE name = 'Antidiabéticos';
    SELECT category_id INTO v_antibiotics_id FROM management.categories WHERE name = 'Antibióticos';
    SELECT category_id INTO v_nervous_system_id FROM management.categories WHERE name = 'Sistema Nervioso';

    -- Insert products linking them to pharmaceutical products
    INSERT INTO management.products (product_id, pharma_product_id, sku, name, description, unit_price, category_id)  VALUES
        -- Atorvastatina (Cholesterol medication)
        (gen_random_uuid(), '0b723120-c2e6-442f-aee4-235f988fb3ed', 'ATOR-10', 'Atorvastatina 10mg Tabletas', 'Tabletas para reducir el colesterol, 30 unidades', 28.99, v_cardiovascular_id),
        (gen_random_uuid(), '2a371734-954d-47b7-aec8-457630f03d32', 'ATOR-20', 'Atorvastatina 20mg Tabletas', 'Tabletas para reducir el colesterol, 30 unidades', 35.99, v_cardiovascular_id),
        (gen_random_uuid(), 'c0496000-2943-4b35-a7b5-e0d66984e6d1', 'ATOR-40', 'Atorvastatina 40mg Tabletas', 'Tabletas para reducir el colesterol, 30 unidades', 42.99, v_cardiovascular_id),
        (gen_random_uuid(), '4efd4889-2cc8-4dee-a74d-0cec6beff69e', 'ATOR-80', 'Atorvastatina 80mg Tabletas', 'Tabletas para reducir el colesterol, 30 unidades', 49.99, v_cardiovascular_id),

        -- Metformina (Diabetes medication)
        (gen_random_uuid(), '8ec8ae91-df39-4e77-a7d2-0438ece25b22', 'MET-500', 'Metformina 500mg Tabletas', 'Tabletas para diabetes tipo 2, 60 unidades', 15.99, v_antidiabetics_id),
        (gen_random_uuid(), '10587939-8e27-4369-98cd-5de8a28f236a', 'MET-850', 'Metformina 850mg Tabletas', 'Tabletas para diabetes tipo 2, 60 unidades', 18.99, v_antidiabetics_id),
        (gen_random_uuid(), '89f71739-982c-41d6-aa91-fb337872e338', 'MET-1000', 'Metformina 1000mg Tabletas', 'Tabletas para diabetes tipo 2, 60 unidades', 22.99, v_antidiabetics_id),

        -- Omeprazol (Gastric medication - OTC)
        (gen_random_uuid(), 'b02a8b2c-680b-4bd0-809b-cbe63b9acd13', 'OMP-20', 'Omeprazol 20mg Tabletas', 'Tabletas para acidez estomacal, 14 unidades', 12.99, v_otc_meds_id),
        (gen_random_uuid(), '06bd8c52-adf4-435c-85c6-94bd87d10cfa', 'OMP-40', 'Omeprazol 40mg Tabletas', 'Tabletas para acidez estomacal, 14 unidades', 16.99, v_otc_meds_id),
        (gen_random_uuid(), '80ab50aa-b7b8-4529-956b-bacf0badf059', 'OMP-20C', 'Omeprazol 20mg Cápsulas', 'Cápsulas para acidez estomacal, 14 unidades', 13.99, v_otc_meds_id),

        -- Valsartán (Blood pressure medication)
        (gen_random_uuid(), '6c2689ca-da03-4074-9b96-036eaf6f7cc0', 'VAL-80', 'Valsartán 80mg Tabletas', 'Tabletas para hipertensión, 28 unidades', 32.99, v_cardiovascular_id),
        (gen_random_uuid(), '7cbbae6f-ff22-43b9-a972-139b5920e3b7', 'VAL-160', 'Valsartán 160mg Tabletas', 'Tabletas para hipertensión, 28 unidades', 45.99, v_cardiovascular_id),
        (gen_random_uuid(), '819739ab-65da-4e1b-8573-2e70013d0b14', 'VAL-320', 'Valsartán 320mg Tabletas', 'Tabletas para hipertensión, 28 unidades', 58.99, v_cardiovascular_id),

        -- Azitromicina (Antibiotic)
        (gen_random_uuid(), '958917ad-bcf1-4dff-b4fd-675b1ad02178', 'AZI-250', 'Azitromicina 250mg Tabletas', 'Antibiótico, 6 tabletas', 25.99, v_antibiotics_id),
        (gen_random_uuid(), '2be1e33d-abb8-47a1-9a1f-400805e273a4', 'AZI-500', 'Azitromicina 500mg Tabletas', 'Antibiótico, 6 tabletas', 35.99, v_antibiotics_id),
        (gen_random_uuid(), 'b2a38e4a-a206-4da1-b6b3-18379e98ee72', 'AZI-200S', 'Azitromicina 200mg/5ml Suspensión', 'Antibiótico suspensión, 15ml', 22.99, v_antibiotics_id),
        (gen_random_uuid(), '3742592f-aaa2-4911-8018-bb3ea6c067a7', 'AZI-100S', 'Azitromicina 100mg/5ml Suspensión', 'Antibiótico suspensión, 15ml', 18.99, v_antibiotics_id),

        -- Escitalopram (Antidepressant)
        (gen_random_uuid(), 'd7360aa5-bb13-4c8b-96ba-573cb4f18b74', 'ESC-5', 'Escitalopram 5mg Tabletas', 'Antidepresivo, 28 tabletas', 29.99, v_nervous_system_id),
        (gen_random_uuid(), 'b67bfa4b-de2a-40f1-89a8-8ed4851c8c84', 'ESC-10', 'Escitalopram 10mg Tabletas', 'Antidepresivo, 28 tabletas', 39.99, v_nervous_system_id),
        (gen_random_uuid(), 'b8d2b4a5-0e23-42ea-b5fd-a47565c06574', 'ESC-20', 'Escitalopram 20mg Tabletas', 'Antidepresivo, 28 tabletas', 49.99, v_nervous_system_id),

        -- High-value specialty medications
        -- Evolocumab (Cholesterol - Specialty)
        (gen_random_uuid(), '9dfec5f4-540a-4c60-bb00-a448ee4f70b4', 'EVO-140', 'Evolocumab 140mg/ml Inyectable', 'Tratamiento especializado para colesterol, 1 pluma prellenada', 599.99, v_cardiovascular_id),

        -- Adalimumab (Immunosuppressant)
        (gen_random_uuid(), 'ed7a0ba0-9a44-4186-8200-0358746a7187', 'ADA-40-04', 'Adalimumab 40mg/0.4ml Inyectable', 'Tratamiento biológico, 1 jeringa prellenada', 899.99, v_prescription_meds_id),
        (gen_random_uuid(), 'f14a4db5-8443-49e3-b761-ffca2f7c6386', 'ADA-40-08', 'Adalimumab 40mg/0.8ml Inyectable', 'Tratamiento biológico, 1 jeringa prellenada', 899.99, v_prescription_meds_id),

        -- Commonly used antibiotics
        -- Amoxicilina/Clavulanato
        (gen_random_uuid(), '5bf9f45a-2099-46e4-9e78-2ae08c02558c', 'AMC-500', 'Amoxicilina/Clavulanato 500/125mg Tabletas', 'Antibiótico combinado, 20 tabletas', 28.99, v_antibiotics_id),
        (gen_random_uuid(), '23694424-e94c-43d3-8995-06cb41a6e0e4', 'AMC-875', 'Amoxicilina/Clavulanato 875/125mg Tabletas', 'Antibiótico combinado, 20 tabletas', 35.99, v_antibiotics_id),
        (gen_random_uuid(), '5138a7f7-ed9d-4ef4-a25e-0024b03a0041', 'AMC-400S', 'Amoxicilina/Clavulanato 400/57mg Suspensión', 'Antibiótico combinado suspensión, 100ml', 24.99, v_antibiotics_id),
        (gen_random_uuid(), 'bb620ae5-8766-421a-aa79-72c21019d97e', 'AMC-600S', 'Amoxicilina/Clavulanato 600/42.9mg Suspensión', 'Antibiótico combinado suspensión, 100ml', 29.99, v_antibiotics_id)
    ;
END $$;
