// src/lib/stores/filterStore.ts
import { writable, derived } from 'svelte/store';
import type { ProductDetails } from './inventory';

export interface PriceRange {
    min: number;
    max: number;
}

interface FilterState {
    searchQuery: string;
    priceRange: PriceRange;
    productType: 'all' | 'pharma' | 'normal';
}

const createFilterStore = () => {
    const defaultState: FilterState = {
        searchQuery: '',
        priceRange: { min: 0, max: 1000 },
        productType: 'all'
    };

    const filterState = writable<FilterState>(defaultState);

    return {
        subscribe: filterState.subscribe,
        setSearchQuery: (query: string) => 
            filterState.update(state => ({ ...state, searchQuery: query })),
        setPriceRange: (range: PriceRange) => 
            filterState.update(state => ({ ...state, priceRange: range })),
        setProductType: (type: 'all' | 'pharma' | 'normal') => 
            filterState.update(state => ({ ...state, productType: type })),
        reset: () => filterState.set(defaultState),
    };
};

export const filterStore = createFilterStore();

// Separate function to apply filters
export const createFilteredProductsStore = (products: ProductDetails[]) => {
    return derived(filterStore, $filters => {
        return products.filter(product => {
            // Search query filter
            const searchMatch = !$filters.searchQuery || 
                product.product_name.toLowerCase().includes($filters.searchQuery.toLowerCase()) ||
                product.description?.toLowerCase().includes($filters.searchQuery.toLowerCase()) ||
                product.sku.toLowerCase().includes($filters.searchQuery.toLowerCase());

            // Price range filter
            const price = Number(product.unit_price);
            const priceMatch = price >= $filters.priceRange.min && 
                             price <= $filters.priceRange.max;

            // Product type filter
            const typeMatch = $filters.productType === 'all' || 
                ($filters.productType === 'pharma' && product.pharma_product_id) ||
                ($filters.productType === 'normal' && !product.pharma_product_id);

            return searchMatch && priceMatch && typeMatch;
        });
    });
};
