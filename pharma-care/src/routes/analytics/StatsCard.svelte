<!-- src/components/StatsCard.svelte -->
<script lang="ts">
    import { fly } from 'svelte/transition';
    import { analyticsService } from '$lib/stores/analytics';
    import type { DashboardMetrics } from '$lib/stores/analytics';
    import { formatCurrency } from '$lib/stores/cart';
    import { DollarSign, Package, Users, Pill } from 'lucide-svelte';

    // State management
    let metricsData: DashboardMetrics | null = null;

    // Stats cards configuration
    const baseStatsCards = [
        {   title: 'Total Sales', icon: DollarSign, color: 'bg-success text-success-content',
            getValue: (data: DashboardMetrics | null) => data ? formatCurrency(data.total_sales) : '—',
        },
        {   title: 'Inventory Items', icon: Package, color: 'bg-info text-info-content',
            getValue: (data: DashboardMetrics | null) => data?.inventory_items ?? '—',
        },
        {   title: 'Sales Count', icon: Users, color: 'bg-secondary text-secondary-content',
            getValue: (data: DashboardMetrics | null) => data?.sales_count ?? '—',
        },
        {   title: 'Prescriptions', icon: Pill, color: 'bg-primary text-primary-content',
            getValue: (data: DashboardMetrics | null) => data?.prescriptions_count ?? '—',
        },
    ];

    // Fetch metrics data
    async function loadMetrics() {
        try {
            metricsData = await analyticsService.fetchDashboardMetrics();
        } catch (error) {
            console.error('Failed to fetch metrics', error);
        }
    }

    loadMetrics();
</script>

<!-- Stats Cards -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    {#each baseStatsCards as { title, icon: Icon, color, getValue }, i}
        <div class="card bg-base-100 shadow-xl" in:fly={{ y: 20, duration: 500, delay: i * 100 }}>
            <div class="card-body">
                <div class="flex items-center justify-between">
                    <h2 class="card-title text-sm">{title}</h2>
                    <div class="rounded-full p-2 {color}">
                        <Icon class="w-6 h-6" />
                    </div>
                </div>
                <p class="text-2xl font-bold">{getValue(metricsData)}</p>
            </div>
        </div>
    {/each}
</div>
