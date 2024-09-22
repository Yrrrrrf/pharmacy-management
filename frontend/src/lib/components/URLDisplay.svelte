<script lang="ts">
    import { onMount } from 'svelte';
    import { api_url } from '$lib/stores/app';
    import { Book } from 'lucide-svelte';

    let apiUrl: string;
    let copied = false;

    onMount(() => {api_url.subscribe(value => {apiUrl = value;});});

    function copyToClipboard() {
        navigator.clipboard.writeText(apiUrl);
        copied = true;
        setTimeout(() => copied = false, 2000);
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (event.key === 'Enter' || event.key === ' ') {
            copyToClipboard();
        }
    }

    function goToDocs() {
        window.open(`${apiUrl}/docs`, '_blank');
    }
</script>

<div class="fixed bottom-4 left-4 z-50 flex items-center space-x-2">
    
    <button
        class="bg-primary text-primary-content rounded-lg shadow-lg p-2 flex items-center justify-center transition-all duration-300 hover:bg-primary-focus"
        on:click={goToDocs}
        aria-label="Go to API Documentation"
    >
    <Book size={16} />
    </button>

    <button
        class="bg-base-300 text-base-content rounded-lg shadow-lg p-2 flex items-center space-x-2 transition-all duration-300 hover:bg-base-200"
        on:click={copyToClipboard}
        on:keydown={handleKeyDown}
        aria-label="Copy API URL"
    >
        <span class="text-xs font-mono">{apiUrl}</span>
        {#if copied}<span class="text-xs text-success ml-2">Copied!</span>{/if}
    </button>
    
</div>
