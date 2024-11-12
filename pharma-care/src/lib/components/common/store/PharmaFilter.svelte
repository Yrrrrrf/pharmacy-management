components/filters/PharmaFilter.svelte
<script lang="ts">
    import { Activity } from 'lucide-svelte';
    import { filters } from '$lib/stores/products';
    
    export let options: {
        forms: string[];
        routes: string[];
        considerations: string[];
        
    };
</script>

<div class="space-y-4">
    <h3 class="text-lg font-semibold flex items-center gap-2">
        <Activity class="h-5 w-5 text-primary" />
        Product Properties
    </h3>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="form-control">
            <label class="label" for="pharmaceuticForm">Pharmaceutic Form</label>
            <select 
                id="pharmaceuticForm"
                class="select select-bordered w-full"
                bind:value={$filters.pharmaceuticForm}
            >
                <option value="all">Select Form</option>
                {#each options.forms as form}
                    <option value={form}>{form}</option>
                {/each}
            </select>
        </div>

        <div class="form-control">
            <label class="label" for="administrationRoute">Administration Route</label>
            <select 
                id="administrationRoute"
                class="select select-bordered w-full"
                bind:value={$filters.administrationRoute}
            >
                <option value="all">Select Route</option>
                {#each options.routes as route}
                    <option value={route}>{route}</option>
                {/each}
            </select>
        </div>

        <div class="form-control">
            <label class="label" for="usageConsideration">Usage Consideration</label>
            <select 
                id="usageConsideration"
                class="select select-bordered w-full"
                bind:value={$filters.usageConsideration}
            >
                <option value="all">Select Usage</option>
                {#each options.considerations as consideration}
                    <option value={consideration}>{consideration}</option>
                {/each}
            </select>
        </div>

        <div class="form-control">
            <label class="label" for="concentration">Concentration</label>
            <input 
                id="concentration"
                type="text"
                placeholder="e.g., 500mg"
                class="input input-bordered w-full"
                bind:value={$filters.concentration}
            />
        </div>
    </div>
</div>