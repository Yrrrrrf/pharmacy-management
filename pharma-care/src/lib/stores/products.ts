// * Used on 'store/ProductCard.svelte'
// lib/types/product.ts
export interface BaseProduct {
    product_id: string;
    sku: string;
    product_name: string;
    description: string | null;
    unit_price: string;
    category_name: string | null;
    pharma_id: string | null;
    drug_id: string | null;
    concentration?: string;
    form?: string;
    created_at: string;
    updated_at: string;
}

export interface PharmaDetails {
    drug_id: string;
    drug_name: string;
    type: 'Patent' | 'Generic';
    nature: 'Allopathic' | 'Homeopathic';
    commercialization: 'I' | 'II' | 'III' | 'IV' | 'V' | 'VI';
    form: string;
    concentration: string;
    pathologies?: string[];
    administration_routes?: string[];
    usage_considerations?: string[];
}

export type ProductWithPharma = BaseProduct & {
    pharmaDetails?: PharmaDetails;
};



export interface PharmaProducts {
    drug_id: string;
    drug_name: string;
    type: string;
    nature: string;
    commercialization: string;
    form: string;
    concentrations: string[];
    prices: string[];
    administration_routes: string[] | null;
    usage_considerations: string[] | null;
    pathologies: string[] | null;
}

export interface PharmaProduct {
    id: string;
    name: string;
    type: string;
    nature: string;
    commercialization: string;
    form: string;
    concentration: string;
    price: string;
}


// // ^ Optional: Add event type for better type safety
// export type ProductActionHandler = (
//     product: BaseProduct, pharmaDetails?: PharmaProduct
// ) => void;

// * Used on 'store/FilterBar.svelte'
export interface FilterOptions {
    drugNames: string[];
    drugTypes: ('Patent' | 'Generic')[];
    drugNatures: ('Allopathic' | 'Homeopathic')[];
    commercializations: ('I' | 'II' | 'III' | 'IV' | 'V' | 'VI')[];
    pathologies: string[];
    effects: string[];
    forms: string[];
    routes: string[];
    considerations: string[];
}

export interface Filters {
    // ~ GENERAL filters
    name: string;
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
    price: string;
}


// lib/stores/products.ts
import { writable, derived } from 'svelte/store';
import { defaultApiClient } from '$lib/api/client';

interface ProductsState {
    items: ProductWithPharma[];
    isLoading: boolean;
    error: string | null;
    lastUpdated: Date | null;
}

function createProductsStore() {
    const { subscribe, set, update } = writable<ProductsState>({
        items: [],
        isLoading: false,
        error: null,
        lastUpdated: null
    });

    return {
        subscribe,
        loadProducts: async () => {
            update(state => ({ ...state, isLoading: true, error: null }));
            
            try {
                // Fetch base products
                const baseProducts = await defaultApiClient.request<BaseProduct[]>('/management/v_base_products');
                
                // Fetch pharma details in parallel for products with drug_id
                const productsWithPharma: ProductWithPharma[] = await Promise.all(
                    baseProducts.map(async (product) => {
                        if (!product.drug_id) return product;
                        
                        try {
                            const [pharmaDetails] = await defaultApiClient
                                .request<PharmaDetails[]>(`/pharma/v_drug_variations?drug_id=${product.drug_id}`);
                            
                            return {
                                ...product,
                                pharmaDetails: pharmaDetails || undefined
                            };
                        } catch (error) {
                            console.error(`Failed to fetch pharma details for ${product.product_id}:`, error);
                            return product;
                        }
                    })
                );

                update(state => ({
                    ...state,
                    items: productsWithPharma,
                    isLoading: false,
                    lastUpdated: new Date()
                }));
            } catch (error) {
                update(state => ({
                    ...state,
                    error: error instanceof Error ? error.message : 'Failed to load products',
                    isLoading: false
                }));
            }
        }
    };
}

export const productsStore = createProductsStore();

// Update the ProductCard type definitions
export type ProductActionHandler = (
    product: BaseProduct, 
    pharmaDetails?: PharmaProduct
) => void;


// Define price range constants
export const PRICE_RANGE = {
    MIN: 0,
    MAX: 10000
} as const;

