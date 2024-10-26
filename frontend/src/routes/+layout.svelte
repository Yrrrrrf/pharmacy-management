<script>
  import '../app.css';
  import { onMount } from 'svelte';
  import { initTheme } from '$lib/theme';
    import Footer from '../components/Footer.svelte';
  
  onMount(() => {
    initTheme();
  });
</script>

<div class="flex flex-col min-h-screen">
  <main class="flex-grow">
    <slot />
  </main>

  <Footer />
</div>