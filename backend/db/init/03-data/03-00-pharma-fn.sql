-- Function to add or update a base drug
/**
 * Creates or updates a drug in the pharma.drug table
 *
 * @param p_id - UUID for the drug (can be generated using gen_random_uuid())
 * @param p_name - Name of the drug (e.g., 'Paracetamol', 'Omeprazol')
 * @param p_type - Type of drug ('Patent' or 'Generic')
 * @param p_nature - Nature of drug ('Allopathic' or 'Homeopathic')
 * @param p_commercialization - Commercialization category ('I' through 'VI')
 * @returns UUID of the created/updated drug
 */
CREATE OR REPLACE FUNCTION pharma.create_drug(
    p_id UUID,
    p_name VARCHAR(255),
    p_type pharma.drug_type,
    p_nature pharma.drug_nature,
    p_commercialization pharma.commercialization
) RETURNS UUID AS $$
DECLARE
    v_drug_id UUID;
BEGIN
    INSERT INTO pharma.drug (id, name, type, nature, commercialization)
    VALUES (p_id, p_name, p_type, p_nature, p_commercialization)
    ON CONFLICT (id) DO UPDATE
    SET name = EXCLUDED.name,
        type = EXCLUDED.type,
        nature = EXCLUDED.nature,
        commercialization = EXCLUDED.commercialization
    RETURNING id INTO v_drug_id;

    RAISE NOTICE 'Drug % successfully created/updated with ID: %', p_name, v_drug_id;
    RETURN v_drug_id;
END;
$$ LANGUAGE plpgsql;

/**
 * Creates a pharmaceutical product for a specific drug with given form and concentration
 *
 * @param p_id - UUID for the pharmaceutical product
 * @param p_drug_id - Reference to the drug ID in pharma.drug
 * @param p_form_id - Reference to the form ID in pharma.form
 * @param p_concentration - Concentration of the drug (e.g., '500mg', '10mg/ml')
 * @returns UUID of the created pharmaceutical product
 */
CREATE OR REPLACE FUNCTION pharma.create_pharmaceutical(
    p_id UUID,
    p_drug_id UUID,
    p_form_id UUID,
    p_concentration VARCHAR(255)
) RETURNS UUID AS $$
DECLARE
    v_pharmaceutical_id UUID;
    v_drug_name VARCHAR;
    v_form_name VARCHAR;
BEGIN
    -- Get drug and form names for the notification
    SELECT name INTO v_drug_name FROM pharma.drug WHERE id = p_drug_id;
    SELECT name INTO v_form_name FROM pharma.form WHERE id = p_form_id;

    -- Validate that drug and form exist
    IF v_drug_name IS NULL THEN
        RAISE EXCEPTION 'Drug with ID % does not exist', p_drug_id;
    END IF;

    IF v_form_name IS NULL THEN
        RAISE EXCEPTION 'Form with ID % does not exist', p_form_id;
    END IF;

    INSERT INTO pharma.pharmaceutical (id, drug_id, form_id, concentration)
    VALUES (p_id, p_drug_id, p_form_id, p_concentration)
    ON CONFLICT (id) DO UPDATE
    SET drug_id = EXCLUDED.drug_id,
        form_id = EXCLUDED.form_id,
        concentration = EXCLUDED.concentration
    RETURNING id INTO v_pharmaceutical_id;

    RAISE NOTICE 'Created pharmaceutical product: % % %', v_drug_name, v_form_name, p_concentration;
    RETURN v_pharmaceutical_id;
END;
$$ LANGUAGE plpgsql;

/**
 * Links a drug with one or more pathologies
 *
 * @param p_drug_id - UUID of the drug
 * @param p_pathology_ids - Array of pathology UUIDs
 */
CREATE OR REPLACE PROCEDURE pharma.link_drug_pathologies(
    p_drug_id UUID,
    p_pathology_ids UUID[]
) AS $$
DECLARE
    v_pathology_id UUID;
    v_drug_name VARCHAR;
    v_pathology_count INTEGER;
