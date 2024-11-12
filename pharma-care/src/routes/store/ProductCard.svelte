<!-- components/ProductCard.svelte -->
<script lang="ts">
    import { ShoppingCart, Tag, Pill, Activity } from 'lucide-svelte';
    import { onMount } from 'svelte';
    import type { ProductWithPharma } from '$lib/stores/products';

    const {
        product,
        onAddToCart = (p: ProductWithPharma) => console.log('Add to cart:', p)
    } = $props<{
        product: ProductWithPharma;
        onAddToCart?: (product: ProductWithPharma) => void;
    }>();

    // Get the current product's concentration
    const currentConcentration = $derived(() => {
        if (!product.pharmaDetails?.concentrations) return '';
        return product.pharmaDetails.concentrations[0];
    });


    const formattedPrice = $derived(
        new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'MXN'
        }).format(Number(product.unit_price))
    );

    const initials = $derived(product.product_name.split(' ').map((word: string) => word[0]).join(''));
    const isPharmaProduct = $derived(!!product.pharmaDetails);

    // on mount print the product
    onMount(() => {
        console.log('Product:', product);
    });

</script>

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
                    {#if isPharmaProduct}
                        <Pill class="w-4 h-4 text-primary" />
                        {product.pharmaDetails.drug_name} {currentConcentration()}
                    {/if}
                    {#if !isPharmaProduct}
                        {product.product_name}
                    {/if}
                    </h2>
                <p class="text-sm opacity-60">SKU: {product.sku}</p>
            </div>
        </div>

        <!-- Pharma Details -->
        {#if product.pharmaDetails}
        <div class="mt-4 space-y-2">
            <div class="flex flex-wrap gap-2">
                <span class="badge badge-primary">{product.pharmaDetails.type}</span>
                <span class="badge badge-secondary">{product.pharmaDetails.nature}</span>
                <span class="badge">Class {product.pharmaDetails.commercialization}</span>
            </div>

            <div class="text-sm space-y-1">
                <!-- Form -->
                <div>
                    <span class="opacity-60">Form:</span>
                    <span class="ml-1 font-medium">
                        {product.pharmaDetails.form_name}
                    </span>
                </div>
                
                <!-- Concentration -->
                <div>
                    <span class="opacity-60">Concentration:</span>
                    <span class="ml-1 font-medium">
                        {currentConcentration()}
                    </span>
                </div>
            </div>

            <!-- Pathologies section remains the same -->
            {#if product.pharmaDetails.pathologies?.length}
                <div class="flex flex-wrap gap-1">
                    {#each product.pharmaDetails.pathologies as pathology}
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
                onclick={() => onAddToCart(product)}
            >
                <ShoppingCart class="w-4 h-4" />
                Add to Cart
            </button>
        </div>
    </div>
</div>