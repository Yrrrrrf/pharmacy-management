<!-- src/components/ThemeSelector.svelte -->
<script lang="ts">
    import { getAvailableThemes, currentTheme, setTheme } from '$lib/stores/theme';
    import { fade } from 'svelte/transition';
    
    // Props
    const { icon = null } = $props(); // Allow parent to pass icon component
    
    let showDropdown = $state(false);
    let searchQuery = $state('');
    
    const themes = getAvailableThemes();
    
    $effect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            const target = event.target as HTMLElement;
            if (!target.closest('.theme-selector')) {
                showDropdown = false;
            }
        };
        
        document.addEventListener('click', handleClickOutside);
        return () => document.removeEventListener('click', handleClickOutside);
    });
    
    const filteredThemes = $derived(
        themes.filter(theme => 
            theme.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            theme.description?.toLowerCase().includes(searchQuery.toLowerCase())
        )
    );
    
    function handleThemeSelect(themeValue: string) {
        setTheme(themeValue);
        showDropdown = false;
    }
</script>

<div class="theme-selector dropdown dropdown-end">
    <button 
        tabindex="0" 
        class="btn btn-ghost btn-circle"
        onclick={() => showDropdown = !showDropdown}
    >
        {#if icon}
            <svelte:component this={icon} class="w-5 h-5" />
        {/if}
    </button>

    {#if showDropdown}
        <ul 
            class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-72 mt-4"
            transition:fade={{ duration: 200 }}
        >
            <li class="menu-title">Theme</li>
            <div class="p-2">
                <input
                    type="text"
                    placeholder="Search themes..."
                    class="input input-bordered input-sm w-full"
                    bind:value={searchQuery}
                />
            </div>
            <div class="max-h-64 overflow-y-auto">
                {#each filteredThemes as theme (theme.value)}
                    <li>
                        <button
                            class="flex items-center gap-4 {$currentTheme === theme.value ? 'active' : ''}"
                            onclick={() => handleThemeSelect(theme.value)}
                        >
                            <span class="text-xl">{theme.icon}</span>
                            <div class="flex flex-col items-start">
                                <span>{theme.name}</span>
                                {#if theme.description}
                                    <span class="text-xs opacity-60">{theme.description}</span>
                                {/if}
                            </div>
                        </button>
                    </li>
                {/each}
            </div>
        </ul>
    {/if}
</div>
