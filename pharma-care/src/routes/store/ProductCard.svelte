<script lang="ts">
	import { Badge } from 'lucide-svelte';
	import type { BaseProduct } from '$lib/api/types';

	export let product: BaseProduct;
  
	// Helper functions with null checks
	function getInitials(name: string | null): string {
	  if (!name) return 'N/A';
	  return name
		.split(' ')
		.map(word => word[0])
		.join('')
		.toUpperCase()
		.slice(0, 2);
	}
  
	// Format price with proper handling of null/undefined
	function formatPrice(price: string | null): string {
	  if (!price) return 'N/A';
	  try {
		return new Intl.NumberFormat('en-US', {
		  style: 'currency',
		  currency: 'USD'
		}).format(Number(price));
	  } catch {
		return 'Invalid Price';
	  }
	}

	function addToCart(product: BaseProduct) {
		console.log('Adding product to cart:', product);
	}
  </script>
  
  <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow duration-200">
	<div class="card-body">
	  <!-- Product Header -->
	  <div class="flex items-center gap-4">
		<div class="avatar placeholder">
		  <div class="bg-neutral text-neutral-content rounded-full w-12">
			<span>{getInitials(product?.product_name)}</span>
		  </div>
		</div>
		
		<div class="flex-1">
		  <h2 class="card-title text-lg">
			{product?.product_name ?? 'Unnamed Product'}
		  </h2>
		  <p class="text-sm opacity-60">
			SKU: {product?.sku ?? 'No SKU'}
		  </p>
		</div>
	  </div>
  
	  <!-- Product Info -->
	  <div class="mt-4 space-y-2">
		<p class="text-sm line-clamp-2">
		  {product?.description ?? 'No description available'}
		</p>
  
		<!-- Tags/Badges -->
		<div class="flex flex-wrap gap-2">
		  {#if product?.drug_type}
			<span class="badge badge-primary">{product.drug_type}</span>
		  {/if}
		  {#if product?.category_name}
			<span class="badge">{product.category_name}</span>
		  {/if}
		  {#if product?.form_name}
			<span class="badge badge-outline">{product.form_name}</span>
		  {/if}
		</div>
  
		<!-- Pharmaceutical Details -->
		{#if product?.pharma_concentration}
		  <div class="text-sm">
			<span class="opacity-60">Concentration:</span> {product.pharma_concentration}
		  </div>
		{/if}
	  </div>
  
	  <!-- Price and Actions -->
	  <div class="card-actions justify-between items-center mt-4">
		<div class="text-xl font-bold">
		  {formatPrice(product?.unit_price)}
		</div>
		
		<div class="flex gap-2">
		  <button class="btn btn-circle btn-ghost btn-sm">
			<Badge class="w-4 h-4" />
		  </button>
		  <button class="btn btn-primary btn-sm" onclick={() => addToCart(product)}>
			Add to Cart
		  </button>
		</div>
	  </div>
	</div>
  </div>
