<script lang="ts">
	import { Pill, Droplet, ShoppingBag, Stethoscope, Zap, Package } from 'lucide-svelte';

	export let product: {
		id: string;
		name: string;
		type: string;
		nature: string;
		commercialization: string;
		pathologies: { name: string }[];
		effects: { name: string }[];
		form: { name: string };
		concentration: string;
		price: number;
		stock: number;
		image_url?: string;
	};

	const getCommercializationColor = (commercialization: string) => {
		switch (commercialization) {
		case 'Over the Counter': return 'bg-green-500';
		case 'Prescription': return 'bg-blue-500';
		case 'Controlled Substance': return 'bg-red-500';
		default: return 'bg-gray-500';
		}
	};

	function getInitials(name: string) {
	return name.split(' ').map(word => word[0]).join('').toUpperCase();
	}

	function getRandomColor() {
	const colors = ['bg-blue-100', 'bg-green-100', 'bg-yellow-100', 'bg-red-100', 'bg-indigo-100', 'bg-purple-100'];
	return colors[Math.floor(Math.random() * colors.length)];
	}

</script>

<div class="bg-white rounded-lg shadow-lg overflow-hidden transition-all duration-300 hover:shadow-xl hover:-translate-y-1 max-w-sm">
	<div class="relative h-48">
	  {#if product.image_url}
		<img src={product.image_url} alt={product.name} class="w-full h-full object-cover" />
	  {:else}
		<div class="w-full h-full flex flex-col items-center justify-center {getRandomColor()} bg-opacity-50">
		  <div class="text-4xl font-bold text-gray-700 mb-2">{getInitials(product.name)}</div>
		  <div class="text-sm text-gray-600 text-center px-4">
			<Pill class="inline-block w-4 h-4 mr-1" />
			{product.name}
		  </div>
		</div>
	  {/if}
	  <div class="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent"></div>
	  <span class="absolute top-2 right-2 px-2 py-1 rounded-full text-xs font-semibold text-white {getCommercializationColor(product.commercialization)}">
		{product.commercialization}
	  </span>
	</div>

	<div class="p-4">
		<h2 class="text-xl font-bold mb-2 text-gray-800">{product.name}</h2>
		<div class="flex space-x-2 mb-2">
		<span class="px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">{product.type}</span>
		<span class="px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">{product.nature}</span>
		</div>
		<p class="text-2xl font-bold text-green-600 mb-2">${product.price.toFixed(2)}</p>
		<p class="text-sm mb-2 {product.stock > 100 ? 'text-green-600' : 'text-red-600'}">
		Stock: {product.stock}
		</p>
		<div class="flex space-x-2 mb-2">
		<span class="flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">
			<Pill class="w-4 h-4 mr-1" />{product.form.name}
		</span>
		<span class="flex items-center px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">
			<Droplet class="w-4 h-4 mr-1" />{product.concentration}
		</span>
		</div>
		<div class="mb-2">
		<p class="font-semibold text-gray-700 mb-1 flex items-center">
			<Stethoscope class="w-4 h-4 mr-1" />Pathologies:
		</p>
		<div class="flex flex-wrap gap-1">
			{#each product.pathologies as pathology}
			<span class="px-2 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800">{pathology.name}</span>
			{/each}
		</div>
		</div>
		<div>
		<p class="font-semibold text-gray-700 mb-1 flex items-center">
			<Zap class="w-4 h-4 mr-1" />Effects:
		</p>
		<div class="flex flex-wrap gap-1">
			{#each product.effects as effect}
			<span class="px-2 py-1 rounded-full text-xs font-semibold border border-blue-300 text-blue-800">{effect.name}</span>
			{/each}
		</div>
		</div>
	</div>

	<div class="p-4 bg-gray-50">
		<button class="w-full py-2 px-4 rounded-full font-semibold transition-colors duration-300 bg-blue-500 text-white hover:bg-blue-600 flex items-center justify-center">
		<ShoppingBag class="w-4 h-4 mr-1" />
		Add to Cart
		</button>
	</div>
</div>