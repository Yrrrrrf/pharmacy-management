import { writable } from 'svelte/store';

// Types
export interface ThemeConfig {
  name: string;
  value: string;
  icon: string;
  description?: string;
}

export interface CustomTheme {
  primary: string;
  secondary: string;
  accent: string;
  neutral: string;
  "base-100": string;
  [key: string]: string;
}

// Theme definitions
export const themes = [
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
] as const;

export const customThemes = {
  some_theme: {
    primary: "#a991f7",
    secondary: "#f6d860",
    accent: "#37cdbe",
    neutral: "#3d4451",
    "base-100": "#ffffff",
  }
} as const;

export const themeIcons: Record<string, string> = {
  light: '🌞',
  dark: '🌙',
  cupcake: '🧁',
  bumblebee: '🐝',
  emerald: '💚',
  corporate: '🏢',
  synthwave: '🌆',
  retro: '📺',
  cyberpunk: '🤖',
  valentine: '💝',
  halloween: '🎃',
  garden: '🌷',
  forest: '🌲',
  aqua: '💧',
  lofi: '🎵',
  pastel: '🎨',
  fantasy: '🔮',
  wireframe: '📝',
  black: '⚫',
  luxury: '👑',
  dracula: '🧛',
  cmyk: '🖨️',
  autumn: '🍂',
  business: '💼',
  acid: '🧪',
  lemonade: '🍋',
  night: '🌃',
  coffee: '☕',
  winter: '❄️',
  dim: '🔅',
  nord: '❄️',
  sunset: '🌅',
  some_theme: '🎨'
};

// Theme management
export const availableThemes = [...themes, ...Object.keys(customThemes)];
const isBrowser = typeof window !== 'undefined';
export const currentTheme = writable<string>(getTheme());

// Helper function to create theme configuration
export function createThemeConfig(themeName: string): ThemeConfig {
  return {
    name: themeName.charAt(0).toUpperCase() + themeName.slice(1),
    value: themeName,
    icon: themeIcons[themeName] || '🎨',
    description: `${themeName} theme`
  };
}

// Get available themes
export function getAvailableThemes(): ThemeConfig[] {
  return availableThemes.map(theme => createThemeConfig(theme));
}

// Get theme from local storage
export function getTheme(): string {
  if (!isBrowser) return 'light';
  return localStorage.getItem('theme') || 'light';
}

// Set theme
export function setTheme(theme: string): void {
  if (!isBrowser) return;
  localStorage.setItem('theme', theme);
  document.documentElement.setAttribute('data-theme', theme);
  currentTheme.set(theme);
}

// Initialize theme
export function initTheme(): void {
  if (!isBrowser) return;
  const theme: string = getTheme();
  setTheme(theme);
  
  // Set up theme chooser
  const themeSelector = document.querySelector('[data-choose-theme]') as HTMLSelectElement | null;
  if (themeSelector) {
    themeSelector.value = theme;
    themeSelector.addEventListener('change', (e: Event) => {
      const target = e.target as HTMLSelectElement;
      setTheme(target.value);
    });
  }
}
