<!-- components/FilterBar.svelte -->
<script lang="ts">
    import { Pill, Search, X, Tag } from 'lucide-svelte';
    import { filters, searchQuery } from '$lib/stores/products';
    import type { FilterOptions } from '$lib/stores/products';
    import DrugFilter from '$lib/components/common/store/DrugFilter.svelte';
    import PharmaFilter from '$lib/components/common/store/PharmaFilter.svelte';

    // Props with new FilterOptions type
    const { options } = $props<{ 
        options: FilterOptions 
    }>();

    // Active filter sections using Svelte 5 state
    let activeFilterTypes = $state({ drug: false, pharma: false });

    // Toggle filter sections
    function toggleFilterSection(section: keyof typeof activeFilterTypes) {
        activeFilterTypes[section] = !activeFilterTypes[section];
    }

    // Get active filters using derived state
    const activeFilters = $derived(
        Object.entries($filters).filter(([key, value]) => {
            if (key === 'price') return false;
            return value !== 'all' && value !== '';
        })
    );
    
    // Handle clear filters
    function clearFilters() {
        filters.set({
            name: 'all',
            drugType: 'all',
            drugNature: 'all',
            commercialization: 'all',
            pathology: 'all',
            effect: 'all',
            pharmaceuticForm: 'all',
            administrationRoute: 'all',
            usageConsideration: 'all',
            concentration: '',
            price: '0,10000', // Using your PRICE_RANGE constants
        });
        searchQuery.set('');
    }

    // Remove single filter
    function removeFilter(key: string) {
        filters.update(f => ({
            ...f,
            [key]: 'all'
        }));
    }
</script>

<div class="card w-full bg-base-100 shadow-lg">
    <!-- Header -->
    <div class="card-title p-4 bg-primary text-primary-content flex justify-between items-center">
        <h2 class="flex items-center gap-2">
            <Pill class="h-5 w-5" />
            Pharmaceutical Product Filter
        </h2>
    </div>

    <div class="card-body p-6 space-y-8">
        <!-- Search and Clear Section -->
        <div class="flex gap-4 items-center">
            <div class="form-control flex-1">
                <div class="input-group">
                    <input
                        type="text"
                        placeholder="Search products..."
                        class="input input-bordered w-full"
                        bind:value={$searchQuery}
                    />
                </div>
            </div>
            <button 
                class="btn btn-outline btn-error btn-sm"
                onclick={clearFilters}
            >
                <X class="w-4 h-4 mr-1" />
                Clear Filters
            </button>
        </div>

        <!-- Filter Type Toggles -->
        <div class="flex gap-2">
            <button 
                class="btn btn-sm {activeFilterTypes.drug ? 'btn-primary' : 'btn-ghost'}"
                onclick={() => toggleFilterSection('drug')}
            >
                Drug Properties
            </button>
            <button 
                class="btn btn-sm {activeFilterTypes.pharma ? 'btn-primary' : 'btn-ghost'}"
                onclick={() => toggleFilterSection('pharma')}
            >
                Product Properties
            </button>
        </div>

        <!-- Filter Sections -->
        {#if activeFilterTypes.drug}
            <DrugFilter {options} />
        {/if}
        
        {#if activeFilterTypes.pharma}
            <PharmaFilter {options} />
        {/if}

        <!-- Active Filters -->
        {#if activeFilters.length > 0}
            <div class="bg-base-200 rounded-lg p-4">
                <h4 class="text-sm font-semibold mb-3 flex items-center gap-2">
                    <Tag class="w-4 h-4" />
                    Active Filters
                </h4>
                <div class="flex flex-wrap gap-2">
                    {#each activeFilters as [key, value]}
                        <div class="badge badge-primary gap-1">
                            {key}: {value}
                            <button 
                                class="btn btn-ghost btn-xs"
                                onclick={() => removeFilter(key)}
                            >
                                <X class="w-3 h-3" />
                            </button>
                        </div>
                    {/each}
                </div>
            </div>
        {/if}

        <!-- Footer -->
        <div class="text-center text-sm text-base-content/60 bg-base-200 p-4 rounded-lg mt-4">
            For professional use only. Consult a pharmacist before use.
        </div>
    </div>
</div>
