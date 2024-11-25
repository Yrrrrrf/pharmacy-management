<script lang="ts">
    type DrugType = 'Patent' | 'Generic';
    type DrugNature = 'Allopathic' | 'Homeopathic';
    type Commercialization = 'I' | 'II' | 'III' | 'IV' | 'V' | 'VI';

    interface DrugForm {
        name: string;
        type: DrugType;
        nature: DrugNature;
        commercialization: Commercialization;
    }

    const { onSubmit } = $props<{
        onSubmit: (data: DrugForm) => void;
    }>();

    let formData = $state<DrugForm>({
        name: '',
        type: 'Generic',
        nature: 'Allopathic',
        commercialization: 'I'
    });

    async function handleSubmit(e: Event) {
        e.preventDefault();
        
        const submitData = {
            id: crypto.randomUUID(),
            name: formData.name,
            type: formData.type,
            nature: formData.nature,
            commercialization: formData.commercialization
        };

        console.log('Submitting data:', JSON.stringify(submitData));

        try {
            const response = await fetch('http://localhost:8000/pharma/drug', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(submitData)
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(JSON.stringify(errorData, null, 2));
            }

            const result = await response.json();
            console.log('Drug created successfully:', result);
            onSubmit(formData);
        } catch (error) {
            console.error('Error creating drug:', error);
        }
    }
</script>

<form class="space-y-4" onsubmit={handleSubmit}>
    <div class="form-control">
        <label class="label" for="drug-name">Name</label>
        <input
            id="drug-name"
            type="text"
            class="input input-bordered"
            bind:value={formData.name}
            placeholder="Drug name"
            required
        />
    </div>

    <div class="form-control">
        <label class="label" for="drug-type">Type</label>
        <select 
            id="drug-type"
            class="select select-bordered"
            bind:value={formData.type}
            required
        >
            <option value="Generic">Generic</option>
            <option value="Patent">Patent</option>
        </select>
    </div>

    <div class="form-control">
        <label class="label" for="drug-nature">Nature</label>
        <select 
            id="drug-nature"
            class="select select-bordered"
            bind:value={formData.nature}
            required
        >
            <option value="Allopathic">Allopathic</option>
            <option value="Homeopathic">Homeopathic</option>
        </select>
    </div>

    <div class="form-control">
        <label class="label" for="drug-commercialization">Commercialization Level</label>
        <select 
            id="drug-commercialization"
            class="select select-bordered"
            bind:value={formData.commercialization}
            required
        >
            {#each ['I', 'II', 'III', 'IV', 'V', 'VI'] as level}
                <option value={level}>Level {level}</option>
            {/each}
        </select>
    </div>

    <div class="alert alert-info mt-4" role="alert">
        <span class="text-sm">
            Levels III and above require prescription
        </span>
    </div>

    <button type="submit" class="btn btn-primary w-full">
        Create Drug
    </button>
</form>
