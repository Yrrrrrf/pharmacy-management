<script lang="ts">
    let isHovered = false;

    export let product = {
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
    };
</script>

<div class="product-card" 
        on:mouseenter={() => isHovered = true} 
        on:mouseleave={() => isHovered = false}>
    <div class="image-container">
    <img src={product.image_url} alt={product.name} class="product-image" class:hovered={isHovered} />
    <div class="image-overlay"></div>
    <span class="badge commercialization">{product.commercialization}</span>
    {#if isHovered}
        <div class="hover-buttons">
        <button class="btn secondary">Quick View</button>
        <button class="btn secondary">Add to Cart</button>
        </div>
    {/if}
    </div>
    <div class="product-info">
    <div class="product-header">
        <div>
        <h2 class="product-title">{product.name}</h2>
        <p class="product-subtitle">{product.type} | {product.nature}</p>
        </div>
        <div class="price-stock">
        <p class="price">${product.price.toFixed(2)}</p>
        <p class="stock" class:in-stock={product.stock > 100}>
            Stock: {product.stock}
        </p>
        </div>
    </div>
    <div class="product-details">
        <div class="form-concentration">
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
    </div>
    <div class="product-footer">
    <p class="storage-info">Store at room temperature</p>
    <button class="btn primary">Add to Cart</button>
    </div>
</div>

<style>
    .product-card {
    max-width: 400px;
    background: linear-gradient(to bottom right, white, #f0f0f0);
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transition: box-shadow 0.3s ease;
    }
    .product-card:hover {
    box-shadow: 0 10px 15px rgba(0, 0, 0, 0.2);
    }
    .image-container {
    position: relative;
    height: 224px;
    overflow: hidden;
    }
    .product-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.5s ease;
    }
    .product-image.hovered {
    transform: scale(1.1);
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
    .hover-buttons {
    position: absolute;
    bottom: 8px;
    left: 8px;
    right: 8px;
    display: flex;
    justify-content: space-between;
    }
    .btn {
    padding: 6px 12px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 0.875rem;
    }
    .btn.secondary {
    background-color: rgba(255, 255, 255, 0.8);
    }
    .btn.secondary:hover {
    background-color: white;
    }
    .product-info {
    padding: 16px;
    }
    .product-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 16px;
    }
    .product-title {
    font-size: 1.5rem;
    font-weight: bold;
    background: linear-gradient(to right, #007bff, #00bfff);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin: 0;
    }
    .product-subtitle {
    font-size: 0.875rem;
    color: #666;
    margin: 4px 0 0;
    }
    .price-stock {
    text-align: right;
    }
    .price {
    font-size: 1.5rem;
    font-weight: bold;
    color: #007bff;
    margin: 0;
    }
    .stock {
    font-size: 0.875rem;
    margin: 4px 0 0;
    }
    .stock.in-stock {
    color: #28a745;
    }
    .form-concentration {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
    }
    .badge.primary {
    background-color: rgba(0, 123, 255, 0.1);
    color: #007bff;
    }
    .section-title {
    font-weight: 600;
    margin-bottom: 8px;
    }
    .badge-container {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
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
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: linear-gradient(to right, rgba(0, 123, 255, 0.05), rgba(0, 191, 255, 0.05));
    }
    .storage-info {
    font-size: 0.875rem;
    color: #666;
    }
    .btn.primary {
    background: linear-gradient(to right, #007bff, #00bfff);
    color: white;
    }
    .btn.primary:hover {
    opacity: 0.9;
    }
</style>