// src/lib/stores/schemaApi.ts
import { writable, get } from 'svelte/store';
import type { SchemaTypes } from '$lib/api/schema-generator';
import { generateSchemaTypes, generateTypeDeclarations } from '$lib/api/schema-generator';
import { generateApiForSchema } from '$lib/api/crud';

interface SchemaStore {
    schemas: SchemaTypes;
    isLoading: boolean;
    error: string | null;
}

function createSchemaApiStore() {
    const { subscribe, set, update } = writable<SchemaStore>({
        schemas: {},
        isLoading: false,
        error: null,
    });

    let api: ReturnType<typeof generateApiForSchema> | null = null;

    return {
        subscribe,
        loadSchemas: async () => {
            update(state => ({ ...state, isLoading: true }));
            try {
                const schemas = await generateSchemaTypes();
                set({ schemas, isLoading: false, error: null });
                
                // Generate API
                api = generateApiForSchema(schemas);
                
                // Generate type declarations (optional)
                const typeDeclarations = generateTypeDeclarations(schemas);
                console.log('Schema types generated successfully');
                console.log(typeDeclarations);

                return api;
            } catch (error) {
                set({ schemas: {}, isLoading: false, error: (error as Error).message });
                throw error;
            }
        },
        getApi: () => {
            const { schemas } = get({ subscribe });
            if (!schemas) {
                throw new Error('Schemas not loaded. Call loadSchemas() first.');
            }
            return api;
        },
        reset: () => {
            set({ schemas: {}, isLoading: false, error: null });
            api = null;
        },
    };
}

export const schemaApiStore = createSchemaApiStore();