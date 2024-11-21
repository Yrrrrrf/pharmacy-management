<!-- src/routes/analytics/+page.svelte -->
<script lang="ts">
    import { fly } from 'svelte/transition';
    import { appName } from '$lib/stores/app';
    import SalesChart from './SalesChart.svelte';
    import StatsCard from './StatsCard.svelte';
    import QuickActions from "./QuickActions.svelte";

    // Recent activities
    const recentActivities = [
        { title: 'New order received', description: 'Order #1234 for Patient John Doe', icon: '📦', time: '2 minutes ago' },
        { title: 'Inventory alert', description: 'Paracetamol stock is running low', icon: '🔔', time: '1 hour ago' },
        { title: 'Prescription refill', description: 'Sarah Connor requested a refill', icon: '💊', time: '3 hours ago' },
    ];

    // Team members
    const teamMembers = [
        { name: 'Dr. Jane Foster', role: 'Head Pharmacist' },
        { name: 'Mike Ross', role: 'Pharmacy Technician' },
        { name: 'Rachel Green', role: 'Pharmacy Assistant' },
    ];
</script>

<div class="min-h-screen bg-base-200 p-8">
    <!-- Header -->
    <header class="mb-8" in:fly={{ y: -20, duration: 500 }}>
        <h1 class="text-4xl font-bold mb-2">Analytics</h1>
    </header>
    <!-- Stats Cards -->
    <StatsCard />

    <!-- Main Content Grid - Updated to 2 columns -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <QuickActions />
        <SalesChart />
    </div>

    <!-- Bottom Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Recent Activities -->
        <div class="lg:col-span-2 card bg-base-100 shadow-xl" in:fly={{ y: 20, duration: 500 }}>
            <div class="card-body">
                <h2 class="card-title">Recent Activities</h2>
                <p class="text-sm text-base-content/60">You have 3 unread notifications</p>
                <div class="space-y-4">
                    {#each recentActivities as { title, description, icon, time }}
                        <div class="flex items-start space-x-4">
                            <div class="w-6 h-6 mt-1">{icon}</div>
                            <div class="flex-1">
                                <p class="font-medium">{title}</p>
                                <p class="text-sm text-base-content/60">{description}</p>
                            </div>
                            <span class="text-xs text-base-content/40">{time}</span>
                        </div>
                    {/each}
                </div>
            </div>
        </div>

        <!-- Team Members -->
        <div class="card bg-base-100 shadow-xl" in:fly={{ y: 20, duration: 500, delay: 200 }}>
            <div class="card-body">
                <h2 class="card-title">Team Members</h2>
                <div class="space-y-4">
                    {#each teamMembers as { name, role }}
                        <div class="flex items-center space-x-4">
                            <div class="avatar placeholder">
                                <div class="w-10 rounded-full bg-neutral-focus text-neutral-content">
                                    <span class="text-xs">{name.split(' ').map(n => n[0]).join('')}</span>
                                </div>
                            </div>
                            <div>
                                <p class="font-medium">{name}</p>
                                <p class="text-sm text-base-content/60">{role}</p>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>
        </div>
    </div>
</div>
