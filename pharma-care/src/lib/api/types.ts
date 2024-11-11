// * Used on 'store/ProductCard.svelte'
export interface BaseProduct {
    product_id: string;
    sku: string;
    product_name: string;
    description: string | null;
    unit_price: string;
    category_name: string | null;
    pharma_id: string | null;
    drug_id: string | null;
    created_at: string;
    updated_at: string;
}

export interface PharmaProduct {
    drug_id: string;
    drug_name: string;
    type: string;
    nature: string;
    commercialization: string;
    form_name: string;
    concentrations: string[];
    prices: string[];
    administration_routes: string[] | null;
    usage_considerations: string[] | null;
    pathologies: string[] | null;
}
// ^ Optional: Add event type for better type safety
export type ProductActionHandler = (
    product: BaseProduct, pharmaDetails?: PharmaProduct
) => void;

// * Used on 'store/FilterBar.svelte'
export interface FilterOptions {
    // ~ PHARMACEUTICAL filters
    drugType: string;
    drugNature: string;
    commercialization: string;
    pathology: string;
    effect: string;
    // ~ pharma-product filters
    pharmaceuticForm: string;
    administrationRoute: string;
    usageConsideration: string;
    concentration: string;
    // ~ product specific filters
    // add some new filter for 'unit_price' (as some kind of range)
    price: string;

}

// & Add other type definitions as needed
