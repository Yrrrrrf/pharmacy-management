<script lang="ts">
    import { onMount, afterUpdate } from 'svelte';
    import { fade, fly } from 'svelte/transition';
    import { spring } from 'svelte/motion';
    import '../app.postcss';
    import NavBar from '$lib/components/NavBar.svelte';
    import UrlDisplay from '$lib/components/URLDisplay.svelte';

    const services = [
        { name: 'School', href: '/school' },
        { name: 'Academic', href: '/academic' },
        { name: 'Library', href: '/library' },
        { name: 'Infrastructure', href: '/infrastructure' },
        { name: 'HR', href: '/hr' },
    ];

    let bgImg = '';
    let scrollY: number;
    let innerHeight: number;
    let innerWidth: number;

    const parallaxIntensity = spring(0, {
        stiffness: 0.1,
        damping: 0.3
    });

    $: parallaxY = $parallaxIntensity * -0.2;

    onMount(() => {
        bgImg = `academic/school-0${Math.floor(Math.random() * 4) + 1}.jpg`;
    });

    afterUpdate(() => {
        parallaxIntensity.set(scrollY);
    });

    let isLoaded = false;
    onMount(() => {
        setTimeout(() => {
            isLoaded = true;
        }, 100);
    });
</script>

<svelte:window bind:scrollY bind:innerHeight bind:innerWidth />

<div class="flex flex-col min-h-screen bg-base-200 relative overflow-hidden">
    <div 
        class="absolute inset-0 bg-cover bg-center bg-no-repeat opacity-15 transition-opacity duration-1000"
        style="background-image: url('{bgImg}'); transform: translateY({parallaxY}px);"
    ></div>

    <div class="absolute inset-0 bg-gradient-to-b from-transparent to-base-200 opacity-50"></div>

    <div class="relative z-10 flex flex-col min-h-screen">
        {#if isLoaded}
            <div in:fly="{{ y: -50, duration: 1000, delay: 300 }}">
                <NavBar {services} />
            </div>
        {/if}

        <main class="flex-grow container mx-auto px-4 py-8">
            {#if isLoaded}
                <div in:fade="{{ duration: 1000, delay: 600 }}">
                    <slot />
                </div>
            {/if}
        </main>

        <UrlDisplay />

        {#if isLoaded}
            <footer 
                class="bg-neutral text-neutral-content"
                in:fly="{{ y: 50, duration: 1000, delay: 900 }}"
            >
                <div class="container mx-auto px-4 py-6 text-center">
                    <p>&copy; 2024 Academic Hub. All rights reserved.</p>
                </div>
            </footer>
        {/if}
    </div>

</div>

<style>
    :global(body) {
        font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    @keyframes gradientAnimation {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    :global(.bg-gradient-animated) {
        background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
        background-size: 400% 400%;
        animation: gradientAnimation 15s ease infinite;
    }
</style>
