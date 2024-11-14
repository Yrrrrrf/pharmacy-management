<!-- components/Cart.svelte -->
<script lang="ts">
    import { fade, fly, slide } from 'svelte/transition';
    import { ShoppingCart, X, Plus, Minus, Pill, Package } from 'lucide-svelte';
    import { cartStore, cartTotals } from '$lib/stores/cart';

    // Access store values
    $: items = $cartStore.items;
    $: isOpen = $cartStore.isOpen;
    $: ({ subtotal, tax, total, totalItems } = $cartTotals);

    // Format currency helper
    const formatCurrency = (amount: number) => 
        new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'MXN'
        }).format(amount);
</script>

<div class="relative">
    <!-- Cart Trigger Button -->
    <button class="btn btn-ghost btn-circle"
        on:click={() => cartStore.toggleCart()}
    >
        {#if totalItems > 0}
            <div class="badge badge-error badge-sm absolute -top-2 -right-2 w-5 h-5 p-0 flex items-center justify-center">
                {totalItems}
            </div>
        {/if}
        <ShoppingCart class="h-5 w-5" />
    </button>

    <!-- Cart Modal -->
    {#if isOpen}
        <div
            class="fixed inset-0 bg-black/50 z-50"
            transition:fade={{ duration: 200 }}
            on:click={() => cartStore.closeCart()}
        >
            <!-- Cart Panel -->
            <div
                class="fixed inset-y-0 right-0 w-full sm:max-w-md bg-base-100 shadow-xl flex flex-col"
                transition:fly={{ x: 400, duration: 200 }}
                on:click|stopPropagation
            >
                <!-- Header -->
                <header class="p-6 border-b border-base-300">
                    <div class="flex items-center justify-between">
                        <h2 class="text-2xl font-semibold">Your Cart</h2>
                        <button
                            class="btn btn-ghost btn-sm btn-circle"
                            on:click={() => cartStore.closeCart()}
                        >
                            <X class="h-5 w-5" />
                        </button>
                    </div>
                </header>

                <!-- Cart Items -->
                <div class="flex-1 overflow-auto">
                    <div class="divide-y divide-base-300">
                        {#each items as item (item.id)}
                            <div
                                class="p-6 flex gap-4"
                                transition:slide|local
                            >
                                <!-- Item Image -->
                                <img
                                    src={item.image}
                                    alt={item.name}
                                    class="h-20 w-20 rounded-lg object-cover bg-base-200"
                                />

                                <!-- Item Details -->
                                <div class="flex-1 min-w-0">
                                    <div class="space-y-1">
                                        <h3 class="font-medium truncate pr-2">
                                            {item.name}
                                        </h3>
                                        {item.sku}
                                        <!--
                                        <p class="text-sm text-base-content/60 flex items-center gap-1">
                                            {#if item.isPharma}
                                                <Pill class="h-4 w-4" />
                                                Pharmaceutical
                                            {:else}
                                                <Package class="h-4 w-4" />
                                                Non-Pharmaceutical
                                            {/if}
                                        </p>
                                        -->
                                    </div>

                                    <!-- Quantity Controls -->
                                    <div class="flex items-center gap-2 mt-2">
                                        <button
                                            class="btn btn-ghost btn-sm btn-circle"
                                            on:click={() => cartStore.updateQuantity(item.id, -1)}
                                            disabled={item.quantity <= 1}
                                        >
                                            <Minus class="h-4 w-4" />
                                        </button>
                                        <span class="w-8 text-center">
                                            {item.quantity}
                                        </span>
                                        <button
                                            class="btn btn-ghost btn-sm btn-circle"
                                            on:click={() => cartStore.updateQuantity(item.id, 1)}
                                        >
                                            <Plus class="h-4 w-4" />
                                        </button>
                                    </div>
                                </div>

                                <!-- Price & Remove -->
                                <div class="text-right space-y-1">
                                    <p class="font-medium">
                                        {formatCurrency(item.price * item.quantity)}
                                    </p>
                                    <button
                                        class="btn btn-ghost btn-xs text-error hover:bg-error/10"
                                        on:click={() => cartStore.removeItem(item.id)}
                                    >
                                        Remove
                                    </button>
                                </div>
                            </div>
                        {/each}

                        {#if items.length === 0}
                            <div class="p-6 text-center text-base-content/60">
                                <p>Your cart is empty</p>
                            </div>
                        {/if}
                    </div>
                </div>

                <!-- Footer with Totals -->
                <footer class="p-6 border-t border-base-300 bg-base-200/50">
                    <div class="space-y-4">
                        <!-- Summary -->
                        <div class="space-y-2">
                            <div class="flex justify-between text-base-content/80">
                                <span>Subtotal</span>
                                <span>{formatCurrency(subtotal)}</span>
                            </div>
                            <div class="flex justify-between text-base-content/80">
                                <span>Tax (10%)</span>
                                <span>{formatCurrency(tax)}</span>
                            </div>
                            <div class="flex justify-between text-lg font-bold">
                                <span>Total</span>
                                <span>{formatCurrency(total)}</span>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="space-y-2">
                            <button
                                class="btn btn-primary w-full"
                                disabled={items.length === 0}
                            >
                                Proceed to Checkout
                            </button>
                            <button
                                class="btn btn-ghost btn-sm w-full"
                                on:click={() => cartStore.closeCart()}
                            >
                                Continue Shopping
                            </button>
                        </div>

                        <!-- Additional Info -->
                        {#if items.some(item => item.isPharma)}
                            <p class="text-xs text-base-content/60 text-center">
                                * Some items require a prescription
                            </p>
                        {/if}
                    </div>
                </footer>
            </div>
        </div>
    {/if}
</div>
