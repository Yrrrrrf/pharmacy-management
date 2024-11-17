import { writable, derived } from 'svelte/store';
import type { Writable } from 'svelte/store';
import defaultApiClient from '$lib/api/client';


// ? Some(useful methods for this context...) ------------------------------------------------

export function getStockStatusClass(stock: number): string {
    if (stock === 0) return 'badge-error';
    if (stock < 10) return 'badge-warning';
    return 'badge-success';
}

export function getInitials(name: string): string {
    return name.split(' ').map(word => word[0]).join('');
}

// ? Product details management ---------------------------------------------------------------

export interface ProductDetails {
    product_id: string;
    sku: string;
    product_name: string;
    description: string;
    unit_price: string;
    category_id: string;
    pharma_product_id: string | null;
    total_stock: number;
    latest_expiration: string | null;
}

export function fetchProductDetails(variantId: string): Promise<ProductDetails[]> {
    return defaultApiClient.request<ProductDetails[]>(
        `/management/v_product_details?pharma_product_id=${variantId}`
        // todo: Somehow, change this to add the request using some kind of:
        // todo:     - schema selector (on the client side)
        // todo:     - Notice the API that I'm using query params (instead of the &str way)
    );
}


// ? Drug dt management ----------------------------------------------------------------

export interface DrugVariant {
    id: string;
    form: string;
    concentration: string;
}

export interface Drug {
    drug_id: string;
    drug_name: string;
    drug_type: "Generic" | "Patent";
    drug_nature: "Allopathic" | "Homeopathic";
    commercialization: "I" | "II" | "III" | "IV" | "V" | "VI";
    requires_prescription: boolean;
    pathologies: string[];
    usage_considerations: string[];
    variants: DrugVariant[];
    variant_count: number;
}

interface InventoryState {
    drugs: Drug[];
    isLoading: boolean;
    error: string | null;
}

function createInventoryStore() {
    const { subscribe, set, update }: Writable<InventoryState> = writable({
        drugs: [],
        isLoading: false,
        error: null
    });

    return {
        subscribe,
        
        async fetchDrugs() {
            update(state => ({ ...state, isLoading: true }));
            
            try {
                const drugs = await defaultApiClient.request<Drug[]>('/pharma/v_pharma_details');
                update(state => ({
                    ...state,
                    drugs,
                    isLoading: false,
                    error: null
                }));
            } catch (error) {
                console.error('Error fetching drugs:', error);
                update(state => ({
                    ...state,
                    isLoading: false,
                    error: error instanceof Error ? error.message : 'Failed to fetch drugs'
                }));
            }
        },
    };
}

export const inventoryStore = createInventoryStore();

// Derived stores for filtered views
export const prescriptionDrugs = derived(inventoryStore, 
    $store => $store.drugs.filter(drug => drug.requires_prescription)
);

export const otcDrugs = derived(inventoryStore, 
    $store => $store.drugs.filter(drug => !drug.requires_prescription)
);


// ? Variant details store -------------------------------------------------------------------

export interface VariantDetailsState {
    details: Record<string, ProductDetails | null>;
    loadingStates: Record<string, boolean>;
    errors: Record<string, string>;
}

export interface StockAdjustment {
    productId: string;
    newQuantity: number;
}

function createVariantDetailsStore() {
    const { subscribe, set, update }: Writable<VariantDetailsState> = writable({
        details: {},
        loadingStates: {},
        errors: {}
    });
  
    return {
        subscribe,

        async fetchVariantDetails(variantId: string) {
            update(state => ({...state,
                loadingStates: { ...state.loadingStates, [variantId]: true },
                errors: { ...state.errors, [variantId]: '' }
            }));

            try {
                const response = await defaultApiClient.request<ProductDetails[]>(
                    `/management/v_product_details?pharma_product_id=${variantId}`
                );
                
                update(state => ({...state,
                    details: { ...state.details, [variantId]: response[0] || null }
                }));
            } catch (error) {
                console.error(`Error fetching details for variant ${variantId}:`, error);
                update(state => ({...state,
                    errors: { 
                        ...state.errors, 
                        [variantId]: 'Failed to load product details' 
                    }
                }));
            } finally {
                update(state => ({...state,
                    loadingStates: { ...state.loadingStates, [variantId]: false }
                }));
            }
        },

        async updateStock(adjustment: StockAdjustment) {
            update(state => ({
                ...state,
                details: {
                    ...state.details,
                    [adjustment.productId]: state.details[adjustment.productId] 
                        ? {
                            ...state.details[adjustment.productId]!,
                            total_stock: adjustment.newQuantity
                        }
                        : null
                }
            }));
        },

        reset() {set({ details: {}, loadingStates: {}, errors: {} })}
    };
}

export const variantDetailsStore = createVariantDetailsStore();


// ? Product details store -------------------------------------------------------------------


export interface VariantDetailsState {
    details: Record<string, ProductDetails | null>;
    loadingStates: Record<string, boolean>;
    errors: Record<string, string>;
}

interface ProductState {
    drugMetadata: Record<string, Drug | null>;
    loadingStates: Record<string, boolean>;
    errors: Record<string, string | null>;
}

function createProductStore() {
    const { subscribe, set, update }: Writable<ProductState> = writable({
        drugMetadata: {},
        loadingStates: {},
        errors: {}
    });

    return {
        subscribe,
        
        async fetchDrugMetadata(pharmaProductId: string) {
            update(state => ({
                ...state,
                loadingStates: { ...state.loadingStates, [pharmaProductId]: true },
                errors: { ...state.errors, [pharmaProductId]: null }
            }));
            
            try {
                const response = await defaultApiClient.request<Drug>(
                    `/pharma/v_pharma_details?${pharmaProductId}`
                );
                
                update(state => ({
                    ...state,
                    drugMetadata: { ...state.drugMetadata, [pharmaProductId]: response },
                    loadingStates: { ...state.loadingStates, [pharmaProductId]: false }
                }));
            } catch (error) {
                console.error(`Error fetching drug metadata for ${pharmaProductId}:`, error);
                update(state => ({
                    ...state,
                    errors: { 
                        ...state.errors, 
                        [pharmaProductId]: 'Failed to load pharmaceutical details'
                    },
                    loadingStates: { ...state.loadingStates, [pharmaProductId]: false }
                }));
            }
        },

        clearDrugMetadata(pharmaProductId: string) {
            update(state => ({
                ...state,
                drugMetadata: { ...state.drugMetadata, [pharmaProductId]: null },
                loadingStates: { ...state.loadingStates, [pharmaProductId]: false },
                errors: { ...state.errors, [pharmaProductId]: null }
            }));
        }
    };
}

export const productStore = createProductStore();