// Create the filters store
function createFiltersStore() {
    const initialFilters: Filters = {
        name: 'all',
        drugType: 'all',
        drugNature: 'all',
        commercialization: 'all',
        pathology: 'all',
        effect: 'all',
        pharmaceuticForm: 'all',
        administrationRoute: 'all',
        usageConsideration: 'all',
        concentration: '',
        price: `${PRICE_RANGE.MIN},${PRICE_RANGE.MAX}`,
    };

    const { subscribe, set, update } = writable<Filters>(initialFilters);

    return {
        subscribe,
        set,
        update,
        reset: () => set(initialFilters)
    };
}

// Create the search query store
export const searchQuery = writable<string>('');

// Create the filters store instance
export const filters = createFiltersStore();

export function getFilterOptions(state: ProductWithPharma[]): FilterOptions {
    const options: FilterOptions = {
        drugNames: ['all'],
        drugTypes: ['all'],
        drugNatures: ['all'],
        commercializations: ['all'],
        pathologies: ['all'],
        effects: ['all'],
        forms: ['all'],
        routes: ['all'],
        considerations: ['all']
    };

    state.forEach(product => {
        if (product.pharmaDetails) {
            const {
                drug_name,
                type,
                nature,
                commercialization,
                form,
                pathologies,
                administration_routes,
                usage_considerations
            } = product.pharmaDetails;

            if (!options.drugNames.includes(drug_name)) options.drugNames.push(drug_name);
            if (!options.drugTypes.includes(type)) options.drugTypes.push(type);
            if (!options.drugNatures.includes(nature)) options.drugNatures.push(nature);
            if (!options.commercializations.includes(commercialization)) 
                options.commercializations.push(commercialization);
            if (!options.forms.includes(form)) options.forms.push(form);

            pathologies?.forEach(p => {
                if (!options.pathologies.includes(p)) options.pathologies.push(p);
            });

            administration_routes?.forEach(r => {
                if (!options.routes.includes(r)) options.routes.push(r);
            });

            usage_considerations?.forEach(c => {
                if (!options.considerations.includes(c)) options.considerations.push(c);
            });
        }
    });

    return options;
};


// Update filteredProducts to use filters
export const filteredProducts = derived(
    [productsStore, filters, searchQuery],
    ([$products, $filters, $search]) => {
        let filtered = $products.items;

        // Apply search filter
        if ($search) {
            const searchLower = $search.toLowerCase();
            filtered = filtered.filter(product => 
                product.product_name.toLowerCase().includes(searchLower) ||
                product.sku.toLowerCase().includes(searchLower) ||
                product.description?.toLowerCase().includes(searchLower)
            );
        }

        // Apply filters
        filtered = filtered.filter(product => {
            // Skip filtering if no pharma details or if filter is set to 'all'
            if (!product.pharmaDetails) {
                return $filters.name === 'all'; // Only show non-pharma products when no filters are active
            }

            const matchesName = $filters.name === 'all' || 
                product.pharmaDetails.drug_name === $filters.name;

            const matchesType = $filters.drugType === 'all' || 
                product.pharmaDetails.type === $filters.drugType;

            const matchesNature = $filters.drugNature === 'all' || 
                product.pharmaDetails.nature === $filters.drugNature;

            const matchesCommercialization = $filters.commercialization === 'all' || 
                product.pharmaDetails.commercialization === $filters.commercialization;

            const matchesPathology = $filters.pathology === 'all' || 
                product.pharmaDetails.pathologies?.includes($filters.pathology);

            const matchesForm = $filters.pharmaceuticForm === 'all' || 
                product.pharmaDetails.form === $filters.pharmaceuticForm;

            const matchesRoute = $filters.administrationRoute === 'all' || 
                product.pharmaDetails.administration_routes?.includes($filters.administrationRoute);

            const matchesConsideration = $filters.usageConsideration === 'all' || 
                product.pharmaDetails.usage_considerations?.includes($filters.usageConsideration);

            const matchesConcentration = !$filters.concentration || 
                product.pharmaDetails.concentration.includes($filters.concentration);

            // Price filter
            const [minPrice, maxPrice] = $filters.price.split(',').map(Number);
            const productPrice = Number(product.unit_price);
            const matchesPrice = productPrice >= minPrice && productPrice <= maxPrice;

            return matchesName && 
                   matchesType && 
                   matchesNature && 
                   matchesCommercialization && 
                   matchesPathology && 
                   matchesForm && 
                   matchesRoute && 
                   matchesConsideration && 
                   matchesConcentration && 
                   matchesPrice;
        });

        return filtered;
    }
);

// Export everything needed