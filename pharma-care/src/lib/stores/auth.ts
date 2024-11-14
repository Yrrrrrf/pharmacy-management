// src/lib/stores/auth.ts
import { writable } from 'svelte/store';

interface User {
    id: string;
    name: string;
    email: string;
    role: 'admin' | 'pharmacist' | 'staff' | 'customer';
}

interface AuthState {
    isAuthenticated: boolean;
    user: User | null;
}

export const authStore = writable<AuthState>({
    isAuthenticated: false,
    user: null
});


// Set authenticated state
authStore.set({
    isAuthenticated: true,
    user: {
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        role: 'staff'
    }
});

// Clear auth state (logout)
// authStore.set({isAuthenticated: false,user: null});