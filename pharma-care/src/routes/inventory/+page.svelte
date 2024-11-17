<!-- routes/inventory/+page.svelte -->
<script lang="ts">
    import DrugTable from "./DrugTable.svelte";
    import { onMount } from "svelte";
    import { inventoryStore } from "$lib/stores/inventory";
    import { CircleOff, AlertCircle, Loader2 } from 'lucide-svelte';
    
    // State management using Runes
    let expandedDrugId = $state<string | null>(null);
    let searchQuery = $state("");

    // Filtered drugs
    const filteredDrugs = $derived(
        // todo: Improve the search query to include more fields
        $inventoryStore.drugs.filter(drug => 
            drug.drug_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            drug.pathologies.some(p => p.toLowerCase().includes(searchQuery.toLowerCase())) ||
            drug.drug_id.toLowerCase().includes(searchQuery.toLowerCase()) ||
            drug.drug_nature.toLowerCase().includes(searchQuery.toLowerCase()) ||
            drug.drug_type.toLowerCase().includes(searchQuery.toLowerCase())
        )
    );

    // Enhanced toggle function
    const toggleAccordion = (drugId: string) => {
        expandedDrugId = expandedDrugId === drugId ? null : drugId;
    };

    // Keyboard event handler
    const handleKeydown = (event: KeyboardEvent, drugId: string) => {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            toggleAccordion(drugId);
        }
    };

    // Fetch data on mount
    onMount(() => {
        inventoryStore.fetchDrugs();
    });
</script>

<div class="min-h-screen bg-base-200 p-4">
    <header class="mb-6">
        <h1 class="text-3xl font-bold mb-2">Inventory</h1>
        <div class="flex gap-4 items-center">
            <div class="form-control flex-1">
                <input 
                    type="text" 
                    placeholder="Search drugs..." 
                    class="input input-bordered w-full"
                    bind:value={searchQuery}
                />
            </div>
        </div>
    </header>

    {#if $inventoryStore.isLoading}
        <div class="flex justify-center items-center h-64">
            <Loader2 class="w-8 h-8 animate-spin text-primary"/>
        </div>
    {:else if $inventoryStore.error}
        <div class="alert alert-error">
            <AlertCircle class="w-5 h-5" />
            <span>{$inventoryStore.error}</span>
        </div>
    {:else if filteredDrugs.length === 0}
        <div class="flex flex-col items-center justify-center h-64 text-base-content/70">
            <CircleOff class="w-16 h-16 mb-4" />
            <p class="text-lg">No drugs found</p>
        </div>
    {:else}
        <div class="space-y-2">
            {#each filteredDrugs as drug}
                <div class="bg-base-100 shadow rounded-lg">
                    <button
                        type="button"
                        class="w-full flex items-center justify-between p-4 hover:bg-base-300 transition-all duration-200"
                        onclick={() => toggleAccordion(drug.drug_id)}
                        onkeydown={(e) => handleKeydown(e, drug.drug_id)}
                        aria-expanded={expandedDrugId === drug.drug_id}
                        aria-controls="drug-content-{drug.drug_id}"
                    >
                        <div class="flex flex-col items-start">
                            <span class="text-lg font-semibold">{drug.drug_name}</span>
                            <span class="text-sm text-base-content/70">
                                <!-- todo: Look on th best metadata to show on the card... -->
                                {drug.variants.length} variants • {drug.drug_id}
                                <!-- {drug.variants.length} variants • {drug.pathologies.join(', ')} -->
                            </span>
                        </div>
                        
                        <div class="flex items-center gap-2">
                            {#if drug.requires_prescription}
                                <span class="badge badge-warning">Rx</span>
                            {/if}
                            <svg
                                xmlns="http://www.w3.org/2000/svg"
                                class="w-5 h-5 transform transition-transform duration-200"
                                class:rotate-180={expandedDrugId === drug.drug_id}
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M19 9l-7 7-7-7"
                                />
                            </svg>
                        </div>
                    </button>

                    {#if expandedDrugId === drug.drug_id}
                        <DrugTable {drug} />
                    {/if}
                </div>
            {/each}
        </div>
    {/if}
</div>
