<!-- components/ProductCard.svelte -->
<script lang="ts">
    import { ShoppingCart, Tag, Pill, Activity, AlertCircle } from 'lucide-svelte';
    import { productsStore } from '$lib/stores/products';
    import type { BaseProduct, PharmaProduct, ProductActionHandler } from '$lib/api/types';
 

	function getInitials(name: string) {
		return name.split(' ').map((word) => word[0]).join('').toUpperCase();
	}

	function formatPrice(price: number) {
		return new Intl.NumberFormat('en-US', {
			style: 'currency',
			currency: 'MXN'
		}).format(price);
	}

    // Props using Runes
    const { 
        product,
        onAddToCart = (p: BaseProduct, ph?: PharmaProduct) => console.log('Add to cart:', p, ph)
    } = $props<{
        product: BaseProduct;
        onAddToCart?: ProductActionHandler;
    }>();

    // Computed values using derived state
    const pharmaDetails = $derived(product.drug_id ? $productsStore.pharmaDetails.get(product.drug_id) : null);
    const initials = $derived(getInitials(product.product_name));
    const formattedPrice = $derived(formatPrice(product.unit_price));
    const isPharmaProduct = $derived(!!product.pharma_id);
</script>

<!-- Rest of the template remains mostly the same, but simplified -->
<div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
    <div class="card-body">
        <!-- Product Header -->
        <div class="flex items-center gap-4">
            <div class="avatar placeholder">
                <div class="bg-neutral text-neutral-content rounded-full w-12">
                    <span>{initials}</span>
                </div>
            </div>
            
            <div class="flex-1">
                <h2 class="card-title text-lg">
                    {product.product_name}
                    {#if isPharmaProduct}
                        <Pill class="w-4 h-4 text-primary" />
                    {/if}
                </h2>
                <p class="text-sm opacity-60">SKU: {product.sku}</p>
            </div>
        </div>

        <!-- Product Info -->
        {#if product.description}
            <p class="text-sm line-clamp-2 mt-4">{product.description}</p>
        {/if}

        <!-- Pharma Details -->
        {#if isPharmaProduct && pharmaDetails}
            <div class="mt-4 space-y-2">
                <!-- Type and Nature -->
                <div class="flex flex-wrap gap-2">
                    <span class="badge badge-primary">{pharmaDetails.type}</span>
                    <span class="badge badge-secondary">{pharmaDetails.nature}</span>
                    <span class="badge">Class {pharmaDetails.commercialization}</span>
                </div>

                <!-- Form and Concentration -->
                {#if pharmaDetails.form_name}
                    <div class="text-sm">
                        <span class="opacity-60">Form:</span> {pharmaDetails.form_name}
                        {#if pharmaDetails.concentrations?.[0]}
                            - {pharmaDetails.concentrations[0]}
                        {/if}
                    </div>
                {/if}

                <!-- Pathologies -->
                {#if pharmaDetails.pathologies?.length}
                    <div class="flex flex-wrap gap-1">
                        {#each pharmaDetails.pathologies as pathology}
                            <span class="badge badge-outline badge-sm">
                                <Activity class="w-3 h-3 mr-1" />
                                {pathology}
                            </span>
                        {/each}
                    </div>
                {/if}
            </div>
        {/if}

        <!-- Categories -->
        {#if product.category_name}
            <div class="flex gap-2 mt-2">
                <span class="badge badge-outline">
                    <Tag class="w-3 h-3 mr-1" />
                    {product.category_name}
                </span>
            </div>
        {/if}

        <!-- Price and Actions -->
        <div class="card-actions justify-between items-center mt-4">
            <div class="text-xl font-bold">{formattedPrice}</div>
            
            <button 
                class="btn btn-primary btn-sm gap-2"
                onclick={() => onAddToCart(product, pharmaDetails ?? undefined)}
            >
                <ShoppingCart class="w-4 h-4" />
                Add to Cart
            </button>
        </div>
    </div>
</div>
