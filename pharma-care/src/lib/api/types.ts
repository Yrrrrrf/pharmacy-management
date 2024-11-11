export interface BaseProduct {
    product_id: string;
    sku: string;
    product_name: string;
    description: string | null;
    unit_price: string;
    category_name: string | null;
    pharma_id: string | null;
    drug_id: string | null;
    drug_name: string | null;
    drug_type: string | null;
    form_name: string | null;
    pharma_concentration: string | null;
    created_at: string;
    updated_at: string;
}


// Add other type definitions as needed
export interface FilterOptions {
    drugType: string;
    drugNature: string;
    commercialization: string;
    pathology: string;
    effect: string;
    pharmaceuticForm: string;
    administrationRoute: string;
    usageConsideration: string;
}