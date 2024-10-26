<!-- $lib/components/TableMetadataForm.svelte -->
<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    export let schema: string;
    export let table: string;
    export let columns: Record<string, string>;
    export let formData: Record<string, string> = {};

    const dispatch = createEventDispatcher();

    function handleInputChange(event: Event, column: string): void {
        const value = (event.target as HTMLInputElement).value;
        formData[column] = value;
        formData = {...formData};
        dispatch('formUpdate', formData);
    }
</script>

<div>
    <h3 class="text-lg font-semibold mb-2">{table} Metadata</h3>
    <table class="w-full bg-white shadow-sm rounded-lg overflow-hidden">
        <thead class="bg-gray-50">
            <tr>
                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/4">Column Name</th>
                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/4">Type</th>
                <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Value</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
            {#each Object.entries(columns) as [columnName, columnType]}
                <tr>
                    <td class="px-4 py-2 whitespace-nowrap text-sm font-medium text-gray-900">{columnName}</td>
                    <td class="px-4 py-2 whitespace-nowrap text-sm text-gray-500 italic">{columnType}</td>
                    <td class="px-4 py-2">
                        <input
                            type="text"
                            class="w-full px-2 py-1 border rounded-md"
                            value={formData[columnName] || ''}
                            on:input={(e) => handleInputChange(e, columnName)}
                        />
                    </td>
                </tr>
            {/each}
        </tbody>
    </table>
</div>
