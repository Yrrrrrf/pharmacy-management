<!-- src/lib/components/common/store/FilterPharma.svelte -->
<script lang="ts">
    import { filterStore } from '$lib/stores/filter';
    import { Activity, Stethoscope } from 'lucide-svelte';

    // Pharmaceutical filter options
    const drugTypes = ['Patent', 'Generic'];
    const drugNatures = ['Allopathic', 'Homeopathic'];
    const commercializationLevels = ['I', 'II', 'III', 'IV', 'V', 'VI'];

    export let onFilterChange: () => void;

    function updateFilter(key: string, value: string) {
        filterStore.setPharmaFilter(key as any, 
            $filterStore.pharma[key as keyof typeof $filterStore.pharma] === value ? null : value
        );
        onFilterChange();
    }
</script>

<div class="space-y-4">
    <div class="divider">Pharmaceutical Filters</div>
    
    <!-- Drug Type -->
    <div class="flex flex-col gap-2">
        <label class="text-sm font-medium opacity-75">
            <div class="w-4 h-4 inline-block mr-2" />
            Drug Type
        </label>
        <div class="flex flex-wrap gap-2">
            {#each drugTypes as type}
                <button
                    class="btn btn-sm {$filterStore.pharma.drugType === type ? 'btn-secondary' : 'btn-ghost'}"
                    onclick={() => updateFilter('drugType', type)}
                >
                    {type}
                </button>
            {/each}
        </div>
    </div>

    <!-- Drug Nature -->
    <div class="flex flex-col gap-2">
        <label class="text-sm font-medium opacity-75">
            <Activity class="w-4 h-4 inline-block mr-2" />
            Drug Nature
        </label>
        <div class="flex flex-wrap gap-2">
            {#each drugNatures as nature}
                <button
                    class="btn btn-sm {$filterStore.pharma.drugNature === nature ? 'btn-secondary' : 'btn-ghost'}"
                    onclick={() => updateFilter('drugNature', nature)}
                >
                    {nature}
                </button>
            {/each}
        </div>
    </div>

    <!-- Commercialization Level -->
    <div class="flex flex-col gap-2">
        <label class="text-sm font-medium opacity-75">
            <Stethoscope class="w-4 h-4 inline-block mr-2" />
            Commercialization Level
        </label>
        <div class="flex flex-wrap gap-2">
            {#each commercializationLevels as level}
                <button
                    class="btn btn-sm {$filterStore.pharma.commercialization === level ? 'btn-secondary' : 'btn-ghost'}"
                    onclick={() => updateFilter('commercialization', level)}
                >
                    Level {level}
                </button>
            {/each}
        </div>
    </div>
</div>