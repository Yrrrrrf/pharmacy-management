-- * Tables for new classes

-- PharmaceuticalForm table
-- Stores information about various pharmaceutical forms
CREATE TABLE pharma.form (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

COMMENT ON COLUMN pharma.form.name IS 'Name of the pharmaceutical form';
COMMENT ON COLUMN pharma.form.description IS 'Optional description of the pharmaceutical form';

-- AdministrationRoute table
-- Contains information about different routes of administration for pharmaceuticals
CREATE TABLE pharma.administration_route (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

COMMENT ON COLUMN pharma.administration_route.name IS 'Name of the administration route';
COMMENT ON COLUMN pharma.administration_route.description IS 'Optional description of the administration route';

-- UsageConsideration table
-- Stores various usage considerations for pharmaceutical products
CREATE TABLE pharma.usage_consideration (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT
);

COMMENT ON COLUMN pharma.usage_consideration.name IS 'Name of the usage consideration';
COMMENT ON COLUMN pharma.usage_consideration.description IS 'Optional description of the usage consideration';

-- Pharmaceutical table
-- Represents specific products of pharmaceuticals with their forms and concentrations
CREATE TABLE pharma.pharmaceutical (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drug_id UUID NOT NULL REFERENCES pharma.drug(id),
    form_id UUID NOT NULL REFERENCES pharma.form(id),
    concentration VARCHAR(255) NOT NULL
);

COMMENT ON COLUMN pharma.pharmaceutical.drug_id IS 'Reference to the base pharmaceutical';
COMMENT ON COLUMN pharma.pharmaceutical.form_id IS 'Reference to the pharmaceutical form';
COMMENT ON COLUMN pharma.pharmaceutical.concentration IS 'Concentration of the pharmaceutical in this product';

-- * Transit tables for many-to-many relationships

-- PharmaceuticalForm_UsageConsideration table
-- Links pharmaceutical forms to their associated usage considerations
CREATE TABLE pharma.form_usage_consideration (
    form_id UUID REFERENCES pharma.form(id),
    consideration_id UUID REFERENCES pharma.usage_consideration(id),
    PRIMARY KEY (form_id, consideration_id)
);

COMMENT ON COLUMN pharma.form_usage_consideration.form_id IS 'Reference to the pharmaceutical form';
COMMENT ON COLUMN pharma.form_usage_consideration.consideration_id IS 'Reference to the usage consideration';

-- PharmaceuticalForm_AdministrationRoute table
-- Links pharmaceutical forms to their possible administration routes
CREATE TABLE pharma.form_administration_route (
    form_id UUID REFERENCES pharma.form(id),
    route_id UUID REFERENCES pharma.administration_route(id),
    PRIMARY KEY (form_id, route_id)
);

COMMENT ON COLUMN pharma.form_administration_route.form_id IS 'Reference to the pharmaceutical form';
COMMENT ON COLUMN pharma.form_administration_route.route_id IS 'Reference to the administration route';
