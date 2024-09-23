import type { Config } from 'tailwindcss'
import daisyui from 'daisyui'

const config: Config = {
    content: ["./src/**/*.{html,js,ts,svelte}"],
    theme: {
        extend: {},
    },
    plugins: [daisyui],

    // daisyUI config
    daisyui: {
        themeRoot: ":root", // The element that receives theme color CSS variables
        styled: true, // include daisyUI colors and design decisions for all components
        utils: true, // adds responsive and modifier utility classes
        logs: true, // Shows info about daisyUI version and used config in the console when building your CSS
        base: true, // applies background color and foreground color for root element by default
        prefix: "", // prefix for daisyUI classnames (components, modifiers and responsive class names. Not colors)
        darkTheme: "dark", // name of one of the included themes for dark mode
        themes: [
            "light",
            "dark",
            "cupcake",
            "bumblebee",
            "emerald",
            "corporate",
            "synthwave",
            "retro",
            "cyberpunk",
            "valentine",
            "halloween",
            "garden",
            "forest",
            "aqua",
            "lofi",
            "pastel",
            "fantasy",
            "wireframe",
            "black",
            "luxury",
            "dracula",
            "cmyk",
            "autumn",
            "business",
            "acid",
            "lemonade",
            "night",
            "coffee",
            "winter",
            "dim",
            "nord",
            "sunset",
            {
                some_theme: {
                    primary: "#a991f7",
                    secondary: "#f6d860",
                    accent: "#37cdbe",
                    neutral: "#3d4451",
                    "base-100": "#ffffff",

                    "--rounded-box": "1rem",
                    "--rounded-btn": "0.5rem",
                    "--rounded-badge": "1.9rem",
                    "--animation-btn": "0.25s",
                    "--animation-input": "0.2s",
                    "--btn-focus-scale": "0.95",
                    "--border-btn": "1px",
                    "--tab-border": "1px",
                    "--tab-radius": "0.5rem",
                },
            },
        ],
    }
}

export default config
