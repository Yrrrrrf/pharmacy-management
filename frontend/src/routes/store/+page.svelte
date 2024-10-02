<script lang="ts">
import { onMount } from 'svelte';
import ProductCard from './ProductCard.svelte';
import FilterBar from './FilterBar.svelte';
import { Search } from 'lucide-svelte';

export const products = [
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
    {
        id: "PROD003",
        name: "Loratadine 10mg Tablets",
        type: "Brand Name",
        nature: "Allopathic",
        commercialization: "Over the Counter",
        pathologies: [{ name: "Allergies" }],
        effects: [{ name: "Antihistamine" }],
        form: { name: "Tablet" },
        concentration: "10mg",
        price: 12.50,
        stock: 400,
        image_url: "https://example.com/loratadine-10mg.jpg"
    },
    {
        id: "PROD004",
        name: "Metformin 850mg Tablets",
        type: "Generic",
        nature: "Allopathic",
        commercialization: "Prescription",
        pathologies: [{ name: "Diabetes" }],
        effects: [{ name: "Antihyperglycemic" }],
        form: { name: "Tablet" },
        concentration: "850mg",
        price: 8.75,
        stock: 600,
        image_url: "https://example.com/metformin-850mg.jpg"
    },
    {
        id: "PROD005",
        name: "Arnica Montana 30C",
        type: "Generic",
        nature: "Homeopathic",
        commercialization: "Over the Counter",
        pathologies: [{ name: "Bruising" }, { name: "Muscle Soreness" }],
        effects: [{ name: "Anti-inflammatory" }],
        form: { name: "Pellets" },
        concentration: "30C",
        price: 7.99,
        stock: 200,
        image_url: "https://example.com/arnica-montana-30c.jpg"
    },
    {
        id: "PROD006",
        name: "Morphine Sulfate 10mg/mL Injection",
        type: "Generic",
        nature: "Allopathic",
        commercialization: "Controlled Substance",
        pathologies: [{ name: "Severe Pain" }],
        effects: [{ name: "Analgesic" }, { name: "Opioid" }],
        form: { name: "Injection" },
        concentration: "10mg/mL",
        price: 45.00,
        stock: 100,
        image_url: "https://example.com/morphine-sulfate-injection.jpg"
    },
    {
        id: "PROD007",
        name: "Ashwagandha Root Extract 500mg",
        type: "Generic",
        nature: "Ayurvedic",
        commercialization: "Over the Counter",
        pathologies: [{ name: "Stress" }, { name: "Anxiety" }],
        effects: [{ name: "Adaptogen" }, { name: "Anxiolytic" }],
        form: { name: "Capsule" },
        concentration: "500mg",
        price: 18.99,
        stock: 350,
        image_url: "https://example.com/ashwagandha-500mg.jpg"
    },
    {
        id: "PROD008",
        name: "Salbutamol 100mcg Inhaler",
        type: "Generic",
        nature: "Allopathic",
        commercialization: "Prescription",
        pathologies: [{ name: "Asthma" }, { name: "COPD" }],
        effects: [{ name: "Bronchodilator" }],
        form: { name: "Inhaler" },
        concentration: "100mcg/dose",
        price: 25.50,
        stock: 250,
        image_url: "https://example.com/salbutamol-inhaler.jpg"
    }
];

let searchQuery = '';
  let filters = {
    drugType: 'all',
    drugNature: 'all',
    commercialization: 'all',
    pathology: 'all',
    effect: 'all',
    pharmaceuticForm: 'all',
    administrationRoute: 'all',
    usageConsideration: 'all'
  };

  $: filteredProducts = products.filter(product => {
    const matchesSearch = searchQuery === '' || product.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = filters.drugType === 'all' || product.type === filters.drugType;
    const matchesNature = filters.drugNature === 'all' || product.nature === filters.drugNature;
    const matchesCommercialization = filters.commercialization === 'all' || product.commercialization === filters.commercialization;
    const matchesPathology = filters.pathology === 'all' || product.pathologies.some(p => p.name === filters.pathology);
    const matchesEffect = filters.effect === 'all' || product.effects.some(e => e.name === filters.effect);
    const matchesForm = filters.pharmaceuticForm === 'all' || product.form.name === filters.pharmaceuticForm;
    // Add checks for administrationRoute and usageConsideration if your product data includes these fields

    return matchesSearch && matchesType && matchesNature && matchesCommercialization && 
           matchesPathology && matchesEffect && matchesForm;
  });

  let isLoading = true;
  onMount(() => {
    isLoading = false; // Simulate data loading
  });

</script>

<FilterBar bind:searchQuery bind:filters />

{#if isLoading}
    <div class="flex justify-center items-center h-64">
    <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-gray-900"></div>
    </div>
{:else if filteredProducts.length > 0}
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mt-6">
    {#each filteredProducts as product (product.id)}
        <ProductCard {product} />
    {/each}
    </div>
{:else}
    <div class="text-center py-12">
    <Search class="mx-auto h-12 w-12 text-gray-400" />
    <h3 class="mt-2 text-sm font-medium text-gray-900">No products found</h3>
    <p class="mt-1 text-sm text-gray-500">Try adjusting your search or filter criteria.</p>
    </div>
{/if}
