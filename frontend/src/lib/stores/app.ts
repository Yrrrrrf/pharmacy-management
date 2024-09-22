import { writable } from 'svelte/store';

// * App Main Stores
// This contains the main stores for the app
export const darkMode = writable(false);
// export const sidebar = writable(false);
// export const modal = writable(false);
// export const modalContent = writable('');
// export const modalTitle = writable('');
// export const modalAction = writable('');
// export const modalData = writable<any>({});

// * App User Stores
// todo: Add here the possible user stores...


// * API URL Store
// todo: Manage some way to READ the API URL from the .env file...
export const api_url = writable<string>('http://localhost:8000');
