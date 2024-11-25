<!-- src/routes/+page.svelte -->
<script lang="ts">
    import { goto } from '$app/navigation';
    import { appName } from '$lib/stores/app';  // Add this import
    import { MapPin, Phone, Mail } from 'lucide-svelte';

    // Services data
    const services = [
        { title: 'Prescription Filling', description: 'Quick and accurate prescription services' },
        { title: 'Health Consultations', description: 'Expert advice from our pharmacists' },
        { title: 'Vaccinations', description: 'Flu shots and other immunizations' },
    ];
    // Features data
    const features = [
        { title: 'Expert Staff', description: 'Knowledgeable and friendly pharmacists' },
        { title: 'Wide Selection', description: 'Extensive range of health products' },
        { title: 'Fast Service', description: 'Minimal wait times for prescriptions' },
        { title: 'Community Focus', description: 'Committed to our local community' },
    ];
    // Testimonials data
    const testimonials = [
        { name: 'Sarah J.', quote: 'PharmaCare always goes above and beyond. Their staff is incredibly helpful!' },
        { name: 'Michael T.', quote: 'I appreciate the quick service and the wide range of products available.' },
        { name: 'Emily R.', quote: 'The pharmacists are knowledgeable and take the time to answer all my questions.' },
    ];
    // Schedule data
    const schedule = [
        { day: 'Monday - Friday', hours: '9:00 AM - 9:00 PM' },
        { day: 'Saturday', hours: '10:00 AM - 6:00 PM' },
        { day: 'Sunday', hours: 'Closed' },
    ];

    let emailInput = $state('');

    function handleSubscribe() {
        // * Add newsletter subscription logic here
        console.log('Subscribe:', emailInput);
        emailInput = '';
    }
  </script>
  
  
  <!-- * ENABLE THE UI SHOWCASE COMPONENT -->
  <!-- <UiShowcase /> -->
  
  <div class="min-h-screen bg-gradient-to-br from-base-200 to-base-300">
    <main>
        <!-- Hero Section -->
        <section class="hero py-12">
            <div class="hero-content text-center">
                <div class="max-w-3xl">
                    <h1 class="text-5xl font-bold mb-2">Welcome to {$appName}</h1>
                    <h2 class="text-4xl font-bold text-primary mb-4">Your Health, Our Priority</h2>
                    <p class="py-6 text-xl">
                        Providing quality healthcare services and products to our community for over 25 years.
                    </p>
                    <button class="btn btn-primary" onclick={() => goto('/store')}>
                        Find a Store
                    </button>
                </div>
            </div>
        </section>
  
        <!-- Services Section -->
        <section class="py-12">
            <div class="container mx-auto px-4">
                <h2 class="text-3xl font-bold text-center mb-8">Our Services</h2>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {#each services as service}
                        <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow">
                            <div class="card-body">
                                <h3 class="card-title">{service.title}</h3>
                                <p>{service.description}</p>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>
        </section>
  
        <!-- Features Section -->
        <section class="bg-primary text-primary-content py-12">
            <div class="container mx-auto px-4">
                <h2 class="text-3xl font-bold text-center mb-8">Why Choose {$appName}?</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    {#each features as feature}
                        <div class="text-center">
                            <h3 class="text-xl font-semibold mb-2">{feature.title}</h3>
                            <p class="opacity-90">{feature.description}</p>
                        </div>
                    {/each}
                </div>
            </div>
        </section>
  
        <!-- Testimonials Section -->
        <section class="py-12">
            <div class="container mx-auto px-4">
                <h2 class="text-3xl font-bold text-center mb-8">What Our Customers Say</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {#each testimonials as testimonial}
                        <div class="card bg-base-100 shadow-xl">
                            <div class="card-body">
                                <p class="italic mb-4">"{testimonial.quote}"</p>
                                <p class="font-semibold">- {testimonial.name}</p>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>
        </section>
  
        <!-- Contact Section -->
        <section class="bg-base-200 py-12">
            <div class="container mx-auto px-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                    <!-- Visit Us -->
                    <div>
                        <h2 class="text-3xl font-bold mb-4">Visit Us</h2>
                        <div class="space-y-4">
                            <p class="flex items-center gap-2"><MapPin class="text-primary" />123 Health Street, Wellness City, MC 12345</p>
                            <p class="flex items-center gap-2"><Phone class="text-primary" />(555) 123-4567</p>
                            <p class="flex items-center gap-2"><Mail class="text-primary" />info@pharmacare.com</p>
                        </div>
                    </div>
  
                    <!-- Opening Hours -->
                    <div>
                        <h2 class="text-3xl font-bold mb-4">Opening Hours</h2>
                        <div class="space-y-2">
                            {#each schedule as { day, hours }}
                                <p class="flex items-center justify-between">
                                    <span>{day}</span>
                                    <span class="font-semibold">{hours}</span>
                                </p>
                            {/each}
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>
</div>
  