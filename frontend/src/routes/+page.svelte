<script lang="ts">
    import { onMount } from 'svelte';
    import { fade, fly } from 'svelte/transition';
    import { goto } from '$app/navigation';

    interface Feature {
        icon: string;
        title: string;
        description: string;
        route: string;
    }

    const features: Feature[] = [
        {   
            icon: '📚', 
            title: 'Comprehensive Data Management', 
            description: 'Handle student records, courses, and faculty information with ease.',
            route: '/manage'
        },
        {   
            icon: '🎨', 
            title: 'User-friendly Interface', 
            description: 'Intuitive design for enhanced user experience.',
            route: '/academic'
        },
        {   
            icon: '📊', 
            title: 'Scalable Architecture', 
            description: 'Designed to efficiently manage large volumes of academic data.',
            route: '/some'
        },
    ];

    let visibleFeatures: Feature[] = [];

    onMount(() => {
        const interval = setInterval(() => {
            if (visibleFeatures.length < features.length) {
                visibleFeatures = [...visibleFeatures, features[visibleFeatures.length]];
            } else {clearInterval(interval);}
        }, 500);
    });

    function navigateTo(route: string) {
        goto(route);
    }
</script>

<div class="text-center mb-16" in:fade={{ duration: 1000 }}>
    <h1 class="text-5xl font-extrabold text-primary mb-4">Welcome to Academic Hub</h1>
    <p class="text-2xl text-secondary font-light">Empowering educational institutions with cutting-edge data management</p>
</div>

<h2 class="text-3xl font-bold text-center mb-8">Features</h2>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
    {#each visibleFeatures as feature, i (feature.title)}
        <button
            class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow duration-300 cursor-pointer"
            on:click={() => navigateTo(feature.route)}
            in:fly={{ y: 50, duration: 500, delay: i * 100 }}
        >
            <div class="card-body text-left">
                <span class="text-5xl mb-4">{feature.icon}</span>
                <h3 class="card-title text-accent text-2xl mb-2">{feature.title}</h3>
                <p class="text-base-content/80">{feature.description}</p>
            </div>
        </button>
    {/each}
</div>
