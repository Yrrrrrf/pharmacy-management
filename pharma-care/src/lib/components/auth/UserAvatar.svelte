<!-- src/components/UserAvatar.svelte -->
<script lang="ts">
    import { goto } from '$app/navigation';
    import { authStore } from '$lib/stores/auth';
    
    // Props
    export let LogOutIcon: any = null;
    
    function handleLogout() {
        authStore.set({
            isAuthenticated: false,
            user: null
        });
        goto('/');
    }
</script>

<div class="dropdown dropdown-end">
    <button tabindex="0" class="btn btn-ghost btn-circle">
        <div class="avatar">
            <div class="w-10 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
                <!-- {#if $authStore.user?.avatarUrl}
                    <img src={$authStore.user.avatarUrl} alt={$authStore.user.name} />
                {:else} -->
                    <div class="bg-primary text-primary-content grid place-items-center">
                        {$authStore.user?.name?.[0].toUpperCase() ?? 'U'}
                    </div>
                <!-- {/if} -->
            </div>
        </div>
    </button>
    <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52 mt-4">
        <li class="menu-title text-sm opacity-70">
            Signed in as<br/>
            <span class="font-semibold">{$authStore.user?.name}</span>
        </li>
        <div class="divider my-0"></div>
        <li><a href="/profile">Profile</a></li>
        <li><a href="/settings">Settings</a></li>
        <div class="divider my-0"></div>
        <li>
            <button 
                class="text-error"
                onclick={handleLogout}
            >
                {#if LogOutIcon}
                    <svelte:component this={LogOutIcon} class="w-4 h-4" />
                {/if}
                Logout
            </button>
        </li>
    </ul>
</div>