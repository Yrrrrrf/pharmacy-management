<!-- ProductCard.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    import { ShoppingCart, Pill, Info } from 'lucide-svelte';
    import type { ProductDetails, Drug } from '$lib/stores/inventory';
    import { getStockStatusClass, getInitials, variantDetailsStore, inventoryStore } from '$lib/stores/inventory';
    import { cartStore } from '$lib/stores/cart';

    const { product } = $props<{
        product: ProductDetails;
    }>();

    // Local state
    let drug = $state<Drug | null>(null);
    let isLoadingDrug = $state(false);

    // Derived values
    const stockStatusClass = $derived(getStockStatusClass(product.total_stock));
    const isPharmaProduct = $derived(!!product.pharma_product_id);
    const formattedPrice = $derived(`$${Number(product.unit_price).toFixed(2)}`);
    
    // Get underlying values from proxy
    const productSnapshot = $derived({
        id: product.product_id,
        name: product.product_name,
        sku: product.sku,
        description: product.description,
        pharmaId: product.pharma_product_id,
        stock: product.total_stock,
        expiration: product.latest_expiration
    });

    function handleAddToCart() {
        cartStore.addItem(product);
    }

    $effect(() => {
        if (productSnapshot.pharmaId) {
            const drugData = $inventoryStore.drugs.find(drug => 
                drug.variants.some(v => v.id === productSnapshot.pharmaId)
            );
            if (drugData) { drug = {...drugData} }
        }
    });

    onMount(() => {
        if (productSnapshot.pharmaId) {
            isLoadingDrug = true;
            variantDetailsStore.fetchVariantDetails(productSnapshot.pharmaId)
                .finally(() => {isLoadingDrug = false;});
        }
    });
</script>

<div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
    <!-- Top Section - Header -->
    <div class="card-body p-4 gap-4">
        <div class="flex items-center gap-4">
            <div class="avatar placeholder">
                <div class="bg-neutral text-neutral-content rounded-full w-12">
                    <span>{getInitials(productSnapshot.name)}</span>
                </div>
            </div>
            
            <div class="flex-1">
                <h2 class="card-title text-lg">
                    {#if isPharmaProduct}
                        <Pill class="w-4 h-4 text-primary" />
                    {/if}
                    {productSnapshot.name}
                </h2>
                <p class="text-sm opacity-60">SKU: {productSnapshot.sku}</p>
            </div>
        </div>

        <!-- Middle Section - Details -->
        <div class="space-y-2">
            {#if isPharmaProduct && drug}
                <!-- Compact Classification -->
                <div class="flex flex-wrap gap-2">
                    <span class="h-6 badge badge-sm badge-primary">{drug.drug_type}</span>
                    <span class="h-6 badge badge-sm badge-secondary">{drug.drug_nature}</span>
                    <!-- <span class="h-6 badge badge-sm badge-secondary">{}</span> -->
                    <span class="h-6 badge badge-sm badge-accent">
                        {drug.commercialization}
                        {#if drug.requires_prescription}•Rx{/if}
                    </span>
                </div>

                <!-- Pathologies as Pills -->
                {#if drug.pathologies?.length > 0}
                    <div class="flex flex-wrap gap-1">
                        {#each drug.pathologies as pathology}
                            <span class="h-6 badge badge-outline badge-sm">{pathology}</span>
                        {/each}
                    </div>
                {/if}
            {:else if !isPharmaProduct && productSnapshot.description}
                <p class="text-sm opacity-75">{productSnapshot.description}</p>
            {/if}
        </div>
    </div>

    <!-- Bottom Section - Price and Actions -->
    <div class="bg-base-200 p-4 rounded-b-xl flex items-center justify-between">
        <div class="flex items-center gap-2">
            <span class="text-xl font-bold">{formattedPrice}</span>
            
            <div class="tooltip tooltip-right" data-tip={`Current Stock: ${productSnapshot.stock} units`}>
                <Info class="w-4 h-4 opacity-50 cursor-help" />
            </div>
        </div>
        
        <button 
            class="btn btn-primary btn-sm gap-2"
            onclick={handleAddToCart}
            disabled={productSnapshot.stock === 0}
        >
            <ShoppingCart class="w-4 h-4" />
            {productSnapshot.stock === 0 ? 'Out of Stock' : 'Add'}
        </button>
    </div>
</div>