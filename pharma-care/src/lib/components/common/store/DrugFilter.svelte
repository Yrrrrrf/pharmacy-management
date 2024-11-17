<!-- components/filters/DrugFilter.svelte -->
<script lang="ts">
    import { Package } from 'lucide-svelte';
    import { filters } from '$lib/stores/products';
    import type { FilterOptions } from '$lib/stores/products';
    
    const { options } = $props<{ options: FilterOptions }>();

    // Filter out 'all' values using a helper function
    function filterOptions<T>(arr: T[]): T[] {
        return arr.filter(item => item !== 'all');
    }
</script>

<div class="space-y-4">
    <h3 class="text-lg font-semibold flex items-center gap-2">
        <Package class="h-5 w-5 text-primary" />
        Pharmaceutical Properties
    </h3>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Drug Name Filter -->
        <div class="form-control">
            <label class="label" for="name">
                <span class="label-text">Drug Name</span>
            </label>
            <select 
                id="name" 
                class="select select-bordered w-full" 
                bind:value={$filters.name}
            >
                <option value="all">All Drugs</option>
                {#each filterOptions(options.drugNames) as name}
                    <option value={name}>{name}</option>
                {/each}
            </select>
        </div>

        <!-- Drug Type Filter -->
        <div class="form-control">
            <label class="label" for="drugType">
                <span class="label-text">Drug Type</span>
            </label>
            <select 
                id="drugType" 
                class="select select-bordered w-full" 
                bind:value={$filters.drugType}
            >
                <option value="all">Select Drug Type</option>
                {#each filterOptions(options.drugTypes) as type}
                    <option value={type}>{type}</option>
                {/each}
            </select>
        </div>

        <!-- Drug Nature Filter -->
        <div class="form-control">
            <label class="label" for="drugNature">
                <span class="label-text">Drug Nature</span>
            </label>
            <select 
                id="drugNature"
                class="select select-bordered w-full"
                bind:value={$filters.drugNature}
            >
                <option value="all">Select Drug Nature</option>
                {#each filterOptions(options.drugNatures) as nature}
                    <option value={nature}>{nature}</option>
                {/each}
            </select>
        </div>

        <!-- Commercialization Filter -->
        <div class="form-control">
            <label class="label" for="commercialization">
                <span class="label-text">Commercialization</span>
            </label>
            <select 
                id="commercialization"
                class="select select-bordered w-full"
                bind:value={$filters.commercialization}
            >
                <option value="all">Select Class</option>
                {#each filterOptions(options.commercializations) as comm}
                    <option value={comm}>Class {comm}</option>
                {/each}
            </select>
        </div>

        <!-- Pathology Filter -->
        <div class="form-control">
            <label class="label" for="pathology">
                <span class="label-text">Pathology</span>
            </label>
            <select 
                id="pathology"
                class="select select-bordered w-full"
                bind:value={$filters.pathology}
            >
                <option value="all">Select Pathology</option>
                {#each filterOptions(options.pathologies) as pathology}
                    <option value={pathology}>{pathology}</option>
                {/each}
            </select>
        </div>

        <!-- Effect Filter -->
        <div class="form-control">
            <label class="label" for="effect">
                <span class="label-text">Effect</span>
            </label>
            <select 
                id="effect"
                class="select select-bordered w-full"
                bind:value={$filters.effect}
            >
                <option value="all">Select Effect</option>
                {#each filterOptions(options.effects) as effect}
                    <option value={effect}>{effect}</option>
                {/each}
            </select>
        </div>
    </div>
</div>