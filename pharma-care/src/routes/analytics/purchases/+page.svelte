<script lang="ts">
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';
    import { 
        ChartBar, 
        Calendar, 
        DollarSign, 
        TrendingUp, 
        Download, 
        FileText, 
        Loader2,
        Package,
        Truck 
    } from 'lucide-svelte';
    import { formatCurrency } from '$lib/stores/cart';
    import { defaultApiClient } from '$lib/api/client';
    import { generatePurchaseReport } from '$lib/api/utils/pdf';

    interface Purchase {
        purchase_id: string;
        purchase_date: string;
        supplier_id: string;
        supplier_name: string;
        reference: string;
        total_amount: string;
        status: string;
    }

    // State Management with Runes
    let purchases = $state<Purchase[]>([]);
    let isLoading = $state(true);
    let error = $state<string | null>(null);
    let dateRange = $state({
        start: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        end: new Date().toISOString().split('T')[0]
    });

    // Derived values
    const totalPurchases = $derived(purchases.length);
    const totalExpenditure = $derived(purchases.reduce((sum, purchase) => 
        sum + Number(purchase.total_amount), 0));
    const averageOrderValue = $derived(totalExpenditure / (totalPurchases || 1));
    
    // Fetch purchases data
    async function fetchPurchases() {
        isLoading = true;
        error = null;
        
        try {
            // First fetch basic purchase data
            const purchaseData = await defaultApiClient.request<Purchase[]>('/management/purchases', {
                params: {
                    start_date: dateRange.start,
                    end_date: dateRange.end
                }
            });

            // Enhance with supplier data and total amounts from purchase_details
            const enhancedPurchases = await Promise.all(purchaseData.map(async purchase => {
                const details = await defaultApiClient.request('/management/v_purchase_orders', {
                // const details = await defaultApiClient.request('/management/purchases', {
                    params: { purchase_id: purchase.purchase_id }
                });
                
                return {
                    ...purchase,
                    total_amount: details.reduce((sum: number, detail: any) => 
                        sum + (detail.purchase_total || 0), 0).toString(),
                    supplier_name: details[0]?.supplier_name || 'Unknown Supplier'
                };
            }));

            purchases = enhancedPurchases;
        } catch (err) {
            console.error('Error fetching purchases:', err);
            error = err instanceof Error ? err.message : 'Failed to fetch purchase data';
        } finally {
            isLoading = false;
        }
    }

    // Handle date range changes
    function handleDateRangeChange() {
        fetchPurchases();
    }

    // Add state for PDF generation
    let generatingPdfForPurchase = $state<string | null>(null);

    // Function to handle PDF generation and opening
    async function handleViewDetails(purchase: Purchase) {
        generatingPdfForPurchase = purchase.purchase_id;
        
        try {
            await generatePurchaseReport(
                purchase.purchase_id,
                purchase.purchase_date,
                purchase.total_amount,
                purchase.supplier_name,
                purchase.reference
            );
        } catch (err) {
            console.error('Error generating PDF:', err);
        } finally {
            generatingPdfForPurchase = null;
        }
    }

    // Export to CSV
    function exportToCSV() {
        const headers = ['Purchase ID', 'Date', 'Supplier', 'Reference', 'Total Amount'];
        const csvContent = [
            headers.join(','),
            ...purchases.map(purchase => [
                purchase.purchase_id,
                new Date(purchase.purchase_date).toLocaleDateString(),
                purchase.supplier_name,
                purchase.reference,
                purchase.total_amount
            ].join(','))
        ].join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `purchases_report_${dateRange.start}_${dateRange.end}.csv`;
        link.click();
    }

    onMount(() => {
        fetchPurchases();
    });
</script>

<div class="min-h-screen bg-base-200 p-4 md:p-8">
    <!-- Header -->
    <header class="mb-8" in:fly={{ y: -20, duration: 500 }}>
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div>
                <h1 class="text-4xl font-bold mb-2">Purchase Analytics</h1>
                <p class="text-base-content/60">Track and analyze your purchase orders</p>
            </div>
            
            <!-- Date Range Selector -->
            <div class="flex flex-wrap items-center gap-4">
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
                    <Package class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Total Orders</div>
                        <div class="text-2xl font-bold">{totalPurchases}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card bg-secondary text-secondary-content">
            <div class="card-body">
                <div class="flex items-center gap-4">
                    <DollarSign class="w-8 h-8" />
                    <div>
                        <div class="text-sm opacity-80">Total Expenditure</div>
                        <div class="text-2xl font-bold">{formatCurrency(totalExpenditure)}</div>
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

    <!-- Purchases Table -->
    <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
            <h2 class="card-title mb-4">Purchase History</h2>
            
            {#if isLoading}
                <div class="flex justify-center items-center h-64">
                    <span class="loading loading-spinner loading-lg text-primary"></span>
                </div>
            {:else if error}
                <div class="alert alert-error">
                    <span>{error}</span>
                </div>
            {:else if purchases.length === 0}
                <div class="text-center py-12">
                    <Truck class="w-12 h-12 mx-auto text-base-content/20" />
                    <h3 class="mt-4 text-lg font-medium">No purchases found</h3>
                    <p class="mt-1 text-base-content/60">
                        Try adjusting your date range to see more results
                    </p>
                </div>
            {:else}
                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full">
                        <thead>
                            <tr>
                                <th>Purchase ID</th>
                                <th>Date</th>
                                <th>Supplier</th>
                                <th>Reference</th>
                                <th>Amount</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {#each purchases as purchase}
                                <tr class="hover">
                                    <td class="font-mono text-sm">{purchase.purchase_id}</td>
                                    <td>{new Date(purchase.purchase_date).toLocaleString()}</td>
                                    <td>{purchase.supplier_name}</td>
                                    <td>{purchase.reference}</td>
                                    <td>{formatCurrency(Number(purchase.total_amount))}</td>
                                    <td>
                                        <button 
                                            class="btn btn-ghost btn-xs"
                                            onclick={() => handleViewDetails(purchase)}
                                            disabled={generatingPdfForPurchase === purchase.purchase_id}
                                        >
                                            {#if generatingPdfForPurchase === purchase.purchase_id}
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
