<script lang="ts">
	import { ShoppingCart, X, Plus, Minus, Pill, Package } from 'lucide-svelte';

	type CartItem = {
		id: string;
		name: string;
		price: number;
		quantity: number;
		isPharma: boolean;
		image: string;
	};

	let cartItems: CartItem[] = [
		// todo: replace with actual data
		{ id: '1', name: 'Ibuprofen 400mg', price: 9.99, quantity: 2, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
		{ id: '2', name: 'Vitamin C 1000mg', price: 14.99, quantity: 1, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
		{ id: '3', name: 'Digital Thermometer', price: 24.99, quantity: 1, isPharma: false, image: '/placeholder.svg?height=80&width=80' },
		{ id: '4', name: 'Allergy Relief Tablets', price: 19.99, quantity: 1, isPharma: true, image: '/placeholder.svg?height=80&width=80' },
		{ id: '5', name: 'First Aid Kit', price: 29.99, quantity: 1, isPharma: false, image: '/placeholder.svg?height=80&width=80' },
	];

	let isCartOpen = false;

	$: totalItems = cartItems.reduce((sum, item) => sum + item.quantity, 0);
	$: subtotal = cartItems.reduce((sum, item) => sum + item.price * item.quantity, 0);
	$: tax = subtotal * 0.1; // Assuming 10% tax
	$: total = subtotal + tax;

	function toggleCart() {isCartOpen = !isCartOpen;}

	function removeItem(id: string) {cartItems = cartItems.filter(item => item.id !== id);}

	function updateQuantity(id: string, change: number) {
		cartItems = cartItems.map(item => 
		// Ensure quantity is non-negative
			item.id === id ? {...item, quantity: Math.max(0, item.quantity + change)} : item
		);
	}
</script>

<div class="relative">
<button on:click={toggleCart} class="relative p-2 border rounded-full">
	<ShoppingCart class="h-5 w-5" />
	<span class="absolute -top-2 -right-2 bg-blue-600 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
		{totalItems}
	</span>
</button>

{#if isCartOpen}
	<div class="fixed inset-0 bg-black bg-opacity-50 z-50 flex justify-end">
		<div class="bg-white w-full max-w-md h-full overflow-auto p-6">
			<div class="flex justify-between items-center mb-4">
				<h2 class="text-2xl font-bold">Your Cart</h2>
				<button on:click={toggleCart} class="text-gray-500 hover:text-gray-700">
					<X class="h-6 w-6" />
				</button>
			</div>

			<div class="space-y-4 mb-4">
				{#each cartItems as item (item.id)}
					<div class="flex items-center py-4 border-b">
						<img src={item.image} alt={item.name} class="h-20 w-20 object-cover rounded-md mr-4" />
						<div class="flex-1">
							<h3 class="font-medium">{item.name}</h3>
							<p class="text-sm text-gray-500 flex items-center">
								{#if item.isPharma}
									<Pill class="h-4 w-4 mr-1" />
									Pharmaceutical
								{:else}
									<Package class="h-4 w-4 mr-1" />
									Non-Pharmaceutical
								{/if}
							</p>
							<div class="flex items-center mt-2">
								<button on:click={() => updateQuantity(item.id, -1)} class="p-1 border rounded-full">
									<Minus class="h-4 w-4" />
								</button>
								<span class="mx-2">Qty {item.quantity}</span>
								<button on:click={() => updateQuantity(item.id, 1)} class="p-1 border rounded-full">
									<Plus class="h-4 w-4" />
								</button>
							</div>
						</div>
						<div class="text-right">
							<p class="font-medium">${(item.price * item.quantity).toFixed(2)}</p>
							<button on:click={() => removeItem(item.id)} class="text-sm text-red-600 hover:text-red-800">
								Remove
							</button>
						</div>
					</div>
				{/each}
			</div>

			<div class="border-t pt-4">
				<div class="flex justify-between py-2">
					<span>Subtotal</span>
					<span>${subtotal.toFixed(2)}</span>
				</div>
				<div class="flex justify-between py-2">
					<span>Tax</span>
					<span>${tax.toFixed(2)}</span>
				</div>
				<div class="flex justify-between py-2 font-bold">
					<span>Total</span>
					<span>${total.toFixed(2)}</span>
				</div>
				<button class="w-full mt-4 bg-blue-600 text-white py-2 rounded-md hover:bg-blue-700">
					Proceed to Checkout
				</button>
			</div>
		</div>
	</div>
{/if}
</div>
