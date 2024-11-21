<!-- src/components/DailySalesOverview.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    import type { Chart as ChartJS, ChartConfiguration } from 'chart.js';
    import { analyticsService, chartOptions } from '$lib/stores/analytics';

    let chartCanvas: HTMLCanvasElement | undefined;
    let chart: ChartJS | undefined;
    let isLoadingChart = true;
    let chartError: string | null = null;

    async function initializeChart() {
        try {
            isLoadingChart = true;
            const { default: Chart } = await import('chart.js/auto');
            const chartData = await analyticsService.fetchDailySales();

            const ctx = chartCanvas?.getContext('2d');
            if (!ctx) throw new Error('Could not get canvas context');

            const config: ChartConfiguration<'line'> = {
                type: 'line',
                data: chartData,
                options: chartOptions,
            };

            chart = new Chart(ctx, config);
        } catch (err) {
            chartError = err instanceof Error ? err.message : 'Failed to load chart';
        } finally {
            isLoadingChart = false;
        }
    }

    onMount(() => {
        initializeChart();
        return () => {
            if (chart) chart.destroy();
        };
    });
</script>

<div class="card bg-base-100 shadow-xl">
    <div class="card-body">
        <h2 class="card-title">Weeky Sales Overview</h2>
        <div class="h-[300px] mt-4 relative">
            {#if isLoadingChart}
                <div class="absolute inset-0 flex items-center justify-center">
                    <span class="loading loading-spinner loading-lg text-primary"></span>
                </div>
            {:else if chartError}
                <div class="alert alert-error">
                    <span>{chartError}</span>
                </div>
            {/if}
            <canvas bind:this={chartCanvas}></canvas>
        </div>
    </div>
</div>
