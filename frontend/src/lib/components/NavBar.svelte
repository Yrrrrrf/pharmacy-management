<script lang="ts">
    import { page } from '$app/stores';
    import { fly } from 'svelte/transition';
    import { clickOutside } from '../../routes/clickOutside';
    import SearchBar from './SearchBar.svelte';

    type ServiceItem = {
        name: string;
        href: string;
    };

    export let services: ServiceItem[] = [
        { name: "Manage", href: "/manage" },
        { name: "Some", href: "/some" },
        { name: "Another", href: "/another" }
    ];

    let showServices = false;

    function toggleServices() {
        showServices = !showServices;
    }

    function closeServices() {
        showServices = false;
    }

    function handleSearch(event: CustomEvent<string>) {
        const query = event.detail;
        console.log('Searching for:', query);
        // Implement search functionality here
    }
</script>

<header class="animated-bg shadow-lg text-white">
    <nav class="container mx-auto px-4 py-3">
        <div class="flex justify-between items-center">
            <!-- TODO: Add logo slot here -->
            <a href="/" class="flex items-center space-x-2">
                <span class="text-xl font-bold">Academic Hub</span>
            </a>

            <div class="flex items-center space-x-4">
                <!-- TODO: Add search slot here -->
                <div class="relative">
                    <SearchBar on:search={handleSearch} />
                </div>

                <!-- TODO: Add academic slot here -->
                <a href="/dashboard" class="hover:text-secondary transition-colors duration-200">Dashboard</a>

                <!-- Services dropdown -->
                <div class="relative" use:clickOutside on:click_outside={closeServices}>
                    <button
                            on:click={toggleServices}
                            class="flex items-center space-x-1 hover:text-secondary transition-colors duration-200"
                    >
                        <span>Services</span>
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </button>
                    {#if showServices}
                        <div
                                class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-10"
                                in:fly="{{ y: -5, duration: 300 }}"
                                out:fly="{{ y: -5, duration: 300 }}"
                        >
                            <!-- TODO: Add services slot here -->
                            {#each services as service}
                                <a
                                        href={service.href}
                                        class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors duration-200"
                                        class:font-bold={$page.url.pathname === service.href}
                                >
                                    {service.name}
                                </a>
                            {/each}
                            <div class="border-t border-gray-200 my-1"></div>
                            <a
                                    href="/settings"
                                    class="block px-4 py-2 text-sm text-blue-600 hover:bg-gray-100 transition-colors duration-200"
                                    class:font-bold={$page.url.pathname === '/settings'}
                            >
                                Settings
                            </a>
                        </div>
                    {/if}
                </div>

                <!-- TODO: Add profile slot here -->
                <a href="/profile" class="hover:text-secondary transition-colors duration-200">Profile</a>
            </div>
        </div>
    </nav>
</header>

<style>
    .animated-bg {
        background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
        background-size: 400% 400%;
        animation: gradient 60s ease infinite;
    }

    @keyframes gradient {
        0% {
            background-position: 0% 50%;
        }
        50% {
            background-position: 100% 50%;
        }
        100% {
            background-position: 0% 50%;
        }
    }

    /* Add some glass effect */
    .animated-bg::before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(5px);
        z-index: -1;
    }

    /* Enhance text readability */
    .animated-bg * {
        text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
    }
</style>
