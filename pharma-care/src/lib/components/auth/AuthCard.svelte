<!-- src/components/auth/AuthCard.svelte -->
<script lang="ts">
    import { APP_CONFIG } from '$lib/stores/app';
    import { fade, fly } from 'svelte/transition';
    import { 
        Pill,
        Eye,
        EyeOff,
        Mail,
        Lock,
        User,
        Github,
        Twitter
    } from 'lucide-svelte';
    
    // Props using Runes
    const { onLogin, onSignup } = $props<{
        onLogin: (data: { email: string; password: string }) => void;
        onSignup: (data: { name: string; email: string; password: string }) => void;
    }>();
    
    let showPassword = $state(false);
    let activeTab = $state('signin');
    let signInData = $state({ email: '', password: '' });
    let signUpData = $state({ name: '', email: '', password: '' });
</script>

<div class="card w-96 bg-base-100/90 shadow-xl backdrop-blur-sm" in:fly={{ y: -20, duration: 500 }}>
    <div class="card-body">
        <!-- Header -->
        <div class="text-center space-y-2 mb-6">
            <div class="flex justify-center mb-4">
                <Pill class="h-12 w-12 text-primary" />
            </div>
            <h2 class="card-title text-3xl justify-center">{$APP_CONFIG.name}</h2>
            <p class="text-base-content/60">Sign in to manage your pharmacy</p>
        </div>

        <!-- Tabs -->
        <div class="tabs tabs-boxed justify-center mb-6">
            <button 
                class="tab {activeTab === 'signin' ? 'tab-active' : ''}" 
                onclick={() => activeTab = 'signin'}
            >
                Sign In
            </button>
            <button 
                class="tab {activeTab === 'signup' ? 'tab-active' : ''}"
                onclick={() => activeTab = 'signup'}
            >
                Sign Up
            </button>
        </div>

        <!-- Sign In Form -->
        {#if activeTab === 'signin'}
            <form 
                class="space-y-4" 
                onsubmit={(e) => {
                    e.preventDefault();
                    onLogin(signInData);
                }}
            >
                <div class="form-control">
                    <label class="label" for="email">Email</label>
                    <div class="relative">
                        <input 
                            type="email"
                            class="input input-bordered w-full pr-10"
                            placeholder="m@example.com"
                            bind:value={signInData.email}
                            required
                        />
                        <Mail class="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 opacity-50" />
                    </div>
                </div>

                <div class="form-control">
                    <label class="label" for="password">Password</label>
                    <div class="relative">
                        <input 
                            type={showPassword ? 'text' : 'password'}
                            class="input input-bordered w-full pr-10"
                            bind:value={signInData.password}
                            required
                        />
                        <button 
                            type="button"
                            class="btn btn-ghost btn-sm btn-circle absolute right-2 top-1/2 -translate-y-1/2"
                            onclick={() => showPassword = !showPassword}
                        >
                            {#if showPassword}
                                <EyeOff class="w-5 h-5" />
                            {:else}
                                <Eye class="w-5 h-5" />
                            {/if}
                        </button>
                    </div>
                </div>

                <button class="btn btn-primary w-full">Sign In</button>
            </form>

        <!-- Sign Up Form -->
        {:else}
            <form 
                class="space-y-4" 
                onsubmit={(e) => {
                    e.preventDefault();
                    onSignup(signUpData);
                }}
            >
                <div class="form-control">
                    <label class="label" for="name">Full Name</label>
                    <div class="relative">
                        <input 
                            type="text"
                            class="input input-bordered w-full pr-10"
                            placeholder="John Doe"
                            bind:value={signUpData.name}
                            required
                        />
                        <User class="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 opacity-50" />
                    </div>
                </div>

                <div class="form-control">
                    <label class="label" for="email">Email</label>
                    <div class="relative">
                        <input 
                            type="email"
                            class="input input-bordered w-full pr-10"
                            placeholder="m@example.com"
                            bind:value={signUpData.email}
                            required
                        />
                        <Mail class="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 opacity-50" />
                    </div>
                </div>

                <div class="form-control">
                    <label class="label" for="password">Password</label>
                    <div class="relative">
                        <input 
                            type={showPassword ? 'text' : 'password'}
                            class="input input-bordered w-full pr-10"
                            bind:value={signUpData.password}
                            required
                        />
                        <button 
                            type="button"
                            class="btn btn-ghost btn-sm btn-circle absolute right-2 top-1/2 -translate-y-1/2"
                            onclick={() => showPassword = !showPassword}
                        >
                            {#if showPassword}
                                <EyeOff class="w-5 h-5" />
                            {:else}
                                <Eye class="w-5 h-5" />
                            {/if}
                        </button>
                    </div>
                </div>

                <button class="btn btn-primary w-full">Sign Up</button>
            </form>
        {/if}

        <!-- Social Login -->
        <div class="divider">Or continue with</div>
        
        <div class="flex gap-2">
            <button class="btn btn-outline flex-1 gap-2">
                <Github class="w-4 h-4" />
                Github
            </button>
            <button class="btn btn-outline flex-1 gap-2">
                <Twitter class="w-4 h-4" />
                Twitter
            </button>
        </div>
    </div>
</div>