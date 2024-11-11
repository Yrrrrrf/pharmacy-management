<script lang="ts">
    import { Search, X, Pill, Droplet, ShoppingBag, Stethoscope, Zap, Syringe, Clock, DollarSign, Percent, Calendar } from 'lucide-svelte';
	import Cart from './Cart.svelte';
    
    export let searchQuery = '';
    
    type FilterId = 'drugType' | 'drugNature' | 'commercialization' | 'pathology' | 'effect' | 'pharmaceuticForm' | 'administrationRoute' | 'usageConsideration';
    
    export let filters: Record<FilterId, string> = {
        drugType: 'all',
        drugNature: 'all',
        commercialization: 'all',
        pathology: 'all',
        effect: 'all',
        pharmaceuticForm: 'all',
        administrationRoute: 'all',
        usageConsideration: 'all'
    };

    const pharmaceuticalFilters = [
        { id: 'drugType', label: 'Drug Type', icon: Pill, options: ['Generic', 'Brand Name', 'OTC', 'Prescription'] },
        { id: 'drugNature', label: 'Drug Nature', icon: Droplet, options: ['Allopathic', 'Homeopathic', 'Ayurvedic'] },
        { id: 'pathology', label: 'Pathology', icon: Stethoscope, options: ['Pain', 'Inflammation', 'Bacterial Infections', 'Viral Infections', 'Allergies'] },
        { id: 'effect', label: 'Effect', icon: Zap, options: ['Analgesic', 'Anti-inflammatory', 'Antibiotic', 'Antiviral', 'Antihistamine'] },
        { id: 'commercialization', label: 'Commercialization', icon: ShoppingBag, options: ['Over the Counter', 'Prescription Only', 'Controlled Substance'] },
    ];
    
    const pharmaProductFilters = [
        { id: 'pharmaceuticForm', label: 'Pharmaceutic Form', icon: Droplet, options: ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Cream'] },
        { id: 'usageConsideration', label: 'Usage Consideration', icon: Clock, options: ['With Food', 'Without Food', 'Before Sleep', 'Morning'] },
        { id: 'administrationRoute', label: 'Administration Route', icon: Syringe, options: ['Oral', 'Topical', 'Intravenous', 'Intramuscular', 'Subcutaneous'] },
    ];
    
    let priceRange = [0, 1000];
    let concentration = '';
    let concentrationUnit = '';
    let expirationDate = '';
    
    function clearFilters() {
        searchQuery = '';
        Object.keys(filters).forEach((key) => filters[key as FilterId] = 'all');
        priceRange = [0, 1000];
        concentration = '';
        concentrationUnit = '';
        expirationDate = '';
    }
    
    function handleFilterChange(filterId: FilterId, value: string) {
        filters[filterId] = value;
        filters = { ...filters }; // Trigger reactivity
    }
    
    $: activeFilters = Object.entries(filters).filter(([_, value]) => value !== 'all') as [FilterId, string][];
</script>

<Cart />

<div class="w-full max-w-4xl mx-auto bg-white rounded-lg shadow-lg overflow-hidden border-2 border-blue-600">
    <div class="bg-blue-600 text-white p-4 text-center font-bold text-lg flex items-center justify-center">
        <Pill class="w-6 h-6 mr-2" />
        Pharmaceutical Product Filter
    </div>

    <div class="p-6 bg-gradient-to-b from-blue-100 to-white">
        <div class="mb-4 flex items-center space-x-2">
            <div class="relative flex-grow">
                <input
                    type="text"
                    placeholder="Search products..."
                    bind:value={searchQuery}
                    class="pl-10 pr-4 py-2 w-full rounded-full border-2 border-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
                />
                <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 text-blue-600" />
            </div>
            <button 
                on:click={clearFilters}
                class="rounded-full border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white px-4 py-2 flex items-center"
            >
                <X class="w-4 h-4 mr-2" />
                Clear Filters
            </button>
        </div>
        
        <div class="mb-6">
            <h3 class="text-lg font-semibold mb-3 text-blue-600">Pharmaceutical</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 bg-white p-4 rounded-lg shadow-inner">
                {#each pharmaceuticalFilters as filter}
                    <div class="flex items-center space-x-2">
                        <label for={filter.id} class="text-sm font-medium text-gray-700 w-1/3 flex items-center">
                            <svelte:component this={filter.icon} class="w-4 h-4 mr-2" />
                            <span>{filter.label}:</span>
                        </label>
                        <select 
                            id={filter.id}
                            bind:value={filters[filter.id]}
                            class="w-2/3 p-2 bg-gray-800 text-white border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                            <option value="all">Select {filter.label}</option>
                            {#each filter.options as option}
                                <option value={option}>{option}</option>
                            {/each}
                        </select>
                    </div>
                {/each}
            </div>
        </div>

        <div class="mb-6">
            <h3 class="text-lg font-semibold mb-3 text-blue-600">Pharma Product</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 bg-white p-4 rounded-lg shadow-inner">
                {#each pharmaProductFilters as filter}
                    <div class="flex items-center space-x-2">
                        <label for={filter.id} class="text-sm font-medium text-gray-700 w-1/3 flex items-center">
                            <svelte:component this={filter.icon} class="w-4 h-4 mr-2" />
                            <span>{filter.label}:</span>
                        </label>
                        <select 
                            id={filter.id}
                            bind:value={filters[filter.id]}
                            class="w-2/3 p-2 bg-gray-800 text-white border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                            <option value="all">Select {filter.label}</option>
                            {#each filter.options as option}
                                <option value={option}>{option}</option>
                            {/each}
                        </select>
                    </div>
                {/each}
                <div class="flex items-center space-x-2">
                    <label for="concentration" class="text-sm font-medium text-gray-700 w-1/3 flex items-center">
                        <Percent class="w-4 h-4 mr-2" />
                        Concentration:
                    </label>
                    <div class="w-2/3 flex space-x-2">
                        <input
                            id="concentration"
                            type="text"
                            placeholder="e.g., 500"
                            bind:value={concentration}
                            class="w-2/3 p-2 bg-gray-800 text-white border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                        <select 
                            bind:value={concentrationUnit}
                            class="w-1/3 p-2 bg-gray-800 text-white border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                            <option value="">Unit</option>
                            {#each ['mg', 'mL', 'µg', 'g', 'IU'] as unit}
                                <option value={unit}>{unit}</option>
                            {/each}
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-6">
            <h3 class="text-lg font-semibold mb-3 text-blue-600">Product Specific</h3>
            <div class="grid grid-cols-1 gap-4 bg-white p-4 rounded-lg shadow-inner">
                <div>
                    <label class="text-sm font-medium text-gray-700 flex items-center mb-2">
                        <DollarSign class="w-4 h-4 mr-2" />
                        Price Range:
                    </label>
                    <input type="range" bind:value={priceRange[1]} min="0" max="1000" step="10" class="w-full" />
                    <div class="flex justify-between text-sm text-gray-600">
                        <span>${priceRange[0]}</span>
                        <span>${priceRange[1]}</span>
                    </div>
                </div>
                <div>
                    <label for="expiration-date" class="text-sm font-medium text-gray-700 flex items-center mb-2">
                        <Calendar class="w-4 h-4 mr-2" />
                        Expiration Date:
                    </label>
                    <input
                        id="expiration-date"
                        type="date"
                        bind:value={expirationDate}
                        class="w-full p-2 bg-gray-800 text-white border border-gray-700 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                </div>
            </div>
        </div>
        
        {#if activeFilters.length > 0 || searchQuery || concentration || concentrationUnit || expirationDate || priceRange[1] !== 1000}
            <div class="mt-4 p-4 bg-blue-100 rounded-lg">
                <h3 class="text-sm font-semibold mb-2 flex items-center text-blue-800">
                    <Stethoscope class="w-4 h-4 mr-2" />
                    Active Filters:
                </h3>
                <div class="flex flex-wrap gap-2">
                    {#if searchQuery}
                        <button
                            class="rounded-full bg-blue-200 text-blue-800 hover:bg-blue-300 px-2 py-1 text-sm flex items-center"
                            on:click={() => searchQuery = ''}
                        >
                            Search: {searchQuery}
                            <X class="w-3 h-3 ml-1" />
                        </button>
                    {/if}
                    {#each activeFilters as [filterId, value]}
                        <button
                            class="rounded-full bg-blue-200 text-blue-800 hover:bg-blue-300 px-2 py-1 text-sm flex items-center"
                            on:click={() => handleFilterChange(filterId, 'all')}
                        >
                            {value}
                            <X class="w-3 h-3 ml-1" />
                        </button>
                    {/each}
                    {#if priceRange[1] !== 1000}
                        <button
                            class="rounded-full bg-blue-200 text-blue-800 hover:bg-blue-300 px-2 py-1 text-sm flex items-center"
                            on:click={() => priceRange = [0, 1000]}
                        >
                            Price: ${priceRange[0]} - ${priceRange[1]}
                            <X class="w-3 h-3 ml-1" />
                        </button>
                    {/if}
                    {#if concentration || concentrationUnit}
                        <button
                            class="rounded-full bg-blue-200 text-blue-800 hover:bg-blue-300 px-2 py-1 text-sm flex items-center"
                            on:click={() => { concentration = ''; concentrationUnit = ''; }}
                        >
                            Concentration: {concentration} {concentrationUnit}
                            <X class="w-3 h-3 ml-1" />
                        </button>
                    {/if}
                    {#if expirationDate}
                        <button
                            class="rounded-full bg-blue-200 text-blue-800 hover:bg-blue-300 px-2 py-1 text-sm flex items-center"
                            on:click={() => expirationDate = ''}
                        >
                            Expiration Date: {expirationDate}
                            <X class="w-3 h-3 ml-1" />
                        </button>
                    {/if}
                </div>
            </div>
        {/if}
    </div>

    <div class="bg-blue-600 text-white p-2 text-center text-xs flex items-center justify-center">
        <Syringe class="w-4 h-4 mr-2" />
        For professional use only. Consult a pharmacist before use.
    </div>
</div>