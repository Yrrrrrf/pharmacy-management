<script lang="ts">
	import { fade } from 'svelte/transition';
	let { children } = $props();
</script>

<div class="bg-gradient-to-br from-base-200 to-base-300">
    <main class="flex-grow" in:fade={{ duration: 150, delay: 150 }} out:fade={{ duration: 150 }} >
        {@render children()}
    </main>
</div>