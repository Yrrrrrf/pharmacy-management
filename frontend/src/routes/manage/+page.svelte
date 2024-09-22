<script lang="ts">
    import { onMount } from 'svelte';
    import SchemaAccordion from '$lib/components/SchemaAccordion.svelte';
    import LoadingIndicator from '$lib/components/LoadingIndicator.svelte';
    import ErrorDisplay from '$lib/components/ErrorDisplay.svelte';
    import { schemaApiStore } from '$lib/stores/schemas';
    import type { SchemaTypes } from '$lib/api/schema-generator';

    let loading: boolean;
    let error: string | null;
    let schemas: SchemaTypes;

    onMount(async () => {
        // check if schemas are already loaded...
        // todo: Put this in the stores/schemas.ts file as a getter
        if (Object.keys($schemaApiStore.schemas).length === 0 && !$schemaApiStore.isLoading) {
            await schemaApiStore.loadSchemas();
        }
    });

    $: ({ isLoading: loading, error, schemas } = $schemaApiStore);
</script>

<svelte:head>
    <title>Academic Hub - Manage</title>
</svelte:head>

<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold mb-6">Manage Database Tables</h1>

    {#if loading}
        <LoadingIndicator />
    {:else if error}
        <ErrorDisplay {error} />
    {:else if Object.keys(schemas).length > 0}
        <SchemaAccordion />
    {:else}
        <p>No schema data available. Please try refreshing the page.</p>
    {/if}
</div>