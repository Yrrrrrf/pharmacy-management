// stores/products.ts
import { writable, derived, get } from 'svelte/store';
import { defaultApiClient } from '$lib/api/client';
import type { BaseProduct, PharmaProduct, FilterOptions } from '$lib/api/types';

interface ProductsState {
    items: BaseProduct[];
    pharmaDetails: Map<string, PharmaProduct>; // Cache pharma details by drug_id
    isLoading: boolean;
    error: string | null;
    lastUpdated: Date | null;
}

function createProductsStore() {
    const initialState: ProductsState = {
        items: [],
        pharmaDetails: new Map(),
        isLoading: false,
        error: null,
        lastUpdated: null
    };

    const { subscribe, set, update } = writable(initialState);

    return {
        subscribe,
        loadProducts: async () => {
            update(state => ({ ...state, isLoading: true, error: null }));
            try {
                const products = await defaultApiClient.request<BaseProduct[]>('/management/v_base_products');
                
                // Collect unique drug_ids from pharma products
                const drugIds = new Set(
                    products
                        .filter(p => p.pharma_id && p.drug_id)
                        .map(p => p.drug_id!)
                );

                // Fetch pharma details for all pharmaceutical products
                const pharmaDetails = new Map<string, PharmaProduct>();
                if (drugIds.size > 0) {
                    const promises = Array.from(drugIds).map(async (drugId) => {
                        try {
                            const response = await defaultApiClient
                                .request<PharmaProduct[]>(`/pharma/v_drug_variations?drug_id=${drugId}`);
                            if (response && response[0]) {
                                pharmaDetails.set(drugId, response[0]);
                            }
                        } catch (error) {
                            console.error(`Error fetching pharma details for drug ${drugId}:`, error);
                        }
                    });

                    await Promise.all(promises);
                }

                update(state => ({
                    ...state,
                    items: products,
                    pharmaDetails,
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
        },
        getPharmaDetails: (drugId: string) => {
            const state = get(productsStore);
            return state.pharmaDetails.get(drugId) || null;
        },
        reset: () => set(initialState)
    };
}

export const productsStore = createProductsStore();


// todo: Check the filtering functions...
// Filtering constants
export const PRICE_RANGE = {
    MIN: 0,
    MAX: 1000,
    STEP: 10
} as const;

// Filter options initial state
export const initialFilters: FilterOptions = {
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

// Create stores
export const searchQuery = writable('');
export const filters = writable(initialFilters);

// Helper functions for filtering
function matchesSearch(product: BaseProduct, query: string): boolean {
    if (!query) return true;
    const searchLower = query.toLowerCase();
    return (
        product.product_name.toLowerCase().includes(searchLower) ||
        product.description?.toLowerCase().includes(searchLower) ||
        product.sku.toLowerCase().includes(searchLower)
    );
}

function matchesPriceRange(product: BaseProduct, priceRange: string): boolean {
    const [min, max] = priceRange.split(',').map(Number);
    const price = Number(product.unit_price);
    return price >= min && price <= max;
}

function matchesFilters(
    product: BaseProduct, 
    filters: FilterOptions, 
    pharmaDetails: PharmaProduct | null
): boolean | undefined {
    // If no pharma details and pharma filters are active, exclude product
    if (!pharmaDetails && (
        filters.drugType !== 'all' || 
        filters.drugNature !== 'all' ||
        filters.pathology !== 'all' ||
        filters.effect !== 'all'
    )) {
        return false;
    }

    // Price range check
    if (!matchesPriceRange(product, filters.price)) {
        return false;
    }

    // If not a pharma product, only check general filters
    if (!pharmaDetails) {
        return true;
    }

    // Check pharma-specific filters
    return (
        (filters.drugType === 'all' || pharmaDetails.type === filters.drugType) &&
        (filters.drugNature === 'all' || pharmaDetails.nature === filters.drugNature) &&
        (filters.commercialization === 'all' || pharmaDetails.commercialization === filters.commercialization) &&
        (filters.pathology === 'all' || pharmaDetails.pathologies?.includes(filters.pathology)) &&
        (filters.pharmaceuticForm === 'all' || pharmaDetails.form_name === filters.pharmaceuticForm) &&
        (filters.administrationRoute === 'all' || pharmaDetails.administration_routes?.includes(filters.administrationRoute)) &&
        (filters.usageConsideration === 'all' || pharmaDetails.usage_considerations?.includes(filters.usageConsideration)) &&
        (!filters.concentration || pharmaDetails.concentrations?.includes(filters.concentration))
    );
}

// Derived store for filtered products
export const filteredProducts = derived(
    [productsStore, searchQuery, filters],
    ([$products, $searchQuery, $filters]) => {
        return $products.items.filter(product => {
            // Ensure pharmaDetails is properly typed
            const pharmaDetails: PharmaProduct | null = 
                product.drug_id ? $products.pharmaDetails.get(product.drug_id) ?? null : null;
            
            return (
                matchesSearch(product, $searchQuery) &&
                matchesFilters(product, $filters, pharmaDetails)
            );
        });
    }
);

// Get unique values for filter options
export function getFilterOptions(products: ProductsState): {
    drugTypes: string[];
    drugNatures: string[];
    commercializations: string[];
    pathologies: string[];
    effects: string[];
    forms: string[];
    routes: string[];
    considerations: string[];
    concentrations: string[];
} {
    const options = {
        drugTypes: new Set<string>(['all']),
        drugNatures: new Set<string>(['all']),
        commercializations: new Set<string>(['all']),
        pathologies: new Set<string>(['all']),
        effects: new Set<string>(['all']),
        forms: new Set<string>(['all']),
        routes: new Set<string>(['all']),
        considerations: new Set<string>(['all']),
        concentrations: new Set<string>(),
    };

    products.pharmaDetails.forEach(pharma => {
        options.drugTypes.add(pharma.type);
        options.drugNatures.add(pharma.nature);
        options.commercializations.add(pharma.commercialization);
        pharma.pathologies?.forEach(p => options.pathologies.add(p));
        pharma.usage_considerations?.forEach(c => options.considerations.add(c));
        pharma.form_name && options.forms.add(pharma.form_name);
        pharma.administration_routes?.forEach(r => options.routes.add(r));
        pharma.concentrations?.forEach(c => options.concentrations.add(c));
    });

    return {
        drugTypes: Array.from(options.drugTypes),
        drugNatures: Array.from(options.drugNatures),
        commercializations: Array.from(options.commercializations),
        pathologies: Array.from(options.pathologies),
        effects: Array.from(options.effects),
        forms: Array.from(options.forms),
        routes: Array.from(options.routes),
        considerations: Array.from(options.considerations),
        concentrations: Array.from(options.concentrations),
    };
}
