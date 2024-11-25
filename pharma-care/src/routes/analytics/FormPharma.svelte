<script lang="ts">
    import { onMount } from 'svelte';

    interface Drug {
        id: string;
        name: string;
    }

    interface Form {
        id: string;
        name: string;
    }

    interface PharmaceuticalForm {
        drug_id: string;
        form_id: string;
        concentration: string;
    }

    const { onSubmit } = $props<{
        onSubmit: (data: PharmaceuticalForm) => void;
    }>();

    let drugs = $state<Drug[]>([]);
    let forms = $state<Form[]>([]);
    let error = $state<string | null>(null);
    let isLoading = $state(false);
    let selectedDrug = $state<Drug | null>(null);
    let selectedForm = $state<Form | null>(null);

    let formData = $state<PharmaceuticalForm>({
        drug_id: '',
        form_id: '',
        concentration: ''
    });

    // Load data
    onMount(async () => {
        try {
            isLoading = true;
            const [drugsResponse, formsResponse] = await Promise.all([
                fetch('http://localhost:8000/pharma/drug'),
                fetch('http://localhost:8000/pharma/form')
            ]);

            if (!drugsResponse.ok || !formsResponse.ok) {
                throw new Error('Failed to fetch data');
            }

            drugs = await drugsResponse.json();
            forms = await formsResponse.json();
            
            console.log('Loaded drugs:', drugs);
            console.log('Loaded forms:', forms);
        } catch (error) {
            console.error('Error fetching data:', error);
            error = 'Failed to load data';
        } finally {
            isLoading = false;
        }
    });

    // Handlers for selection
    function handleDrugSelect(event: Event) {
        const select = event.target as HTMLSelectElement;
        const drug = drugs.find(d => d.id === select.value);
        if (drug) {
            selectedDrug = drug;
            formData.drug_id = drug.id;
            console.log('Selected drug:', drug);
        }
    }

    function handleFormSelect(event: Event) {
        const select = event.target as HTMLSelectElement;
        const form = forms.find(f => f.id === select.value);
        if (form) {
            selectedForm = form;
            formData.form_id = form.id;
            console.log('Selected form:', form);
        }
    }

    async function handleSubmit(e: Event) {
        e.preventDefault();
        error = null;
        
        // Validate selections
        if (!selectedDrug || !selectedForm) {
            error = 'Please select both drug and form';
            return;
        }

        // Create submission data
        const submitData = {
            id: crypto.randomUUID(),
            drug_id: selectedDrug.id,
            form_id: selectedForm.id,
            concentration: formData.concentration
        };

        console.log('Attempting to submit:', submitData);

        try {
            const response = await fetch('http://localhost:8000/pharma/pharmaceutical', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(submitData)
            });

            if (!response.ok) {
                const errorData = await response.json();
                console.error('Server error response:', errorData);
                throw new Error(errorData.detail || 'Failed to create pharmaceutical');
            }

            const result = await response.json();
            console.log('Success response:', result);
            onSubmit(submitData);
        } catch (err) {
            console.error('Submission error:', err);
            error = err instanceof Error ? err.message : 'An error occurred';
        }
    }
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
        <label class="label" for="drug-select">Drug</label>
        <select 
            id="drug-select"
            class="select select-bordered"
            value={selectedDrug?.id || ''}
            onchange={handleDrugSelect}
            required
            disabled={isLoading}
        >
            <option value="">Select a drug...</option>
            {#each drugs as drug}
                <option value={drug.id}>{drug.name}</option>
            {/each}
        </select>
        {#if selectedDrug}
            <label class="label">
                <span class="label-text-alt">Selected: {selectedDrug.name}</span>
            </label>
        {/if}
    </div>

    <div class="form-control">
        <label class="label" for="form-select">Form</label>
        <select 
            id="form-select"
            class="select select-bordered"
            value={selectedForm?.id || ''}
            onchange={handleFormSelect}
            required
            disabled={isLoading}
        >
            <option value="">Select a form...</option>
            {#each forms as form}
                <option value={form.id}>{form.name}</option>
            {/each}
        </select>
        {#if selectedForm}
            <label class="label">
                <span class="label-text-alt">Selected: {selectedForm.name}</span>
            </label>
        {/if}
    </div>

    <div class="form-control">
        <label class="label" for="concentration">Concentration</label>
        <input
            id="concentration"
            type="text"
            class="input input-bordered"
            bind:value={formData.concentration}
            placeholder="e.g., 500mg"
            required
            disabled={isLoading}
        />
    </div>

    <!-- Debug Information -->
    <div class="mt-4 p-4 bg-base-200 rounded-lg text-sm">
        <h3 class="font-bold mb-2">Debug Info:</h3>
        <pre class="text-xs overflow-auto">
Selected Drug: {JSON.stringify(selectedDrug, null, 2)}
Selected Form: {JSON.stringify(selectedForm, null, 2)}
Form Data: {JSON.stringify(formData, null, 2)}
        </pre>
    </div>

    <button 
        type="submit" 
        class="btn btn-primary w-full"
        disabled={isLoading || !selectedDrug || !selectedForm}
    >
        Create Pharmaceutical
    </button>
</form>
