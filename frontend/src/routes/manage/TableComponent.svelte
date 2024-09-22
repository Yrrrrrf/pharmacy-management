<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import type { SchemaTypes } from '$lib/api/schema-generator';

    export let schema: string;
    export let table: string;
    export let columns: SchemaTypes[string][string];

    const dispatch = createEventDispatcher();

    let showModal = false;
    let currentOperation: 'POST' | 'GET' | 'PUT' | 'DELETE' | null = null;
    let formData: Record<string, any> = {};

    function handleCrudOperation(operation: 'POST' | 'GET' | 'PUT' | 'DELETE') {
        currentOperation = operation;
        if (operation === 'POST' || operation === 'PUT') {
            formData = Object.keys(columns).reduce((acc, col) => {
                acc[col] = '';
                return acc;
            }, {} as Record<string, any>);
            showModal = true;
        } else if (operation === 'DELETE') {
            if (confirm(`Are you sure you want to delete from ${table}?`)) {
                dispatch('crudOperation', { schema, table, operation });
            }
        } else {
            dispatch('crudOperation', { schema, table, operation });
        }
    }

    function handleSubmit() {
        dispatch('crudOperation', { schema, table, operation: currentOperation, data: formData });
        showModal = false;
    }
</script>

<div class="border-t pt-4">
    <h3 class="text-xl font-medium mb-2 text-gray-700">{table}</h3>
    <div class="flex space-x-2 mb-4">
        <button
                class="btn btn-sm bg-green-500 hover:bg-green-600 text-white transition-colors duration-200"
                on:click={() => handleCrudOperation('POST')}
        >
            POST
        </button>
        <button
                class="btn btn-sm bg-blue-500 hover:bg-blue-600 text-white transition-colors duration-200"
                on:click={() => handleCrudOperation('GET')}
        >
            GET
        </button>
        <button
                class="btn btn-sm bg-orange-500 hover:bg-orange-600 text-white transition-colors duration-200"
                on:click={() => handleCrudOperation('PUT')}
        >
            PUT
        </button>
        <button
                class="btn btn-sm bg-red-500 hover:bg-red-600 text-white transition-colors duration-200"
                on:click={() => handleCrudOperation('DELETE')}
        >
            DELETE
        </button>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead>
            <tr class="bg-gray-100">
                <th class="text-left py-2 px-4 font-semibold text-gray-600">Column</th>
                <th class="text-left py-2 px-4 font-semibold text-gray-600">Type</th>
            </tr>
            </thead>
            <tbody>
            {#each Object.entries(columns) as [column, type]}
                <tr class="border-b hover:bg-gray-50 transition-colors duration-200">
                    <td class="py-2 px-4 text-gray-800">{column}</td>
                    <td class="py-2 px-4 text-gray-600">{type}</td>
                </tr>
            {/each}
            </tbody>
        </table>
    </div>
</div>

{#if showModal}
    <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full" on:click={() => showModal = false}>
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white"
             on:click|stopPropagation>
            <div class="mt-3 text-center">
                <h3 class="text-lg leading-6 font-medium text-gray-900">{currentOperation} {table}</h3>
                <div class="mt-2 px-7 py-3">
                    <form on:submit|preventDefault={handleSubmit}>
                        {#each Object.entries(columns) as [column, _]}
                            <div class="mb-4">
                                <label for={column} class="block text-gray-700 text-sm font-bold mb-2">{column}</label>
                                <input
                                        type="text"
                                        id={column}
                                        bind:value={formData[column]}
                                        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                                />
                            </div>
                        {/each}
                        <div class="items-center px-4 py-3">
                            <button
                                    id="ok-btn"
                                    class="px-4 py-2 bg-blue-500 text-white text-base font-medium rounded-md w-full shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-300"
                                    type="submit"
                            >
                                Submit
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
{/if}
