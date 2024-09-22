<!-- $lib/components/SchemaAccordion.svelte -->
<script lang="ts">
    import { slide } from 'svelte/transition';
    import TableButtonGrid from './TableButtonGrid.svelte';
    import TableMetadataForm from './TableMetadataForm.svelte';
    import FetchDataButton from './FetchDataButton.svelte';
    import DataTable from './DataTable.svelte';
    import { schemaApiStore } from '$lib/stores';

    let expandedSchemas: Record<string, boolean> = {};
    let activeTable: Record<string, string | null> = {};
    let showDataTable: Record<string, Record<string, boolean>> = {};
    let tableFormData: Record<string, Record<string, Record<string, string>>> = {};

    function toggleSchema(schema: string): void {
        expandedSchemas[schema] = !expandedSchemas[schema];
        expandedSchemas = {...expandedSchemas};
    }

    function setActiveTable(schema: string, table: string): void {
        if (activeTable[schema] === table) {
            activeTable[schema] = null;
        } else {
            activeTable[schema] = table;
        }
        if (!showDataTable[schema]) showDataTable[schema] = {};
        showDataTable[schema][table] = false;
        activeTable = {...activeTable};
        showDataTable = {...showDataTable};
    }

    function handleFetchData(schema: string, table: string): void {
        if (!showDataTable[schema]) showDataTable[schema] = {};
        showDataTable[schema][table] = true;
        showDataTable = {...showDataTable};
    }

    function handleFormUpdate(event: CustomEvent, schema: string, table: string): void {
        if (!tableFormData[schema]) tableFormData[schema] = {};
        tableFormData[schema][table] = event.detail;
        tableFormData = {...tableFormData};
    }
</script>

{#each Object.entries($schemaApiStore.schemas) as [schema, tables]}
    <div class="mb-6 bg-white shadow rounded-lg p-4">
        <button
            class="flex justify-between items-center w-full text-left focus:outline-none"
            on:click={() => toggleSchema(schema)}
        >
            <h2 class="text-xl font-semibold text-gray-800">{schema}</h2>
            <svg
                class="w-5 h-5 transform transition-transform duration-200"
                class:rotate-180={expandedSchemas[schema]}
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
        </button>

        {#if expandedSchemas[schema]}
            <div transition:slide="{{ duration: 300 }}" class="mt-4 space-y-4">
                <TableButtonGrid 
                    tables={Object.keys(tables)} 
                    activeTable={activeTable[schema]} 
                    on:selectTable={(event) => setActiveTable(schema, event.detail)}
                />

                {#each Object.keys(tables) as table}
                    {#if activeTable[schema] === table}
                        <TableMetadataForm 
                            {schema}
                            {table}
                            columns={tables[table]}
                            formData={tableFormData[schema]?.[table] || {}}
                            on:formUpdate={(event) => handleFormUpdate(event, schema, table)}
                        />
                        <FetchDataButton 
                            on:fetch={() => handleFetchData(schema, table)}
                        />
                        {#if showDataTable[schema]?.[table]}
                            <DataTable 
                                {schema} 
                                {table}
                            />
                        {/if}
                    {/if}
                {/each}
            </div>
        {/if}
    </div>
{/each}
