-- -- Create the pharma schema
-- CREATE SCHEMA IF NOT EXISTS pharma;

-- * Enum types
-- Create enum types in the pharma schema
CREATE TYPE pharma.drug_type AS ENUM ('Patent', 'Generic');
CREATE TYPE pharma.drug_nature AS ENUM ('Allopathic', 'Homeopathic');
CREATE TYPE pharma.commercialization AS ENUM ('I', 'II', 'III', 'IV', 'V', 'VI');


-- * Tables
-- Pathology table
-- Stores information about various pathologies (diseases or medical conditions) 
-- that pharmaceuticals can treat.
CREATE TABLE pharma.pathology (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

COMMENT ON COLUMN pharma.pathology.name IS 'Name of the pathology';
COMMENT ON COLUMN pharma.pathology.description IS 'Optional description of the pathology';

-- Pharmaceutic Effects table
-- Contains effects that drugs can have on pathologies.
CREATE TABLE pharma.effect (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL
);

COMMENT ON COLUMN pharma.effect.name IS 'Name of the drug effect';
COMMENT ON COLUMN pharma.effect.description IS 'Description of the drug effect';

-- Pharmaceutical table
-- Stores information about pharmaceuticals, including their classification
-- and commercialization status.
CREATE TABLE pharma.drug (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type pharma.drug_type NOT NULL,
    nature pharma.drug_nature NOT NULL,
    commercialization pharma.commercialization NOT NULL
);

COMMENT ON COLUMN pharma.drug.name IS 'Name of the drug';
COMMENT ON COLUMN pharma.drug.type IS 'Type of the drug (Patent or Generic)';
COMMENT ON COLUMN pharma.drug.nature IS 'Nature of the drug (Allopathic or Homeopathic)';
COMMENT ON COLUMN pharma.drug.commercialization IS 'Commercialization category of the drug';

-- drug_pathology table
-- Links pharmaceuticals to the pathologies they are used to treat, 
-- representing a many-to-many relationship.
CREATE TABLE pharma.drug_pathology (
    drug_id UUID REFERENCES pharma.drug(id),
    pathology_id UUID REFERENCES pharma.pathology(id),
    PRIMARY KEY (drug_id, pathology_id)
);

COMMENT ON COLUMN pharma.drug_pathology.drug_id IS 'Reference to the drug';
COMMENT ON COLUMN pharma.drug_pathology.pathology_id IS 'Reference to the pathology the drug treats';

-- Pathology_Effect table
-- Links pathologies to their associated drug effects, 
-- representing a many-to-many relationship.
CREATE TABLE pharma.pathology_effect (
    pathology_id UUID REFERENCES pharma.pathology(id),
    effect_id UUID REFERENCES pharma.effect(id),
    PRIMARY KEY (pathology_id, effect_id)
);

COMMENT ON COLUMN pharma.pathology_effect.pathology_id IS 'Reference to the pathology';
COMMENT ON COLUMN pharma.pathology_effect.effect_id IS 'Reference to the drug effect associated with the pathology';
