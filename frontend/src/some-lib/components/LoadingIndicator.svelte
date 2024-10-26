<!-- $lib/components/LoadingIndicator.svelte -->
<script lang="ts">
    export let message = 'Loading...';
</script>

<div class="flex justify-center items-center">
    <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
    <span class="ml-3 text-gray-700">{message}</span>
</div>