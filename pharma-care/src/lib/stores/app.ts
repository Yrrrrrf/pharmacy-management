import { derived, readable, writable } from 'svelte/store';

// Type definitions
interface AppConfig {
    name: string;
    version: string;
    description: string;
    company: string;
    logo: string;
    supportEmail: string;
}

interface User {
    id: string;
    name: string;
    email: string;
    role: 'admin' | 'pharmacist' | 'technician' | 'staff';
    avatar?: string;
}

interface Notification {
    id: string;
    type: 'info' | 'success' | 'warning' | 'error';
    message: string;
    timestamp: Date;
    read: boolean;
}

interface AppState {
    isAuthenticated: boolean;
    user: User | null;
    theme: string;
    notifications: Notification[];
    isLoading: boolean;
    error: string | null;
}

// Immutable app configuration
export const APP_CONFIG = readable<AppConfig>({
    name: 'PharmaCare',
    version: '0.2.0',
    description: 'A comprehensive solution for modern pharmacy operations',
    company: 'Your Company Name',
    logo: '/resources/pharmacy.png',
    supportEmail: 'support@yourcompany.com',
});

// Derived values that can be imported directly
export const appName = derived(APP_CONFIG, $config => $config.name);
export const appLogo = derived(APP_CONFIG, $config => $config.logo);
export const appVersion = derived(APP_CONFIG, $config => $config.version);
export const appDescription = derived(APP_CONFIG, $config => $config.description);
export const appCompany = derived(APP_CONFIG, $config => $config.company);
export const appSupportEmail = derived(APP_CONFIG, $config => $config.supportEmail);

// Environment-specific configuration
export const API_CONFIG = readable({
    API_URL: import.meta.env.VITE_API_URL || 'http://localhost:8000',
    API_VERSION: 'v1',
    ENVIRONMENT: import.meta.env.MODE,
    IS_DEVELOPMENT: import.meta.env.DEV,
    IS_PRODUCTION: import.meta.env.PROD,
});

// Mutable application state
const createAppState = () => {
    const { subscribe, set, update } = writable<AppState>({
        isAuthenticated: false,
        user: null,
        theme: 'light',
        notifications: [],
        isLoading: false,
        error: null,
    });

    return {
        subscribe,
        // Authentication actions
        login: (user: User) => update(state => ({
            ...state,
            isAuthenticated: true,
            user,
        })),
        logout: () => update(state => ({
            ...state,
            isAuthenticated: false,
            user: null,
        })),
        // Theme management
        setTheme: (theme: string) => update(state => ({
            ...state,
            theme,
        })),
        // Notification management
        addNotification: (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => 
            update(state => ({
                ...state,
                notifications: [
                    {
                        id: crypto.randomUUID(),
                        timestamp: new Date(),
                        read: false,
                        ...notification,
                    },
                    ...state.notifications,
                ],
            })),
        markNotificationAsRead: (notificationId: string) => 
            update(state => ({
                ...state,
                notifications: state.notifications.map(n =>
                    n.id === notificationId ? { ...n, read: true } : n
                ),
            })),
        clearNotifications: () => update(state => ({
            ...state,
            notifications: [],
        })),
        // Loading state management
        setLoading: (isLoading: boolean) => update(state => ({
            ...state,
            isLoading,
        })),
        // Error handling
        setError: (error: string | null) => update(state => ({
            ...state,
            error,
        })),
        // Reset state
        reset: () => set({
            isAuthenticated: false,
            user: null,
            theme: 'light',
            notifications: [],
            isLoading: false,
            error: null,
        }),
    };
};

// Export the store instance
export const appStore = createAppState();

// Utility function to handle API errors
export function handleApiError(error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
    appStore.setError(errorMessage);
    appStore.addNotification({
        type: 'error',
        message: errorMessage,
    });
}

// Example usage:
/*
import { appStore, APP_CONFIG, API_CONFIG } from '$lib/stores/app';

// Subscribe to store changes
appStore.subscribe(state => {
    console.log('App state changed:', state);
});

// Use store actions
appStore.setTheme('dark');
appStore.addNotification({
    type: 'success',
    message: 'Operation completed successfully',
});

// Access config
console.log(APP_CONFIG.name);
console.log(API_CONFIG.API_URL);
*/
