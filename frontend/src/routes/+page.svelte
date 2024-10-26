<script lang="ts">
  import { goto } from '$app/navigation';
  import { fade, fly } from 'svelte/transition';
  
  // Define the Feature type
  type Feature = {
    icon: string;
    title: string;
    description: string;
    route: string;
  };

  // Features data
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
      route: '/dashboard'
    },
    {   
      icon: '📊', 
      title: 'Scalable Architecture', 
      description: 'Designed to efficiently manage large volumes of academic data.',
      route: '/some'
    },
  ];

  // Using runes for state
  let visibleFeatures = $state([]);

  // Effect for animated feature loading
  $effect(() => {
    let currentIndex = 0;
    const interval = setInterval(() => {
      if (currentIndex < features.length) {
        visibleFeatures = [...visibleFeatures, features[currentIndex]];
        currentIndex++;
      } else {
        clearInterval(interval);
      }
    }, 500);

    // Cleanup
    return () => clearInterval(interval);
  });

  function navigateTo(route: string) {
    goto(route);
  }

  import UiShowcase from '../components/UIShowcase.svelte';
  import NavBar from '../components/NavBar.svelte';
</script>


<NavBar />

<!-- * ENABLE THE UI SHOWCASE COMPONENT -->
<!-- <UiShowcase /> -->



<div class="text-center mb-16" in:fade={{ duration: 1000 }}>
  <h1 class="text-5xl font-extrabold text-primary mb-4">
    Welcome to Pharmacy Management
  </h1>
  <p class="text-2xl text-secondary font-light">
    Empowering educational institutions with cutting-edge data management
  </p>
</div>

<h2 class="text-3xl font-bold text-center mb-8">Features</h2>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
  {#each visibleFeatures as feature, i (feature.title)}
    <button
      class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow duration-300 cursor-pointer"
      onclick={() => navigateTo(feature.route)}
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