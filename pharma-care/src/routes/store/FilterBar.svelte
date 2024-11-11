<!-- components/FilterBar.svelte -->
<script lang="ts">
    import { Pill, Search, X } from 'lucide-svelte';
    import { productsStore, filters, searchQuery, PRICE_RANGE, getFilterOptions } from '$lib/stores/products';
    
    // Get filter options
    const options = $derived(getFilterOptions($productsStore));
    
    // Handle clear filters
    function clearFilters() {
        filters.set({
            drugType: 'all',
            drugNature: 'all',
            commercialization: 'all',
            pathology: 'all',
            effect: 'all',
            pharmaceuticForm: 'all',
            administrationRoute: 'all',
            usageConsideration: 'all',
            concentration: '',
            price: `${PRICE_RANGE.MIN},${PRICE_RANGE.MAX}`,
        });
        searchQuery.set('');
    }

    // Price range handling
    let [minPrice, maxPrice] = $derived($filters.price.split(',').map(Number));
</script>

<div class="bg-gradient-to-r from-teal-400 to-cyan-400 p-6 rounded-lg shadow-lg">
    <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white flex items-center gap-2">
            <Pill />
            Pharmaceutical Product Filter
        </h2>
        <button 
            class="btn btn-ghost btn-sm text-white"
            onclick={clearFilters}
        >
            <X class="w-4 h-4 mr-1" />
            Clear Filters
        </button>
    </div>

    <!-- Search Bar -->
    <div class="flex gap-4 mb-6">
        <div class="form-control flex-1">
            <div class="input-group">
                <input
                    type="text"
                    placeholder="Search products..."
                    class="input input-bordered w-full"
                    bind:value={$searchQuery}
                />
                <button class="btn btn-square">
                    <Search class="w-5 h-5" />
                </button>
            </div>
        </div>
    </div>

    <!-- Filter Sections -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Pharmaceutical Section -->
        <div class="space-y-4">
            <h3 class="font-semibold text-white">Pharmaceutical</h3>
            
            <div class="grid grid-cols-2 gap-4">
                <!-- Drug Type -->
                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.drugType}
                    >
                        <option disabled>Drug Type</option>
                        {#each options.drugTypes as type}
                            <option value={type}>{type}</option>
                        {/each}
                    </select>
                </div>

                <!-- Drug Nature -->
                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.drugNature}
                    >
                        <option disabled>Drug Nature</option>
                        {#each options.drugNatures as nature}
                            <option value={nature}>{nature}</option>
                        {/each}
                    </select>
                </div>
            </div>

            <!-- Other pharmaceutical filters -->
            <div class="grid grid-cols-2 gap-4">
                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.pathology}
                    >
                        <option disabled>Select Pathology</option>
                        {#each options.pathologies as pathology}
                            <option value={pathology}>{pathology}</option>
                        {/each}
                    </select>
                </div>

                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.effect}
                    >
                        <option disabled>Select Effect</option>
                        {#each options.effects as effect}
                            <option value={effect}>{effect}</option>
                        {/each}
                    </select>
                </div>
            </div>
        </div>

        <!-- Product Specific Section -->
        <div class="space-y-4">
            <!-- Form and Route -->
            <div class="grid grid-cols-2 gap-4">
                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.pharmaceuticForm}
                    >
                        <option disabled>Form</option>
                        {#each options.forms as form}
                            <option value={form}>{form}</option>
                        {/each}
                    </select>
                </div>

                <div class="form-control">
                    <select 
                        class="select select-bordered w-full"
                        bind:value={$filters.administrationRoute}
                    >
                        <option disabled>Route</option>
                        {#each options.routes as route}
                            <option value={route}>{route}</option>
                        {/each}
                    </select>
                </div>
            </div>

            <!-- Concentration -->
            <div class="form-control">
                <select 
                    class="select select-bordered w-full"
                    bind:value={$filters.concentration}
                >
                    <option value="">Any Concentration</option>
                    {#each options.concentrations as concentration}
                        <option value={concentration}>{concentration}</option>
                    {/each}
                </select>
            </div>
        </div>
    </div>
</div>