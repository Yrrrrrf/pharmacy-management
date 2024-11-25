<script lang="ts">
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';
    import { ChartBar, Calendar, DollarSign, TrendingUp, Download, FileText, Loader2 } from 'lucide-svelte';
    import { formatCurrency } from '$lib/stores/cart';
    import { defaultApiClient } from '$lib/api/client';
    import { generateSaleReport } from '$lib/api/utils/pdf';

    interface Sale {
        sale_id: string;
        sale_date: string;
        total_amount: string;
        payment_method: string;
    }

    // State Management with Runes
    let sales = $state<Sale[]>([]);
    let isLoading = $state(true);
    let error = $state<string | null>(null);
    let dateRange = $state({
        start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        end: new Date().toISOString().split('T')[0]
    });

    // Derived values
    const totalSales = $derived(sales.length);
    const totalRevenue = $derived(sales.reduce((sum, sale) => sum + Number(sale.total_amount), 0));
    const averageOrderValue = $derived(totalRevenue / (totalSales || 1));
    
    // Fetch sales data
    async function fetchSales() {
        isLoading = true;
        error = null;
        
        try {
            const response = await defaultApiClient.request<Sale[]>('/management/sales', {
                params: {
                    // Add date range filtering
                    start_date: dateRange.start,
                    end_date: dateRange.end
                }
            });
            sales = response;
        } catch (err) {
            console.error('Error fetching sales:', err);
            error = err instanceof Error ? err.message : 'Failed to fetch sales data';
        } finally {
            isLoading = false;
        }
    }

    // Handle date range changes
    function handleDateRangeChange() {
        fetchSales();
    }

    // Add state for PDF generation
    let generatingPdfForSale = $state<string | null>(null);

    // Function to handle PDF generation and opening
    async function handleViewDetails(sale: Sale) {
        // Track which sale is being processed
        generatingPdfForSale = sale.sale_id;
        
        try {
            await generateSaleReport(
                sale.sale_id,
                sale.sale_date,
                sale.total_amount,
                sale.payment_method
            );
        } catch (err) {
            console.error('Error generating PDF:', err);
            // Optionally show an error toast/notification here
        } finally {
            generatingPdfForSale = null;
        }
    }

    // Export to CSV
    function exportToCSV() {
        const headers = ['Sale ID', 'Date', 'Total Amount', 'Payment Method'];
        const csvContent = [
            headers.join(','),
            ...sales.map(sale => [
                sale.sale_id,
                new Date(sale.sale_date).toLocaleDateString(),
                sale.total_amount,
                sale.payment_method
            ].join(','))
        ].join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `sales_report_${dateRange.start}_${dateRange.end}.csv`;
        link.click();
    }

    onMount(() => {
        fetchSales();
    });
</script>

<div class="min-h-screen bg-base-200 p-4 md:p-8">
    <!-- Header -->
    <header class="mb-8" in:fly={{ y: -20, duration: 500 }}>
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-4xl font-bold mb-2">Sales Analytics</h1>
                <p class="text-base-content/60">Track and analyze your sales performance</p>
            </div>
            
            <!-- Date Range Selector -->
            <div class="flex flex-wrap items-center gap-4">
                <!-- Template modifications for a11y -->
                <div class="form-control">
                    <label for="startDate" class="label">
                        <span class="label-text">Start Date</span>
                    </label>
                    <input 
                        id="startDate"
                        type="date" 
                        class="input input-bordered" 
                        bind:value={dateRange.start}
                        onchange={handleDateRangeChange}
                    />
                </div>
                <div class="form-control">
                    <label for="endDate" class="label">
                        <span class="label-text">End Date</span>
                    </label>
                    <input 
                        id="endDate"
                        type="date" 
                        class="input input-bordered" 
                        bind:value={dateRange.end}
                        onchange={handleDateRangeChange}
                    />
                </div>

                <button 
                    class="btn btn-primary" 
                    onclick={exportToCSV}
                >
                    <Download class="w-4 h-4" />
                    Export CSV
                </button>
            </div>
        </div>
    </header>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="card bg-primary text-primary-content">
            <div class="card-body">
                <div class="flex items-center gap-4">
                    <ChartBar class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Total Sales</div>
                        <div class="text-2xl font-bold">{totalSales}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card bg-secondary text-secondary-content">
            <div class="card-body">
                <div class="flex items-center gap-4">
                    <DollarSign class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Total Revenue</div>
                        <div class="text-2xl font-bold">{formatCurrency(totalRevenue)}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card bg-accent text-accent-content">
            <div class="card-body">
                <div class="flex items-center gap-4">
                    <TrendingUp class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Average Order Value</div>
                        <div class="text-2xl font-bold">{formatCurrency(averageOrderValue)}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card bg-neutral text-neutral-content">
            <div class="card-body">
                <div class="flex items-center gap-4">
                    <Calendar class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Date Range</div>
                        <div class="text-sm font-bold">
                            {new Date(dateRange.start).toLocaleDateString()} - 
                            {new Date(dateRange.end).toLocaleDateString()}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Sales Table -->
    <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
            <h2 class="card-title mb-4">Sales History</h2>
            
            {#if isLoading}
                <div class="flex justify-center items-center h-64">
                    <span class="loading loading-spinner loading-lg text-primary"></span>
                </div>
            {:else if error}
                <div class="alert alert-error">
                    <span>{error}</span>
                </div>
            {:else if sales.length === 0}
                <div class="text-center py-12">
                    <ChartBar class="w-12 h-12 mx-auto text-base-content/20" />
                    <h3 class="mt-4 text-lg font-medium">No sales found</h3>
                    <p class="mt-1 text-base-content/60">
                        Try adjusting your date range to see more results
                    </p>
                </div>
            {:else}
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Sale ID</th>
                                <th>Date</th>
                                <th>Amount</th>
                                <th>Payment Method</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {#each sales as sale}
                                <tr class="hover">
                                    <td class="font-mono text-sm">{sale.sale_id}</td>
                                    <td>{new Date(sale.sale_date).toLocaleString()}</td>
                                    <td>{formatCurrency(Number(sale.total_amount))}</td>
                                    <td>
                                        <span class="badge badge-ghost">{sale.payment_method}</span>
                                    </td>
                                    <td>
                                        <button 
                                            class="btn btn-ghost btn-xs"
                                            onclick={() => handleViewDetails(sale)}
                                            disabled={generatingPdfForSale === sale.sale_id}
                                        >
                                            {#if generatingPdfForSale === sale.sale_id}
                                                <Loader2 class="w-4 h-4 animate-spin" />
                                            {:else}
                                                <FileText class="w-4 h-4" />
                                            {/if}
                                            View Details
                                        </button>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>
            {/if}
        </div>
    </div>
</div>
