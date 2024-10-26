// main-store.ts
import { readable } from 'svelte/store';

// Type definitions
interface AppConfig {
    name: string;
    version: string;
    description: string;
    company: string;
    logo: string;
    supportEmail: string;
}

// Using runes for state management
export const APP_CONFIG = readable<AppConfig>({
    // name: 'Pharmacy Management System',
    name: 'PharmaCare',
    version: '0.2.0',
    description: 'A comprehensive solution for modern pharmacy operations',
    company: 'Your Company Name',
    logo: '/resources/pharmacy.png',
    supportEmail: 'support@yourcompany.com',
});

// API URL configuration
// Using import.meta.env for type-safe environment variables
export const API_URL = readable<string>('http://localhost:8000');

// Example of how to use in a component:
/*
<script lang="ts">
    import { APP_CONFIG, API_URL } from './stores/main-store';
    
    // Access the values directly with $ syntax
    $: console.log($APP_CONFIG.name);
    $: console.log($API_URL);
</script>
*/










// // Pagination configuration
// export const paginationConfig = writable<PaginationConfig>({
//     defaultPageSize: 10,
//     pageSizeOptions: [5, 10, 20, 50, 100],
// });

// // Feature flags for conditional functionality
// export const featureFlags = writable({
//     enablePrescriptionModule: true,
//     enableInventoryAlerts: true,
//     enableCustomerPortal: false,
//     enableAnalytics: true,
//     enableMobileApp: false,
// });

// // Currency configuration
// export const currencyConfig = writable({
//     code: 'USD',
//     symbol: '$',
//     position: 'before' as 'before' | 'after',
//     decimal: '.',
//     thousand: ',',
//     precision: 2,
// });

// // Date format configuration
// export const dateConfig = writable({
//     format: 'YYYY-MM-DD',
//     timeFormat: 'HH:mm:ss',
//     timezone: 'UTC',
// });

// // Notification settings
// export const notificationConfig = writable({
//     position: 'top-right' as 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left',
//     duration: 5000,
//     maxNotifications: 5,
// });

// // Cache configuration
// export const cacheConfig = writable({
//     ttl: 300, // 5 minutes in seconds
//     maxSize: 100, // Maximum number of items to cache
//     enableLocalStorage: true,
// });

// // Error messages
// export const errorMessages = writable({
//     network: 'Network error occurred. Please check your connection.',
//     unauthorized: 'You are not authorized to perform this action.',
//     notFound: 'The requested resource was not found.',
//     serverError: 'An internal server error occurred. Please try again later.',
//     validation: 'Please check your input and try again.',
// });