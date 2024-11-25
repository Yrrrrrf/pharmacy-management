<script lang="ts">
    import { onMount } from 'svelte';

    interface Pharmaceutical {
        id: string;
        name: string;  // This should be pharmaceutical name + concentration
    }

    interface Category {
        category_id: string;
        name: string;
    }

    interface ProductForm {
        product_id: string;
        pharma_product_id: string | null;
        sku: string;
        name: string;
        description: string;
        unit_price: number;
        category_id: string;
    }

    const { onSubmit } = $props<{
        onSubmit: (data: ProductForm) => void;
    }>();

    // State management
    let pharmaceuticals = $state<Pharmaceutical[]>([]);
    let categories = $state<Category[]>([]);
    let isLoading = $state(false);
    let error = $state<string | null>(null);

    let formData = $state<ProductForm>({
        product_id: crypto.randomUUID(),
        pharma_product_id: null,
        sku: '',
        name: '',
        description: '',
        unit_price: 0,
        category_id: ''
    });

    onMount(async () => {
        try {
            isLoading = true;
            const [pharmaResponse, categoriesResponse] = await Promise.all([
                fetch('http://localhost:8000/pharma/pharmaceutical'),
                fetch('http://localhost:8000/management/categories')
            ]);

            if (!pharmaResponse.ok || !categoriesResponse.ok) {
                throw new Error('Failed to fetch data');
            }

            pharmaceuticals = await pharmaResponse.json();
            categories = await categoriesResponse.json();

            console.log('Loaded pharmaceuticals:', pharmaceuticals);
            console.log('Loaded categories:', categories);
        } catch (err) {
            console.error('Error fetching data:', err);
            error = 'Failed to load data';
        } finally {
            isLoading = false;
        }
    });

    async function handleSubmit(e: Event) {
        e.preventDefault();
        error = null;

        const submitData = {
            ...formData,
            unit_price: Number(formData.unit_price)  // Ensure price is a number
        };

        try {
            const response = await fetch('http://localhost:8000/management/products', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(submitData)
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || 'Failed to create product');
            }

            const result = await response.json();
            console.log('Success:', result);
            onSubmit(submitData);
        } catch (err) {
            console.error('Error:', err);
            error = err instanceof Error ? err.message : 'An error occurred';
        }
    }

    // Generate SKU automatically when name changes
    $effect(() => {
        if (formData.name) {
            formData.sku = formData.name
                .toUpperCase()
                .replace(/[^A-Z0-9]/g, '')
                .substring(0, 8) + '-' + 
                Math.random().toString(36).substring(2, 6).toUpperCase();
        }
    });
</script>

<form class="space-y-4" onsubmit={handleSubmit}>
    {#if isLoading}
        <div class="alert alert-info">Loading data...</div>
    {/if}

    {#if error}
        <div class="alert alert-error">
            <span>{error}</span>
        </div>
    {/if}

    <div class="form-control">
        <label class="label" for="pharma-select">Pharmaceutical Product</label>
        <select 
            id="pharma-select"
            class="select select-bordered"
            bind:value={formData.pharma_product_id}
        >
            <option value="">None (Regular Product)</option>
            {#each pharmaceuticals as pharma}
                <option value={pharma.id}>{pharma.name}</option>
            {/each}
        </select>
    </div>

    <div class="form-control">
        <label class="label" for="name">Product Name</label>
        <input
            id="name"
            type="text"
            class="input input-bordered"
            bind:value={formData.name}
            placeholder="Product name"
            required
        />
    </div>

    <div class="form-control">
        <label class="label" for="sku">SKU</label>
        <input
            id="sku"
            type="text"
            class="input input-bordered"
            bind:value={formData.sku}
            placeholder="Auto-generated SKU"
            readonly
        />
        <label class="label">
            <span class="label-text-alt">Auto-generated based on name</span>
        </label>
    </div>

    <div class="form-control">
        <label class="label" for="description">Description</label>
        <textarea
            id="description"
            class="textarea textarea-bordered h-24"
            bind:value={formData.description}
            placeholder="Product description"
        ></textarea>
    </div>

    <div class="form-control">
        <label class="label" for="price">Unit Price</label>
        <input
            id="price"
            type="number"
            step="0.01"
            min="0"
            class="input input-bordered"
            bind:value={formData.unit_price}
            placeholder="0.00"
            required
        />
    </div>

    <div class="form-control">
        <label class="label" for="category-select">Category</label>
        <select 
            id="category-select"
            class="select select-bordered"
            bind:value={formData.category_id}
            required
        >
            <option value="">Select a category...</option>
            {#each categories as category}
                <option value={category.category_id}>{category.name}</option>
            {/each}
        </select>
    </div>

    <!-- Debug Information -->
    <div class="mt-4 p-4 bg-base-200 rounded-lg text-sm">
        <h3 class="font-bold mb-2">Form Data:</h3>
        <pre class="text-xs overflow-auto">
{JSON.stringify(formData, null, 2)}
        </pre>
    </div>

    <button 
        type="submit" 
        class="btn btn-primary w-full"
        disabled={isLoading}
    >
        Create Product
    </button>
</form>
