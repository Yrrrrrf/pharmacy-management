import { availableThemes, customThemes } from './src/lib/theme';
import daisyui from 'daisyui';


/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{html,js,ts,svelte}"],
  theme: {
    extend: {},
  },
  plugins: [daisyui],
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
}