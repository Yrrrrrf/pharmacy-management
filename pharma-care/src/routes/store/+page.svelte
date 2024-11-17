<!-- store/+page.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    import { Search, Loader2 } from 'lucide-svelte';
    import ProductCard from '$lib/components/common/store/ProductCard.svelte';
    import type { ProductDetails } from '$lib/stores/inventory';
    import { variantDetailsStore, inventoryStore } from '$lib/stores/inventory';
    import { filterStore, createFilteredProductsStore } from '$lib/stores/filter';
    import defaultApiClient from '$lib/api/client';
    import FilterBar from '$lib/components/common/store/FilterBar.svelte';

    // State management using Runes
    let products = $state<ProductDetails[]>([]);
    let isLoading = $state(true);
    let error = $state<string | null>(null);

    // Create filtered products store
    $effect(() => {
        filteredProducts = createFilteredProductsStore(products);
    });
    let filteredProducts = createFilteredProductsStore([]);

    async function loadAllProducts() {
        isLoading = true;
        error = null;
        
        try {
            // Load all products
            const response = await defaultApiClient.request<ProductDetails[]>(
                '/management/v_product_details'
            );
            products = response;

            // Update price range in filter store based on actual product prices
            const prices = response.map(p => Number(p.unit_price));
            const minPrice = Math.min(...prices);
            const maxPrice = Math.max(...prices);
            filterStore.setPriceRange({ min: minPrice, max: maxPrice });

            // Load drug data for pharmaceutical products
            await inventoryStore.fetchDrugs();

            // For pharma products, fetch their variant details
            const pharmaProducts = response.filter(p => p.pharma_product_id !== null);
            if (pharmaProducts.length > 0) {
                await Promise.all(
                    pharmaProducts.map(p => 
                        p.pharma_product_id && 
                        variantDetailsStore.fetchVariantDetails(p.pharma_product_id)
                    )
                );
            }
        } catch (err) {
            console.error('Failed to load products:', err);
            error = err instanceof Error ? err.message : 'Failed to load products';
        } finally {
            isLoading = false;
        }
    }

    // Cleanup on unmount
    onMount(() => {
        loadAllProducts();
        return () => {
            variantDetailsStore.reset();
            filterStore.reset();
        };
    });
</script>

<div class="container mx-auto px-4 py-8">
    <FilterBar />
   
    <!-- Content Section -->
    <section class="mt-8">
        {#if isLoading}
            <div class="flex justify-center items-center min-h-[400px]">
                <Loader2 class="w-12 h-12 animate-spin text-primary" />
            </div>
        {:else if error}
            <div class="alert alert-error">
                <div class="flex-1">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 mx-2" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                    <div>
                        <h3 class="font-bold">Error loading products!</h3>
                        <p class="text-sm">{error}</p>
                    </div>
                </div>
                <button 
                    class="btn btn-sm btn-ghost" 
                    onclick={() => loadAllProducts()}
                >
                    Retry
                </button>
            </div>
        {:else if $filteredProducts.length === 0}
            <div class="text-center py-12">
                <Search class="mx-auto h-12 w-12 text-base-content opacity-20" />
                <h3 class="mt-2 text-lg font-medium">No products found</h3>
                <p class="mt-1 text-base-content opacity-60">
                    Try adjusting your search or filter criteria
                </p>
            </div>
        {:else}
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {#each $filteredProducts as product (product.product_id)}
                    <ProductCard {product} />
                {/each}
            </div>
            
            <div class="mt-4 text-sm text-base-content opacity-70">
                Showing {$filteredProducts.length} of {products.length} products
            </div>
        {/if}
    </section>
</div>
