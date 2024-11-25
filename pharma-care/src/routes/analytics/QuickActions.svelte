<script lang="ts">
    import { goto } from '$app/navigation';
    import { Pill, Package, ClipboardList, Receipt, ShoppingBag, X } from 'lucide-svelte';
    import FormPharma from './FormPharma.svelte';
    import FormProduct from './FormProduct.svelte';
    import FormDrug from './FormDrug.svelte';

    type FormType = 'drug' | 'product' | 'pharmaceutical';

    interface QuickAction {
        title: string;
        icon: any;
        color: string;
        formType?: FormType;  // Optional now since not all actions open forms
        href?: string;        // For navigation actions
    }

    // State management using Runes
    let activeModal = $state<FormType | null>(null);



    const quickActions: QuickAction[] = [
        {
            title: 'New drug',
            icon: Pill,
            color: 'bg-primary/20 text-primary',
            formType: 'drug'
        },
        {
            title: 'New Pharmaceutical',
            icon: Pill,
            color: 'bg-primary/20 text-primary',
            formType: 'pharmaceutical'
        },
        {
            title: 'New Product',
            icon: Package,
            color: 'bg-secondary/20 text-secondary',
            formType: 'product'
        },
        // Navigation actions
        {
            title: 'Inventory',
            icon: ClipboardList,
            color: 'bg-success/20 text-success',
            href: '/inventory'
        },
        {
            title: 'Sales Records',
            icon: Receipt,
            color: 'bg-warning/20 text-warning',
            href: '/analytics/sales'
        },
        {
            title: 'Purchase Records',
            icon: ShoppingBag,
            color: 'bg-error/20 text-error',
            href: '/analytics/purchases'
        }
    ];

    function handleFormSubmit(formType: FormType, data: any) {
        console.log(`Submitting ${formType} form:`, data);
        // Here you would handle the form submission
        closeModal();
    }

    function closeModal() {
        activeModal = null;
    }

    // Handle keyboard navigation
    function handleKeyDown(e: KeyboardEvent) {
        if (e.key === 'Escape') {
            closeModal();
        }
    }
</script>

<svelte:window on:keydown={handleKeyDown}/>

<div class="card bg-base-100 shadow-xl">
    <div class="card-body">
        <h2 class="card-title text-center w-full justify-center mb-6">Quick Actions</h2>
        <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
            {#each quickActions as { title, icon: Icon, color, formType, href }}
                <button
                    type="button"
                    class="card bg-base-200 hover:bg-base-300 transition-all duration-300 hover:scale-105 hover:shadow-lg"
                    onclick={() => formType ? (activeModal = formType) : goto(href)}
                    onkeydown={(e) => e.key === 'Enter' && (formType ? (activeModal = formType) : goto(href))}
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

<!-- Modal -->
{#if activeModal}
    <div 
        class="modal modal-open"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modal-title"
    >
        <div class="modal-box relative">
            <button 
                type="button"
                class="btn btn-sm btn-circle absolute right-2 top-2"
                onclick={closeModal}
                aria-label="Close modal"
            >
                <X class="w-4 h-4" />
            </button>
            
            <h3 id="modal-title" class="font-bold text-lg mb-4">
                {quickActions.find(a => a.formType === activeModal)?.title}
            </h3>

            {#if activeModal === 'drug'}
                <FormDrug
                    onSubmit={(data) => handleFormSubmit('drug', data)} 
                />
            {:else if activeModal === 'pharmaceutical'}
                <FormPharma
                    onSubmit={(data) => handleFormSubmit('pharmaceutical', data)} 
                />
            {:else if activeModal === 'product'}
                <FormProduct
                    onSubmit={(data) => handleFormSubmit('product', data)} 
                />
            {:else}
                <p class="text-center text-base-content/70">
                    This feature is coming soon...
                </p>
            {/if}
        </div>
        <button
            class="modal-backdrop"
            onclick={closeModal}
            aria-label="Close modal background"
        ></button>
    </div>
{/if}
