import { availableThemes, customThemes } from './src/lib/stores/theme';
import type { Config } from 'tailwindcss';

export default {
    content: ["./src/**/*.{html,js,ts,svelte}"],
    theme: {
		extend: {},
    },
    plugins: [require('daisyui')],
    daisyui: {
		themes: [...availableThemes, customThemes],
		themeRoot: ":root",
		styled: true,
		utils: true,
		logs: true,
		base: true,
		prefix: "",
		darkTheme: "dark",
    }
} as Config;
