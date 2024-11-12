<!-- store/+page.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    import { Search, Loader2 } from 'lucide-svelte';
    import ProductCard from './ProductCard.svelte';
    import FilterBar from './FilterBar.svelte';
    import { productsStore, filteredProducts, getFilterOptions } from '$lib/stores/products';
    import Cart from '../../lib/components/common/store/Cart.svelte';

    async function loadProducts() {
        try {
            await productsStore.loadProducts();
        } catch (error) {
            console.error('Failed to load products:', error);
        }
    }

    // Get filter options from the store using derived computation

    // Get filter options from the store using derived computation
    const filterOptions = $derived(getFilterOptions($productsStore.items));

    onMount(() => {
        loadProducts();
    });
</script>

<div class="container mx-auto px-4 py-8">
    <!-- Pass the derived filter options -->
    <FilterBar options={filterOptions} />
   
    <!-- Content Section -->
    <section class="mt-8">
        {#if $productsStore.isLoading}
            <div class="flex justify-center items-center min-h-[400px]">
                <Loader2 class="w-12 h-12 animate-spin text-primary" />
            </div>
        {:else if $productsStore.error}
            <div class="alert alert-error">
                <div class="flex-1">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 mx-2" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                    </svg>
                    <div>
                        <h3 class="font-bold">Error loading products!</h3>
                        <p class="text-sm">{$productsStore.error}</p>
                    </div>
                </div>
                <button 
                    class="btn btn-sm btn-ghost" 
                    onclick={() => loadProducts()}
                >
                    Retry
                </button>
            </div>
        {:else if $filteredProducts.length === 0}
            <div class="text-center py-12">
                <Search class="mx-auto h-12 w-12 text-base-content opacity-20" />
                <h3 class="mt-2 text-lg font-medium">No products found</h3>
                <p class="mt-1 text-base-content opacity-60">
                    Try adjusting your search or filter criteria.
                </p>
            </div>
        {:else}
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {#each $filteredProducts as product (product.product_id)}
                    <ProductCard {product} />
                {/each}
            </div>
            
            <div class="mt-4 text-sm text-base-content opacity-70">
                Showing {$filteredProducts.length} of {$productsStore.items.length} products
            </div>
        {/if}
    </section>
</div>