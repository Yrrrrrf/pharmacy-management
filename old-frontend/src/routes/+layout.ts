// * TailwindCSS Layout (https://tailwindcss.com)
export const prerender = true
export const ssr = false


// * Main App Layout
import { schemaApiStore } from "$lib/stores";

export async function load() {
    await schemaApiStore.loadSchemas();
    return {};
}

// * Some(?) Layouts
// import { Layout } from '$lib/layout';