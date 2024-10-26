import adapter from "@sveltejs/adapter-auto";
// import { vitePreprocess } from 'svelte-preprocess';

// add some static adapter
// import adapter from '@sveltejs/adapter-static';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    adapter: adapter(),
  },
  // preprocess: vitePreprocess(),  // useful when using svelte-preprocess
};

export default config;
