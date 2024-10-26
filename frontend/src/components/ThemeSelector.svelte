<script lang="ts">
    import { getAvailableThemes, currentTheme, setTheme } from '../lib/theme';
    import { fade } from 'svelte/transition';
    
    let showDropdown = $state(false);
    let searchQuery = $state('');
    
    const themes = getAvailableThemes();
    
    $effect(() => {
      // Close dropdown when clicking outside
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
  
<div class="theme-selector relative">
    <button class="btn btn-ghost gap-2" on:click={() => showDropdown = !showDropdown} >
        <span class="text-xl">{themes.find(t => t.value === $currentTheme)?.icon || '🎨'}</span>
        <span class="hidden md:inline">{themes.find(t => t.value === $currentTheme)?.name || 'Theme'}</span>
    </button>

    {#if showDropdown}
        <div class="absolute right-0 mt-2 w-72 max-h-96 overflow-y-auto rounded-box bg-base-200 shadow-lg z-50"
            transition:fade={{ duration: 200 }}
        >
            <div class="p-4 sticky top-0 bg-base-200 border-b border-base-300">
                <input
                    type="text"
                    placeholder="Search themes..."
                    class="input input-bordered w-full"
                    bind:value={searchQuery}
                />
            </div>
            
            <div class="grid grid-cols-1 gap-1 p-2">
                {#each filteredThemes as theme (theme.value)}
                    <button
                        class="btn btn-ghost justify-start gap-4 {$currentTheme === theme.value ? 'btn-active' : ''}"
                        on:click={() => handleThemeSelect(theme.value)}
                    >
                        <span class="text-xl">{theme.icon}</span>
                        <div class="flex flex-col items-start">
                            <span>{theme.name}</span>
                            {#if theme.description}
                                <span class="text-xs opacity-60">{theme.description}</span>
                            {/if}
                        </div>
                    </button>
                {/each}
            </div>
        </div>
    {/if}
</div>
