<script lang="ts">
    import type { Drug } from '$lib/stores/inventory';
    import VariantsTable from './VariantsTable.svelte';

    const { drug } = $props<{
        drug: Drug;
    }>();

    let metadata = {
        type: drug.drug_type,
        nature: drug.drug_nature,
        commercialization: drug.commercialization,
        pathologies: drug.pathologies.join(", "),
        usage_considerations: drug.usage_considerations.join(", ") || "None"
    }

</script>

<div class="flex flex-col lg:flex-row bg-base-200 p-4 rounded-lg shadow-md">
    <!-- Left Section: Drug Overview -->
    <div class="w-full lg:w-1/3 p-4 border-r border-base-300">
        <!-- Drug Header -->
        <div class="mt-4 space-y-2 text-sm">
            {#each Object.entries(metadata) as [key, value]}
                <div class="flex justify-between">
                    <strong>{key.replace("_", " ").toUpperCase()}:</strong> {value}
                </div>
            {/each}
        </div>
    </div>

    <!-- Right Section: Variants Table -->
    <VariantsTable variants={drug.variants} />
</div>
