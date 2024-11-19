<!-- src/components/NavBar.svelte -->
<script lang="ts">
    import { goto } from '$app/navigation';
    // Stores
    import { appName } from '$lib/stores/app';
    import { authStore } from '$lib/stores/auth';    

    // Components
    import AuthCard from '$lib/components/auth/AuthCard.svelte';
    import UserAvatar from '$lib/components/auth/UserAvatar.svelte';
    import ThemeSelector from './ThemeSelector.svelte';

    // Icons - direct imports
    import { 
        Bell, 
        Search, 
        Settings, 
        User, 
        Pill, 
        Activity, 
        LogIn, 
        LogOut 
    } from 'lucide-svelte';
    import Cart from '$lib/components/common/store/Cart.svelte';

    // State using Runes
    let isSearchActive = $state(false);
    let searchQuery = $state('');
    let notificationCount = $state(3);

    // Auth state
    const isAuthenticated = $derived($authStore.isAuthenticated);
    
    // Navigation items with proper typing
    type NavItem = {
        icon: typeof Pill | typeof Activity | typeof User;
        label: string;
        path: string;
        requiresAuth: boolean;
    };

    const navItems: NavItem[] = [
        { icon: Pill, label: 'Inventory', path: '/inventory', requiresAuth: true },
        // { icon: Activity, label: 'Analytics', path: '/dashboard', requiresAuth: true },
        { icon: Activity, label: 'Analytics', path: '/analytics', requiresAuth: true },
    ];

    // Compute visible nav items based on auth state
    const visibleNavItems = $derived(
        navItems.filter(item => !item.requiresAuth || isAuthenticated)
    );

    function handleSearch(e: KeyboardEvent) {
        if (e.key === 'Enter' && searchQuery.trim()) {
            goto(`/search?q=${encodeURIComponent(searchQuery)}`);
            isSearchActive = false;
        } else if (e.key === 'Escape') {
            isSearchActive = false;
        }
    }
</script>

<div class="navbar bg-base-100">
    <!-- Logo Section -->
    <div class="flex-1">
        <button class="btn btn-ghost normal-case text-xl gap-2" onclick={() => goto('/')}>
            <div class="w-10 h-10">
                <img 
                    src="/favicon.png" 
                    alt="{$appName} Logo"
                    class="w-full h-full object-contain rounded-full hover:animate-spin"
                />
            </div>
            <span>{$appName}</span>
        </button>
    </div>

    <div class="flex-none gap-2">
        <!-- Navigation Links -->
        <ul class="menu menu-horizontal px-1 hidden md:flex">
            {#each visibleNavItems as {icon: Icon, label, path}}
                <li>
                    <button class="btn btn-ghost" onclick={() => goto(path)} >
                        <Icon class="w-5 h-5" />
                        <span>{label}</span>
                    </button>
                </li>
            {/each}
        </ul>

        <!-- Search -->
        <!--
        <div class="form-control">
            <div class="relative {isSearchActive ? 'w-64' : 'w-10'} transition-all duration-300">
                <input
                    bind:value={searchQuery}
                    type="text"
                    placeholder={isSearchActive ? "Search..." : ""}
                    onkeydown={handleSearch}
                    class="input input-bordered input-sm w-full 
                           {isSearchActive ? 'opacity-100' : 'opacity-0'}"
                />
                <button 
                    class="btn btn-ghost btn-circle btn-sm absolute left-0 top-0"
                    onclick={() => isSearchActive = !isSearchActive}
                >
                    <Search class="w-4 h-4" />
                </button>
            </div>
        </div>
        -->

        <!-- Authenticated Content -->
        {#if isAuthenticated}
            <!-- Notifications -->
            <div class="dropdown dropdown-end">
                <button class="btn btn-ghost btn-circle">
                    <div class="indicator">
                        <Bell class="w-5 h-5" />
                        {#if notificationCount > 0}
                            <span class="badge badge-sm indicator-item">{notificationCount}</span>
                        {/if}
                    </div>
                </button>
            </div>

            <!-- User Avatar -->
            <UserAvatar LogOutIcon={LogOut} />
        {:else}
            <Cart />
            <!-- Login/Auth Card Dropdown -->
            <div class="dropdown dropdown-end">
                <button class="btn btn-primary btn-sm">
                    <LogIn class="w-4 h-4 mr-2" />
                    Sign In
                </button>
                <div class="dropdown-content z-[1] p-2 mt-2">
                    <AuthCard 
                        onLogin={(data) => {
                            authStore.set({
                                isAuthenticated: true,
                                user: {
                                    id: '1',
                                    name: data.email.split('@')[0],
                                    email: data.email,
                                    role: 'staff'
                                }
                            });
                        }}
                        />
                        
                        <!-- 

                        onSignup={(data) => {
                            authStore.set({
                                isAuthenticated: true,
                                user: {
                                    id: '1',
                                    name: data.name,
                                    email: data.email,
                                    role: 'staff'
                                }
                            });
                        }} 
                            
                        -->

                </div>
            </div>
        {/if}

        <!-- Theme Selector -->
        <ThemeSelector icon={Settings} />
    </div>
</div>
