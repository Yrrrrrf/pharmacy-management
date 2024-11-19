<script lang="ts">
    import { onMount } from 'svelte';
	import { fade } from 'svelte/transition';

	import '../app.css';
	
    import { initializeApi } from '$lib/api';
	import { appName } from '$lib/stores/app';
	import { initTheme } from '$lib/stores/theme';
    import NavBar from '$lib/components/layout/NavBar.svelte';
    import UrlDisplay from '$lib/components/layout/URLDisplay.svelte';
    import Footer from '$lib/components/layout/Footer.svelte';
	// import UiShowcase from '$lib/components/layout/UIShowcase.svelte';

	let { children } = $props();  // children is a special prop that holds the nested routes

	onMount(() => {
		initializeApi();
		initTheme();
	});	
</script>

<svelte:head>
    <title>{$appName}</title>
    <meta name="application-name" content={$appName} />
</svelte:head>

<!-- <UiShowcase /> -->

<div class="flex flex-col min-h-screen bg-base-100">
	<NavBar />
	<UrlDisplay />
	<div class="bg-gradient-to-br from-base-200 to-base-300">
		<main class="flex-grow" in:fade={{ duration: 150, delay: 150 }} out:fade={{ duration: 150 }} >
			{@render children()}
		</main>
	</div>
	<Footer />
</div>
