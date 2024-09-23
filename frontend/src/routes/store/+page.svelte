<script lang="ts">
    import { onMount } from 'svelte';

    let products = [
        {
        id: "PROD001",
        name: "Ibuprofen 400mg Tablets",
        type: "Generic",
        nature: "Allopathic",
        commercialization: "Over the Counter",
        pathologies: [{ name: "Pain" }, { name: "Inflammation" }],
        effects: [{ name: "Analgesic" }, { name: "Anti-inflammatory" }],
        form: { name: "Tablet" },
        concentration: "400mg",
        price: 9.99,
        stock: 500,
        image_url: "https://example.com/ibuprofen-400mg.jpg"
        },
        {
        id: "PROD002",
        name: "Amoxicillin 500mg Capsules",
        type: "Generic",
        nature: "Allopathic",
        commercialization: "Prescription",
        pathologies: [{ name: "Bacterial Infections" }],
        effects: [{ name: "Antibiotic" }],
        form: { name: "Capsule" },
        concentration: "500mg",
        price: 15.99,
        stock: 300,
        image_url: "https://example.com/amoxicillin-500mg.jpg"
        },
        // ... other products ...
    ];

    let searchQuery = '';
    let typeFilter = 'all';
    let natureFilter = 'all';
    let commercializationFilter = 'all';

    $: filteredProducts = products.filter(product => {
        const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase());
        const matchesType = typeFilter === 'all' || product.type === typeFilter;
        const matchesNature = natureFilter === 'all' || product.nature === natureFilter;
        const matchesCommercialization = commercializationFilter === 'all' || product.commercialization === commercializationFilter;
        return matchesSearch && matchesType && matchesNature && matchesCommercialization;
    });

    let isLoading = true;
    onMount(() => {
        setTimeout(() => {
        isLoading = false;
        }, 1000);
    });
</script>

<div class="container">
    <h1>Pharmaceutical Product Catalog</h1>

    <div class="filters-container">
    <div class="filter-item">
        <label for="search">Search Products</label>
        <input id="search" type="text" placeholder="Search by name..." bind:value={searchQuery} />
    </div>
    <div class="filter-item">
        <label for="type">Type</label>
        <select id="type" bind:value={typeFilter}>
        <option value="all">All Types</option>
        <option value="Generic">Generic</option>
        <option value="Brand">Brand</option>
        </select>
    </div>
    <div class="filter-item">
        <label for="nature">Nature</label>
        <select id="nature" bind:value={natureFilter}>
        <option value="all">All Natures</option>
        <option value="Allopathic">Allopathic</option>
        <option value="Homeopathic">Homeopathic</option>
        </select>
    </div>
    <div class="filter-item">
        <label for="commercialization">Commercialization</label>
        <select id="commercialization" bind:value={commercializationFilter}>
        <option value="all">All</option>
        <option value="Over the Counter">Over the Counter</option>
        <option value="Prescription">Prescription</option>
        </select>
    </div>
    </div>

    {#if isLoading}
    <div class="loading">
        <div class="spinner"></div>
    </div>
    {:else}
    {#if filteredProducts.length > 0}
        <div class="product-grid">
        {#each filteredProducts as product (product.id)}
            <div class="product-card">
            <div class="image-container">
                <img src={product.image_url} alt={product.name} class="product-image" />
                <div class="image-overlay"></div>
                <span class="badge commercialization">{product.commercialization}</span>
            </div>
            <div class="product-info">
                <h2 class="product-title">{product.name}</h2>
                <p class="product-subtitle">{product.type} | {product.nature}</p>
                <p class="price">${product.price.toFixed(2)}</p>
                <p class="stock" class:in-stock={product.stock > 100}>
                Stock: {product.stock}
                </p>
                <div class="product-details">
                <span class="badge primary">{product.form.name}</span>
                <span class="badge primary">{product.concentration}</span>
                </div>
                <div class="pathologies">
                <p class="section-title">Pathologies:</p>
                <div class="badge-container">
                    {#each product.pathologies as pathology}
                    <span class="badge secondary">{pathology.name}</span>
                    {/each}
                </div>
                </div>
                <div class="effects">
                <p class="section-title">Effects:</p>
                <div class="badge-container">
                    {#each product.effects as effect}
                    <span class="badge outline">{effect.name}</span>
                    {/each}
                </div>
                </div>
            </div>
            <div class="product-footer">
                <button class="btn primary">Add to Cart</button>
            </div>
            </div>
        {/each}
        </div>
    {:else}
        <div class="no-results">
        <h2>No products found</h2>
        <p>Try adjusting your search or filter criteria</p>
        </div>
    {/if}
    {/if}
</div>

<style>
    .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
    font-family: Arial, sans-serif;
    }
    h1 {
    font-size: 2rem;
    margin-bottom: 1.5rem;
    text-align: center;
    }
    .filters-container {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    margin-bottom: 2rem;
    padding: 1rem;
    background-color: #f5f5f5;
    border-radius: 0.5rem;
    }
    .filter-item {
    flex: 1;
    min-width: 200px;
    }
    label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: bold;
    }
    input, select {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ccc;
    border-radius: 0.25rem;
    }
    .loading {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 200px;
    }
    .spinner {
    border: 4px solid #f3f3f3;
    border-top: 4px solid #007bff;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    animation: spin 1s linear infinite;
    }
    @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
    }
    .product-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 2rem;
    }
    .product-card {
    background-color: white;
    border-radius: 0.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    overflow: hidden;
    transition: transform 0.3s ease;
    }
    .product-card:hover {
    transform: translateY(-5px);
    }
    .image-container {
    position: relative;
    height: 200px;
    }
    .product-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    }
    .image-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.5), transparent);
    }
    .badge {
    padding: 4px 8px;
    border-radius: 16px;
    font-size: 0.875rem;
    font-weight: 600;
    }
    .badge.commercialization {
    position: absolute;
    top: 8px;
    right: 8px;
    background-color: #007bff;
    color: white;
    }
    .product-info {
    padding: 1rem;
    }
    .product-title {
    font-size: 1.25rem;
    font-weight: bold;
    margin: 0 0 0.5rem;
    }
    .product-subtitle {
    font-size: 0.875rem;
    color: #666;
    margin-bottom: 0.5rem;
    }
    .price {
    font-size: 1.25rem;
    font-weight: bold;
    color: #007bff;
    margin-bottom: 0.25rem;
    }
    .stock {
    font-size: 0.875rem;
    color: #666;
    }
    .stock.in-stock {
    color: #28a745;
    }
    .product-details {
    margin-top: 1rem;
    }
    .badge.primary {
    background-color: rgba(0, 123, 255, 0.1);
    color: #007bff;
    }
    .section-title {
    font-weight: 600;
    margin: 0.5rem 0;
    }
    .badge-container {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    }
    .badge.secondary {
    background-color: #f0f0f0;
    color: #333;
    }
    .badge.outline {
    border: 1px solid rgba(0, 123, 255, 0.3);
    color: #007bff;
    }
    .product-footer {
    padding: 1rem;
    background-color: #f5f5f5;
    }
    .btn {
    width: 100%;
    padding: 0.5rem;
    border: none;
    border-radius: 0.25rem;
    font-weight: bold;
    cursor: pointer;
    }
    .btn.primary {
    background-color: #007bff;
    color: white;
    }
    .no-results {
    text-align: center;
    padding: 2rem;
    }
    .no-results h2 {
    font-size: 1.5rem;
    color: #666;
    margin-bottom: 0.5rem;
    }
    .no-results p {
    color: #888;
    }
</style>