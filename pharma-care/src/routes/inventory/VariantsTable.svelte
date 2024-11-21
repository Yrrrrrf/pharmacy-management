<script lang="ts">
    import { onMount } from 'svelte';
    import { Package2, AlertCircle, History, Edit2, Plus, Minus } from 'lucide-svelte';
    import type { ProductDetails, DrugVariant } from '$lib/stores/inventory';
    import { variantDetailsStore, getStockStatusClass } from '$lib/stores/inventory';
    import { formatCurrency } from '$lib/stores/cart';

    // Props using Runes
    const { variants } = $props<{
        variants: DrugVariant[];
    }>();

    // Subscribe to the variantDetailsStore
    const variantStoreData = $derived($variantDetailsStore);
    const variantDetails = $derived(variantStoreData.details);
    const loadingStates = $derived(variantStoreData.loadingStates);
    const errors = $derived(variantStoreData.errors);

    // State management using Runes
    let activeDropdown = $state<string | null>(null);
    let editingStock = $state<string | null>(null);

    function formatDate(date: string | null): string {
        if (!date) return 'N/A';
        return new Date(date).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    function getExpirationClass(date: string | null): string {
        if (!date) return 'text-base-content/70';

        const expirationDate = new Date(date);
        const today = new Date();
        const monthsUntilExpiration = (expirationDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24 * 30);
        
        if (monthsUntilExpiration <= 1) return 'text-error font-bold';
        if (monthsUntilExpiration <= 3) return 'text-warning font-bold';
        if (monthsUntilExpiration <= 6) return 'text-info';
        return 'text-base-content/70';
    }

    // Restock handler with product details
    const handleRestock = (details: ProductDetails) => {
        const message = `Restocking ${details.product_name}\n` +
                        `SKU: ${details.sku}\n` +
                        `Current Stock: ${details.total_stock}\n` +
                        `Latest Expiration: ${formatDate(details.latest_expiration)}`;
        alert(message);
    };

    onMount(() => {
        for (const variant of variants) {  // Fetch details for all variants on mount
            variantDetailsStore.fetchVariantDetails(variant.id);
            console.log(`Fetching details for variant ${variant.id}`);
        }
    });
</script>

<div class="overflow-x-auto">
    <table class="table table-zebra w-full">
        <thead>
            <tr>
                <th>Product Info</th>
                <th>Stock</th>
                <th>Price</th>
                <th>Expiration</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            {#each variants as variant}
                {@const details = variantDetails[variant.id]}
                {@const isLoading = loadingStates[variant.id]}
                {@const error = errors[variant.id]}
                
                <tr class="hover">
                    <td class="max-w-md">
                        {#if isLoading}
                            <div class="animate-pulse bg-base-300 h-8 w-48 rounded"></div>
                        {:else if error}
                            <div class="text-error flex items-center gap-2">
                                <AlertCircle class="w-4 h-4" />
                                <span>{error}</span>
                            </div>
                        {:else if details}
                            <div class="flex flex-col">
                                <span class="font-medium">{details.product_name}</span>
                                <span class="text-xs text-base-content/70">SKU: {details.sku}</span>
                            </div>
                        {/if}
                    </td>

                    <td>
                        {#if details && !isLoading}
                            <div class="flex items-center gap-2">
                                {#if editingStock === details.product_id}
                                    <div class="join">
                                        <input 
                                            type="number" 
                                            class="join-item input input-bordered input-xs w-20 text-center"
                                            bind:value={details.total_stock}
                                            min="0"
                                        />
                                    </div>
                                    <div class="join">
                                        <button 
                                            class="btn btn-xs btn-success join-item"
                                            onclick={() => editingStock = null}
                                        >
                                            Save
                                        </button>
                                        
                                        <button 
                                            class="btn btn-xs btn-error join-item"
                                            onclick={() => editingStock = null}
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                {:else}
                                    <span class="badge {getStockStatusClass(details.total_stock)} w-24 h-6">
                                        {details.total_stock} units
                                    </span>
                                    <button 
                                        class="btn btn-xs btn-ghost"
                                        onclick={() => editingStock = editingStock === details.product_id ? null : details.product_id}
                                    >
                                        <Edit2 class="w-3 h-3" />
                                    </button>
                                {/if}
                            </div>
                        {/if}
                    </td>

                    <td>
                        {#if details && !isLoading}
                            <div class="flex items-center gap-2 font-mono">
                                {formatCurrency(parseFloat(details.unit_price))}
                            </div>
                        {/if}
                    </td>

                    <td>
                        {#if details && !isLoading}
                            <div class="flex items-center gap-2 {getExpirationClass(details.latest_expiration)}">
                                <History class="w-4 h-4" />
                                {formatDate(details.latest_expiration)}
                                {#if details.latest_expiration}
                                    {@const monthsLeft = Math.ceil((new Date(details.latest_expiration).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24 * 30))}
                                    {#if monthsLeft <= 3}
                                        <span class="text-xs">
                                            ({monthsLeft} {monthsLeft === 1 ? 'month' : 'months'} left)
                                        </span>
                                    {/if}
                                {/if}
                            </div>
                        {/if}
                    </td>

                    <td>
                        <div class="flex gap-2">
                            <button 
                                class="btn btn-sm btn-success"
                                disabled={isLoading || !details || (details.total_stock > 20)}
                                onclick={() => details && handleRestock(details)}
                            >
                                <Package2 class="w-4 h-4" />
                                Re-Stock
                            </button>
                            
                            <div class="dropdown dropdown-end">
                                <button 
                                    class="btn btn-sm btn-ghost"
                                    disabled={isLoading || !details}
                                    onclick={() => details && (activeDropdown = activeDropdown === details.product_id ? null : details.product_id)}
                                    aria-expanded={activeDropdown === details?.product_id}
                                >
                                    •••
                                </button>
                                {#if activeDropdown === details?.product_id}
                                    <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                                        <!-- <li><a href={`/inventory/products/${details.product_id}`}>View Details</a></li> -->
                                        <li><a href={`/inventory/sales/${details.product_id}`}>Stock History</a></li>
                                        <li><a href={`/inventory/purchases/${details.product_id}`}>Purchase Orders</a></li>
                                    </ul>
                                {/if}
                            </div>
                        </div>
                    </td>
                </tr>
            {/each}
        </tbody>
    </table>
</div>
