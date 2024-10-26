<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    export let tables: string[];
    export let activeTable: string | null;

    const dispatch = createEventDispatcher();

    function selectTable(table: string) {
        dispatch('selectTable', table);
    }
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
    {#each tables as table}
        <button
            on:click={() => selectTable(table)}
            class="p-4 hover:bg-blue-100 text-blue-700 rounded-lg shadow transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
            class:bg-blue-100={activeTable === table}
            class:bg-blue-50={activeTable !== table}
        >
            <span class="font-medium">{table}</span>
        </button>
    {/each}
</div>