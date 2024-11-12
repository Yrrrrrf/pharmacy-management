<script lang="ts">
    import { fade, fly, slide } from 'svelte/transition';
    import { appName } from '$lib/stores/app';
    import { ShoppingCart, X, Plus, Minus, Pill, Package } from 'lucide-svelte';

    type CartItem = {
        id: string;
        name: string;
        price: number;
        quantity: number;
        isPharma: boolean;
        image: string;
    };

    let cartItems = $state<CartItem[]>([
        { id: '1', name: 'Ibuprofen 400mg', price: 9.99, quantity: 2, isPharma: true, image: '/api/placeholder/80/80' },
        { id: '2', name: 'Vitamin C 1000mg', price: 14.99, quantity: 1, isPharma: true, image: '/api/placeholder/80/80' },
        { id: '3', name: 'Digital Thermometer', price: 24.99, quantity: 1, isPharma: false, image: '/api/placeholder/80/80' },
        { id: '4', name: 'Allergy Relief Tablets', price: 19.99, quantity: 1, isPharma: true, image: '/api/placeholder/80/80' },
        { id: '5', name: 'First Aid Kit', price: 29.99, quantity: 1, isPharma: false, image: '/api/placeholder/80/80' },
    ]);

    let isOpen = $state(false);

    // Computed values
    const totalItems = $derived(cartItems.reduce((sum, item) => sum + item.quantity, 0));
    const subtotal = $derived(cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0));
    const tax = $derived(subtotal * 0.1);
    const total = $derived(subtotal + tax);

    // Cart operations
    function removeItem(id: string) {
        cartItems = cartItems.filter(item => item.id !== id);
    }

    function updateQuantity(id: string, change: number) {
        cartItems = cartItems.map(item =>
            item.id === id ? { ...item, quantity: Math.max(0, item.quantity + change) } : item
        );
    }
</script>

<!-- Cart Trigger Button -->
<div class="relative">
    <button 
        class="relative btn btn-outline btn-circle"
        onclick={() => isOpen = true}
    >
        <ShoppingCart class="h-5 w-5" />
        <span class="badge badge-error badge-sm absolute -top-2 -right-2 h-5 w-5 rounded-full flex items-center justify-center">
            {totalItems}
        </span>
    </button>

    <!-- Cart Sheet -->
    {#if isOpen}
        <div class="fixed inset-0 bg-black/50 z-50" transition:fade>
            <div 
                class="fixed inset-y-0 right-0 w-full sm:max-w-md bg-base-100 shadow-xl flex flex-col"
                transition:fly={{ x: 20, duration: 200 }}
            >
                <!-- Header -->
                <div class="p-6 border-b">
                    <div class="flex justify-between items-center">
                        <h2 class="text-2xl font-semibold">Your Cart</h2>
                        <button 
                            class="btn btn-ghost btn-sm btn-circle"
                            onclick={() => isOpen = false}
                        >
                            <X class="h-5 w-5" />
                        </button>
                    </div>
                </div>

                <!-- Cart Items -->
                <div class="flex-1 overflow-auto p-6">
                    <div class="space-y-4">
                        {#each cartItems as item (item.id)}
                            <div class="flex items-center gap-4 py-4 border-b border-base-300"
                                 transition:slide|local>
                                <img 
                                    src={item.image} 
                                    alt={item.name} 
                                    class="h-20 w-20 object-cover rounded-lg" 
                                />
                                
                                <div class="flex-1 space-y-1">
                                    <h3 class="font-medium">{item.name}</h3>
                                    <p class="text-sm text-base-content/60 flex items-center">
                                        {#if item.isPharma}
                                            <Pill class="h-4 w-4 mr-1" />
                                            Pharmaceutical
                                        {:else}
                                            <Package class="h-4 w-4 mr-1" />
                                            Non-Pharmaceutical
                                        {/if}
                                    </p>
                                    
                                    <div class="flex items-center gap-2">
                                        <button 
                                            class="btn btn-ghost btn-sm btn-circle"
                                            onclick={() => updateQuantity(item.id, -1)}
                                        >
                                            <Minus class="h-4 w-4" />
                                        </button>
                                        <span class="w-8 text-center">
                                            Qty {item.quantity}
                                        </span>
                                        <button 
                                            class="btn btn-ghost btn-sm btn-circle"
                                            onclick={() => updateQuantity(item.id, 1)}
                                        >
                                            <Plus class="h-4 w-4" />
                                        </button>
                                    </div>
                                </div>

                                <div class="text-right space-y-1">
                                    <p class="font-medium">
                                        ${(item.price * item.quantity).toFixed(2)}
                                    </p>
                                    <button 
                                        class="btn btn-ghost btn-sm text-error hover:bg-error/10"
                                        onclick={() => removeItem(item.id)}
                                    >
                                        Remove
                                    </button>
                                </div>
                            </div>
                        {/each}
                    </div>
                </div>

                <!-- Footer -->
                <div class="p-6 border-t bg-base-100">
                    <div class="space-y-4">
                        <div class="space-y-1.5">
                            <div class="flex justify-between">
                                <span>Subtotal</span>
                                <span>${subtotal.toFixed(2)}</span>
                            </div>
                            <div class="flex justify-between">
                                <span>Tax</span>
                                <span>${tax.toFixed(2)}</span>
                            </div>
                            <div class="flex justify-between font-bold">
                                <span>Total</span>
                                <span>${total.toFixed(2)}</span>
                            </div>
                        </div>
                        <button class="btn btn-primary w-full">
                            Proceed to Checkout
                        </button>
                    </div>
                </div>
            </div>
        </div>
    {/if}
</div>

<style>
    /* Optional: Add any custom styles */
    .cart-item-enter {
        opacity: 0;
        transform: translateX(-20px);
    }
    .cart-item-enter-active {
        opacity: 1;
        transform: translateX(0);
        transition: all 200ms;
    }
    .cart-item-exit {
        opacity: 1;
    }
    .cart-item-exit-active {
        opacity: 0;
        transform: translateX(20px);
        transition: all 200ms;
    }
</style>
