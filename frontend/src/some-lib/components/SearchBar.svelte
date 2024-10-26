<!-- src/lib/components/SearchBar.svelte -->
<script lang="ts">
    import { createEventDispatcher } from 'svelte';

// Create an event dispatcher
    const dispatch = createEventDispatcher<{search: string}>();

    // Bind the search query to this variable
    let searchQuery = '';

    // Function to handle the search submission
    function handleSearch() {
        // Dispatch the search event with the current query
        dispatch('search', searchQuery);
        // Optionally clear the search query after dispatching
        // searchQuery = '';
    }
</script>

<form on:submit|preventDefault={handleSearch} class="relative">
    <input
        type="text"
        placeholder="Search..."
        bind:value={searchQuery}
        class="input input-bordered w-full max-w-xs pr-10"
    />
    <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
    </button>
</form>