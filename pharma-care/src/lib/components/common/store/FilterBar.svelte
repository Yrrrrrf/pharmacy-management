<!-- src/lib/components/FilterBar.svelte -->
<script lang="ts">
    import { slide } from 'svelte/transition';
    import { filterStore } from '$lib/stores/filter';
    import { Search, Pill, Package, X, SlidersHorizontal } from 'lucide-svelte';
    import { onMount } from 'svelte';
    
    // Local state
    let searchInput = $state('');
    let minPrice = $state(0);
    let maxPrice = $state(1000);
    let isExpanded = $state(false);
    let activeFiltersCount = $state(0);

    // Update search with debounce
    let searchTimeout: ReturnType<typeof setTimeout>;
    function handleSearch() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            filterStore.setSearchQuery(searchInput);
            updateActiveFiltersCount();
        }, 300);
    }

    // Handle price range changes
    function handlePriceChange() {
        filterStore.setPriceRange({ min: minPrice, max: maxPrice });
        updateActiveFiltersCount();
    }

    // Product type selection
    let productTypes = [
        { id: 'all', label: 'All Products', icon: Package },
        { id: 'pharma', label: 'Pharmaceutical', icon: Pill },
        { id: 'normal', label: 'Regular Items', icon: Package }
    ];

    function selectProductType(type: 'all' | 'pharma' | 'normal') {
        filterStore.setProductType(type);
        updateActiveFiltersCount();
    }

    function updateActiveFiltersCount() {
        let count = 0;
        if (searchInput) count++;
        if (minPrice > 0 || maxPrice < 1000) count++;
        if ($filterStore.productType !== 'all') count++;
        activeFiltersCount = count;
    }

    function resetFilters() {
        searchInput = '';
        minPrice = 0;
        maxPrice = 1000;
        filterStore.reset();
        updateActiveFiltersCount();
    }

    // Initialize
    onMount(() => {
        updateActiveFiltersCount();
    });
</script>

<div class="bg-base-100 rounded-xl shadow-lg p-4 mb-6">
    <!-- Main Search and Expand -->
    <div class="flex items-center gap-4">
        <!-- Search Bar -->
        <div class="flex-1 relative">
            <input
                type="text"
                placeholder="Search products..."
                class="input input-bordered w-full pl-10"
                bind:value={searchInput}
                oninput={handleSearch}
            />
            <Search class="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 opacity-50" />
        </div>

        <!-- Active Filters Count -->
        {#if activeFiltersCount > 0}
            <div class="badge badge-primary">{activeFiltersCount} active</div>
        {/if}

        <!-- Expand/Collapse Button -->
        <button 
            class="btn btn-ghost btn-circle"
            onclick={() => isExpanded = !isExpanded}
        >
            <SlidersHorizontal class="w-5 h-5" />
        </button>
    </div>

    <!-- Expanded Filters -->
    {#if isExpanded}
        <div class="mt-4 space-y-4" transition:slide>
            <!-- Product Type Selection -->
            <div class="flex flex-col gap-2">
                <label class="text-sm font-medium opacity-75">Product Type</label>
                <div class="flex flex-wrap gap-2">
                    {#each productTypes as {id, label, icon: Icon}}
                        <button
                            class="btn btn-sm {$filterStore.productType === id ? 'btn-primary' : 'btn-ghost'}"
                            onclick={() => selectProductType(id as 'all' | 'pharma' | 'normal')}
                        >
                            <svelte:component this={Icon} class="w-4 h-4" />
                            {label}
                        </button>
                    {/each}
                </div>
            </div>

            <!-- Price Range -->
            <div class="flex flex-col gap-2">
                <label class="text-sm font-medium opacity-75">Price Range</label>
                <div class="flex items-center gap-4">
                    <input
                        type="number"
                        class="input input-bordered input-sm w-24"
                        bind:value={minPrice}
                        onchange={handlePriceChange}
                        min="0"
                        max={maxPrice}
                        placeholder="Min"
                    />
                    <div class="text-sm opacity-50">to</div>
                    <input
                        type="number"
                        class="input input-bordered input-sm w-24"
                        bind:value={maxPrice}
                        onchange={handlePriceChange}
                        min={minPrice}
                        placeholder="Max"
                    />
                </div>
            </div>

            <!-- Reset Filters -->
            {#if activeFiltersCount > 0}
                <div class="pt-2">
                    <button 
                        class="btn btn-sm btn-ghost text-error"
                        onclick={resetFilters}
                    >
                        <X class="w-4 h-4" />
                        Reset Filters
                    </button>
                </div>
            {/if}
        </div>
    {/if}
</div>