BEGIN
    -- Get drug name for notification
    SELECT name INTO v_drug_name FROM pharma.drug WHERE id = p_drug_id;

    IF v_drug_name IS NULL THEN
        RAISE EXCEPTION 'Drug with ID % does not exist', p_drug_id;
    END IF;

    -- Clear existing pathology associations
    DELETE FROM pharma.drug_pathology WHERE drug_id = p_drug_id;

    -- Add new pathology associations
    v_pathology_count := 0;
    FOREACH v_pathology_id IN ARRAY p_pathology_ids
    LOOP
        INSERT INTO pharma.drug_pathology (drug_id, pathology_id)
        VALUES (p_drug_id, v_pathology_id);
        v_pathology_count := v_pathology_count + 1;
    END LOOP;

    RAISE NOTICE 'Updated % pathologies for drug: %', v_pathology_count, v_drug_name;
END;
$$ LANGUAGE plpgsql;

-- First, create a type to handle the pharmaceutical variations
CREATE TYPE pharma.pharma_variation AS (
    form_name VARCHAR(255),
    concentration VARCHAR(255)
);

/**
 * Creates a drug and its pharmaceutical variations in one go
 * 
 * @param p_name - Name of the drug (e.g., 'Paracetamol', 'Omeprazol')
 * @param p_type - Type of drug ('Patent' or 'Generic')
 * @param p_nature - Nature of drug ('Allopathic' or 'Homeopathic')
 * @param p_commercialization - Commercialization category ('I' through 'VI')
 * @param p_variations - Array of variations (form_name, concentration)
 * @returns UUID of the created drug
 *
 * Example usage:
 * SELECT pharma.create_drug_with_variations(
 *     'Omeprazol',
 *     'Generic',
 *     'Allopathic',
 *     'I',
 *     ARRAY[
 *         ('Tableta', '20mg'),
 *         ('Tableta', '40mg'),
 *         ('Cápsula', '20mg')
 *     ]::pharma.pharma_variation[]
 * );
 */
CREATE OR REPLACE FUNCTION pharma.create_drug_with_variations(
    p_name VARCHAR(255),
    p_type pharma.drug_type,
    p_nature pharma.drug_nature,
    p_commercialization pharma.commercialization,
    p_variations pharma.pharma_variation[]
) RETURNS UUID AS $$
DECLARE
    v_drug_id UUID;
    v_variation pharma.pharma_variation;
    v_form_id UUID;
BEGIN
    -- Create the base drug
    v_drug_id := pharma.create_drug(
        gen_random_uuid(),
        p_name,
        p_type,
        p_nature,
        p_commercialization
    );

    -- Create each pharmaceutical variation
    FOREACH v_variation IN ARRAY p_variations
    LOOP
        -- Get the form ID
        SELECT id INTO v_form_id 
        FROM pharma.form 
        WHERE name = v_variation.form_name 
        LIMIT 1;

        IF v_form_id IS NULL THEN
            RAISE EXCEPTION 'Form not found: %', v_variation.form_name;
        END IF;

        -- Create the pharmaceutical product
        PERFORM pharma.create_pharmaceutical(
            gen_random_uuid(),
            v_drug_id,
            v_form_id,
            v_variation.concentration
        );
    END LOOP;

    RETURN v_drug_id;
END;
$$ LANGUAGE plpgsql;

/**
 * Creates a drug with its variations and links it to pathologies
 * 
 * @param p_name - Name of the drug
 * @param p_type - Type of drug
 * @param p_nature - Nature of drug
 * @param p_commercialization - Commercialization category
 * @param p_variations - Array of variations (form_name, concentration)
 * @param p_pathology_names - Array of pathology names to link
 * @returns UUID of the created drug
 */
CREATE OR REPLACE FUNCTION pharma.create_complete_drug(
    p_name VARCHAR(255),
    p_type pharma.drug_type,
    p_nature pharma.drug_nature,
    p_commercialization pharma.commercialization,
    p_variations pharma.pharma_variation[],
    p_pathology_names VARCHAR[] DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_drug_id UUID;
    v_pathology_ids UUID[];
BEGIN
    -- Create drug with variations
    v_drug_id := pharma.create_drug_with_variations(
        p_name,
        p_type,
        p_nature,
        p_commercialization,
        p_variations
    );

    -- If pathology names were provided, link them
    IF p_pathology_names IS NOT NULL THEN
        SELECT ARRAY_AGG(id) INTO v_pathology_ids
        FROM pharma.pathology
        WHERE name = ANY(p_pathology_names);

        IF v_pathology_ids IS NOT NULL THEN
            CALL pharma.link_drug_pathologies(v_drug_id, v_pathology_ids);
        END IF;
    END IF;

    RETURN v_drug_id;
END;
$$ LANGUAGE plpgsql;
