<script lang="ts">
    import { onMount } from 'svelte';
	import { fade } from 'svelte/transition';
	import { initTheme } from '../lib/stores/theme';
	import '../app.css';


	import UiShowcase from '$lib/components/layout/UIShowcase.svelte';
    import Footer from '$lib/components/layout/Footer.svelte';
    import NavBar from '$lib/components/layout/NavBar.svelte';
    import UrlDisplay from '$lib/components/layout/URLDisplay.svelte';
	let { children } = $props();

	let ready = $state(false);

	onMount(() => {
		initTheme();
		ready = true;
	});
	
</script>


<!-- <UiShowcase /> -->

<div class="flex flex-col min-h-screen bg-base-100">
	<NavBar />
	<UrlDisplay />
	{#if ready}
		<main class="flex-grow" in:fade={{ duration: 150, delay: 150 }} out:fade={{ duration: 150 }} >
			{@render children()}
		</main>
	{/if}
	<Footer />
</div>
