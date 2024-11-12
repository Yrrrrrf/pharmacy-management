// lib/stores/cart.ts
import { writable, derived } from 'svelte/store';
import type { ProductWithPharma } from '$lib/stores/products';

export interface CartItem {
    id: string;
    name: string;
    price: number;
    quantity: number;
    isPharma: boolean;
    image: string;
    product: ProductWithPharma; // Store the full product for reference
}

// const currentConcentration = $derived(() => {
//     if (!product.pharmaDetails?.concentrations) return '';
//     return product.pharmaDetails.concentrations.find(conc => 
//         product.product_name.includes(conc)
//     ) || product.pharmaDetails.concentrations[0];
// // });

function currentConcentration(product: ProductWithPharma): string {
    if (!product.pharmaDetails?.concentrations) return '';
    return product.pharmaDetails.concentrations.find(conc => 
        product.product_name.includes(conc)
    ) || product.pharmaDetails.concentrations[0];
}

interface CartStore {
    items: CartItem[];
    isOpen: boolean;
}

function createCartStore() {
    // Initialize with some demo items
    const initialState: CartStore = {
        items: [
            { 
                id: 'demo-1', 
                name: 'Demo Product', 
                price: 9.99, 
                quantity: 1, 
                isPharma: true,
                image: '/api/placeholder/80/80',
                product: null // Demo product doesn't need original reference
            }
        ],
        isOpen: false
    };

    const { subscribe, set, update } = writable<CartStore>(initialState);

    return {
        subscribe,
        addItem: (product: ProductWithPharma) => {
            console.log('Adding to cart:', { id: product.product_id, name: product.product_name });
            
            update(state => {
                const existingItem = state.items.find(item => item.id === product.product_id);
                
                if (existingItem) {
                    // Update quantity if item exists
                    const updatedItems = state.items.map(item =>
                        item.id === product.product_id
                            ? { ...item, quantity: item.quantity + 1 }
                            : item
                    );
                    return { ...state, items: updatedItems, isOpen: true };
                } else {
                    let pharma_name: string;
                    if (product.pharmaDetails) {
                        pharma_name = `${product.pharmaDetails.drug_name} ${currentConcentration(product)}`.trim();
                    } else {
                        pharma_name = product.product_name;
                    }
                    const newItem: CartItem = {
                        id: product.product_id,
                        name: pharma_name,
                        price: Number(product.unit_price),
                        quantity: 1,
                        isPharma: !!product.pharmaDetails,
                        image: '/api/placeholder/80/80',
                        product
                    };
                    return {
                        ...state,
                        items: [...state.items, newItem],
                        isOpen: true
                    };
                }
            });
        },
        removeItem: (id: string) => {
            update(state => ({
                ...state,
                items: state.items.filter(item => item.id !== id)
            }));
        },
        updateQuantity: (id: string, change: number) => {
            update(state => ({
                ...state,
                items: state.items.map(item =>
                    item.id === id
                        ? { ...item, quantity: Math.max(0, item.quantity + change) }
                        : item
                )
            }));
        },
        toggleCart: () => {
            update(state => ({ ...state, isOpen: !state.isOpen }));
        },
        closeCart: () => {
            update(state => ({ ...state, isOpen: false }));
        }
    };
}

export const cartStore = createCartStore();

// Derived stores for calculations
export const cartTotals = derived(cartStore, ($cart) => {
    const subtotal = $cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const tax = subtotal * 0.1; // 10% tax
    const total = subtotal + tax;
    const totalItems = $cart.items.reduce((sum, item) => sum + item.quantity, 0);

    return { subtotal, tax, total, totalItems };
});
