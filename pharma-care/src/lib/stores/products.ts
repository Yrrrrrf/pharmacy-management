import { writable, derived } from 'svelte/store';
import { defaultApiClient } from '$lib/api/client';
import type { BaseProduct, FilterOptions } from '$lib/api/types';

interface ProductsState {
    items: BaseProduct[];
    isLoading: boolean;
    error: string | null;
    lastUpdated: Date | null;
}

function createProductsStore() {
    const initialState: ProductsState = {
        items: [],
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
                update(state => ({
                    ...state,
                    items: products,
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
        reset: () => set(initialState)
    };
}

export const productsStore = createProductsStore();

export const initialFilters: FilterOptions = {
    drugType: 'all',
    drugNature: 'all',
    commercialization: 'all',
    pathology: 'all',
    effect: 'all',
    pharmaceuticForm: 'all',
    administrationRoute: 'all',
    usageConsideration: 'all'
};

export const searchQuery = writable('');
export const filters = writable(initialFilters);

// Derived store for filtered products
export const filteredProducts = derived(
    [productsStore, searchQuery, filters],
    ([$products, $searchQuery, $filters]) => {
        return $products.items.filter(product => {
            const matchesSearch = !$searchQuery || 
                product.product_name.toLowerCase().includes($searchQuery.toLowerCase());
            
            const matchesType = $filters.drugType === 'all' || 
                product.drug_type === $filters.drugType;
            
            return matchesSearch && matchesType;
        });
    }
);