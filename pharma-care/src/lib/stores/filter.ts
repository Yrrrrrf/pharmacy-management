// src/lib/stores/filter.ts
import { writable, derived } from 'svelte/store';
import { inventoryStore, type ProductDetails, type Drug } from './inventory';

interface PriceRange {
    min: number;
    max: number;
}

interface PharmaceuticalFilters {
    drugType: string | null;
    drugNature: string | null;
    pathology: string | null;
    effect: string | null;
    commercialization: string | null;
}

interface FilterState {
    searchQuery: string;
    priceRange: PriceRange;
    productType: 'all' | 'pharma' | 'normal';
    showInStock: boolean;
    pharma: PharmaceuticalFilters;
}

const defaultState: FilterState = {
    searchQuery: '',
    priceRange: { min: 0, max: 1000 },
    productType: 'all',
    showInStock: false,
    pharma: {
        drugType: null,
        drugNature: null,
        pathology: null,
        effect: null,
        commercialization: null,
    },
};

function createFilterStore() {
    const { subscribe, set, update } = writable<FilterState>(defaultState);

    return {
        subscribe,
        setSearchQuery: (query: string) =>
            update((state) => ({ ...state, searchQuery: query })),
        setPriceRange: (range: PriceRange) =>
            update((state) => ({ ...state, priceRange: range })),
        setProductType: (type: 'all' | 'pharma' | 'normal') =>
            update((state) => ({ ...state, productType: type })),
        setPharmaFilter: (
            key: keyof PharmaceuticalFilters,
            value: string | null
        ) =>
            update((state) => ({
                ...state,
                pharma: { ...state.pharma, [key]: value },
            })),
        setStockFilter: (showInStock: boolean) =>
            update((state) => ({ ...state, showInStock })),
        reset: () => set(defaultState),
    };
}

export const filterStore = createFilterStore();

function findDrugForProduct(
    product: ProductDetails,
    drugs: Drug[]
): Drug | undefined {
    if (!product.pharma_product_id) return undefined;
    return drugs.find((drug) =>
        drug.variants.some((variant) => variant.id === product.pharma_product_id)
    );
}

export function createFilteredProductsStore(products: ProductDetails[]) {
    return derived(
        [filterStore, inventoryStore],
        ([$filters, $inventory]) => {
            return products.filter((product) => {
                const searchMatch =
                    !$filters.searchQuery ||
                    product.product_name.toLowerCase().includes(
                        $filters.searchQuery.toLowerCase()
                    ) ||
                    (product.description &&
                        product.description.toLowerCase().includes(
                            $filters.searchQuery.toLowerCase()
                        )) ||
                    product.sku.toLowerCase().includes(
                        $filters.searchQuery.toLowerCase()
                    );

                const priceMatch =
                    Number(product.unit_price) >= $filters.priceRange.min &&
                    Number(product.unit_price) <= $filters.priceRange.max;

                let typeAndPharmaMatch = true;

                if ($filters.productType === 'pharma') {
                    if (!product.pharma_product_id) return false;
                    const drugData = findDrugForProduct(product, $inventory.drugs);
                    if (!drugData) return false;

                    if (
                        $filters.pharma.drugType &&
                        drugData.drug_type !== $filters.pharma.drugType
                    ) {
                        return false;
                    }

                    if (
                        $filters.pharma.drugNature &&
                        drugData.drug_nature !== $filters.pharma.drugNature
                    ) {
                        return false;
                    }

                    if (
                        $filters.pharma.commercialization &&
                        drugData.commercialization !== $filters.pharma.commercialization
                    ) {
                        return false;
                    }

                    if (
                        $filters.pharma.pathology &&
                        !drugData.pathologies.includes($filters.pharma.pathology)
                    ) {
                        return false;
                    }
                } else if ($filters.productType === 'normal') {
                    typeAndPharmaMatch = !product.pharma_product_id;
                }

                const stockMatch = !$filters.showInStock || product.total_stock > 0;

                return searchMatch && priceMatch && typeAndPharmaMatch && stockMatch;
            });
        }
    );
}
