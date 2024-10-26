<script lang="ts">
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    
    let Bell, Search, Settings, User, Pill, Activity, Droplet;
    let isSearchActive = false;
    let searchInput: HTMLInputElement;
    let mounted = false;
    let searchQuery = '';
    
    onMount(async () => {
        const icons = await import('lucide-svelte');
        ({ Bell, Search, Settings, User, Pill, Activity, Droplet } = icons);
        mounted = true;
    });

    const items = [
        { icon: 'Pill', label: 'Inventory', path: '/inventory' },
        { icon: 'Activity', label: 'Analytics', path: '/analytics' },
        { icon: 'Droplet', label: 'Lab', path: '/lab' },
    ];

    function toggleSearch() {
        isSearchActive = !isSearchActive;
        if (isSearchActive) {
            setTimeout(() => searchInput?.focus(), 100);
        } else {
            searchQuery = '';
        }
    }

    function handleSearch(e: KeyboardEvent) {
        if (e.key === 'Enter' && searchQuery.trim()) {
            goto(`/search?q=${encodeURIComponent(searchQuery)}`);
            toggleSearch();
        } else if (e.key === 'Escape') {
            toggleSearch();
        }
    }

    function navigateTo(path: string) {
        goto(path);
    }

    let notificationCount = 3; // Example notification count
</script>

<nav class="bg-gradient-to-r from-teal-500 to-cyan-600 p-4 rounded-b-3xl shadow-lg backdrop-blur-sm">
    <div class="max-w-7xl mx-auto flex items-center justify-between">
        <!-- Logo and Title -->
        <div class="flex items-center space-x-4 cursor-pointer" on:click={() => navigateTo('/')}>
            <div class="relative w-10 h-10 transition-transform duration-300 hover:scale-110">
                <img 
                    src="/favicon.png" 
                    alt="PharmaCare Logo"
                    class="w-full h-full object-contain rounded-full hover:animate-spin"
                />
            </div>
            <h1 class="text-white text-2xl font-bold hover:text-cyan-100 transition-colors duration-300">
                PharmaCare
            </h1>
        </div>

        {#if mounted}
        <div class="flex items-center space-x-6">
            <!-- Navigation Items -->
            <ul class="hidden md:flex space-x-4">
                {#each items as item}
                    <li>
                        <button 
                            on:click={() => navigateTo(item.path)}
                            class="flex items-center px-3 py-2 text-white hover:bg-white hover:text-teal-600 rounded-full transition-all duration-300 ease-in-out transform hover:scale-110 group"
                        >
                            <svelte:component this={eval(item.icon)} class="w-5 h-5 mr-2 group-hover:animate-bounce" />
                            <span class="font-medium">{item.label}</span>
                        </button>
                    </li>
                {/each}
            </ul>

            <!-- Enhanced Search Bar -->
            <div class="relative flex items-center">
                <div class="relative {isSearchActive ? 'w-64' : 'w-10'} transition-all duration-300 ease-in-out">
                    <input
                        bind:this={searchInput}
                        bind:value={searchQuery}
                        type="text"
                        placeholder={isSearchActive ? "Search..." : ""}
                        on:keydown={handleSearch}
                        class="w-full bg-white/20 text-white placeholder-white/70 rounded-full py-2 pl-10 pr-4 
                               focus:outline-none focus:ring-2 focus:ring-white/50 transition-all duration-300
                               {isSearchActive ? 'opacity-100' : 'opacity-0'}"
                    />
                    <button 
                        on:click={toggleSearch}
                        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-white 
                               transition-all duration-300 hover:scale-110
                               {isSearchActive ? 'opacity-100' : 'opacity-70 hover:opacity-100'}"
                    >
                        <svelte:component this={Search} class="w-5 h-5" />
                    </button>
                </div>
            </div>

            <!-- User Menu Section -->
            <div class="flex items-center space-x-4">
                <!-- Notifications -->
                <div class="relative">
                    <button class="relative">
                        <svelte:component this={Bell} class="w-6 h-6 text-white cursor-pointer hover:text-yellow-300 transition-colors duration-300" />
                        {#if notificationCount > 0}
                            <span class="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center animate-pulse">
                                {notificationCount}
                            </span>
                        {/if}
                    </button>
                </div>

                <!-- Settings -->
                <button on:click={() => navigateTo('/settings')}>
                    <svelte:component this={Settings} class="w-6 h-6 text-white cursor-pointer hover:rotate-90 transition-transform duration-300" />
                </button>

                <!-- User Profile Dropdown -->
                <div class="relative group">
                    <button class="focus:outline-none">
                        <svelte:component this={User} class="w-8 h-8 text-white cursor-pointer p-1 rounded-full bg-white/20 group-hover:bg-white/40 transition-colors duration-300" />
                    </button>
                    <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-xl py-2 hidden group-hover:block transition-all duration-300 ease-in-out transform origin-top-right scale-95 group-hover:scale-100 z-50">
                        <button 
                            on:click={() => navigateTo('/profile')}
                            class="block w-full text-left px-4 py-2 text-gray-800 hover:bg-teal-100 transition-colors duration-200"
                        >
                            Profile
                        </button>
                        <button 
                            on:click={() => navigateTo('/settings')}
                            class="block w-full text-left px-4 py-2 text-gray-800 hover:bg-teal-100 transition-colors duration-200"
                        >
                            Settings
                        </button>
                        <hr class="my-1 border-gray-200" />
                        <button 
                            on:click={() => navigateTo('/logout')}
                            class="block w-full text-left px-4 py-2 text-red-600 hover:bg-red-50 transition-colors duration-200"
                        >
                            Logout
                        </button>
                    </div>
                </div>
            </div>
        </div>
        {/if}
    </div>
</nav>
