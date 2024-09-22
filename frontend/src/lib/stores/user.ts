// src/lib/stores/user.ts
import { writable } from 'svelte/store';

interface User {
    id: string;
    name: string;
    email: string;
    // Add more user properties as needed
}

export const user = writable<User | null>(null);

// create some default user
let defaultUser: User = {
    id: 'A-ICO-24-001',
    name: 'Etesech Penchs',
    email: 'ete.sech@penchs.com',
};

// user.set(defaultUser);

// You can add more user-related stores or functions here
