<!-- src/lib/components/analytics/QuickActions.svelte -->
<script lang="ts">
    import { goto } from '$app/navigation';
    import {
        Pill,
        Package,
        FileText,
        ClipboardList,
        Receipt,
        ShoppingBag
    } from 'lucide-svelte';

    interface QuickAction {
        title: string;
        icon: any;
        color: string;
        onClick: () => void;
    }

    const quickActions: QuickAction[] = [
        {
            title: 'New Pharmaceutical',
            icon: Pill,
            color: 'bg-primary/20 text-primary',
            onClick: () => goto('/pharma/new')
        },
        {
            title: 'New Product',
            icon: Package,
            color: 'bg-secondary/20 text-secondary',
            onClick: () => goto('/products/new')
        },
        {
            title: 'New Prescription',
            icon: FileText,
            color: 'bg-info/20 text-info',
            onClick: () => goto('/prescriptions/new')
        },
        {
            title: 'Inventory',
            icon: ClipboardList,
            color: 'bg-success/20 text-success',
            onClick: () => goto('/inventory')
        },
        {
            title: 'Sales Records',
            icon: Receipt,
            color: 'bg-warning/20 text-warning',
            onClick: () => goto('/analytics/sales')
        },
        {
            title: 'Purchase Records',
            icon: ShoppingBag,
            color: 'bg-error/20 text-error',
            onClick: () => goto('/analytics/purchases')
        }
    ];
</script>

<div class="card bg-base-100 shadow-xl">
    <div class="card-body">
        <h2 class="card-title text-center w-full justify-center mb-6">Quick Actions</h2>
        <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
            {#each quickActions as { title, icon: Icon, color, onClick }}
                <button
                        class="card bg-base-200 hover:bg-base-300 transition-all duration-300 hover:scale-105 hover:shadow-lg"
                        onclick={onClick}
                >
                    <div class="card-body p-6 flex flex-col items-center justify-center text-center h-full">
                        <div class="rounded-full p-4 {color} mb-3 transform transition-transform hover:rotate-12">
                            <Icon class="w-6 h-6" />
                        </div>
                        <h3 class="font-semibold text-sm mb-1">{title}</h3>
                    </div>
                </button>
            {/each}
        </div>
    </div>
</div>