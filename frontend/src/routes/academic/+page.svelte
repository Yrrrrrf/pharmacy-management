<script lang="ts">
    import { onMount } from 'svelte';
    import { user } from '$lib/stores/user';
    import { tweened } from 'svelte/motion';
    import { cubicOut } from 'svelte/easing';

    let grades = [
        { exam_type: 'Math Midterm', grade: 85 },
        { exam_type: 'Science Quiz', grade: 92 },
        { exam_type: 'History Essay', grade: 78 },
        { exam_type: 'Literature Analysis', grade: 88 },
        { exam_type: 'Physical Education', grade: 95 },
    ];
    let loans = [
        { book_copy_id: 'The Great Gatsby', due_date: '2024-08-20' },
        { book_copy_id: 'To Kill a Mockingbird', due_date: '2024-08-25' },
        { book_copy_id: '1984', due_date: '2024-08-30' },
    ];
    let userName = 'Yusepe';

    const averageGrade = tweened(0, {
        duration: 2000,
        easing: cubicOut
    });

    onMount(() => {
        userName = $user?.name || 'Yusepe';
        const calculatedAverage = calculateAverageGrade(grades);
        averageGrade.set(calculatedAverage);
    });

    function calculateAverageGrade(grades: { exam_type: string; grade: number }[]): number {
        if (grades.length === 0) return 0;
        const sum = grades.reduce((acc, grade) => acc + grade.grade, 0);
        return Math.round(sum / grades.length);
    }
</script>

<svelte:head>
    <title>Dashboard | Academic Hub</title>
</svelte:head>

<div class="p-6 max-w-7xl mx-auto">
    <h1 class="text-3xl font-bold mb-6">Welcome, {userName}!</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Grade Widget -->
        <div class="bg-base-200 p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-semibold mb-4">Recent Grades</h2>
            <ul class="space-y-2">
                {#each grades as grade}
                    <li class="flex justify-between items-center">
                        <span>{grade.exam_type}</span>
                        <span class="font-semibold">{grade.grade}%</span>
                    </li>
                {/each}
            </ul>
        </div>

        <!-- Average Grade Widget -->
        <div class="bg-base-200 p-6 rounded-lg shadow-lg flex flex-col items-center justify-center">
            <h2 class="text-xl font-semibold mb-4">Average Grade</h2>
            <div class="radial-progress text-primary" style="--value:{$averageGrade}; --size:8rem; --thickness: 1rem;">
                <div class="text-2xl font-bold">{$averageGrade.toFixed(1)}%</div>
            </div>
        </div>

        <!-- Library Loans Widget -->
        <div class="bg-base-200 p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-semibold mb-4">Library Loans</h2>
            <ul class="space-y-2">
                {#each loans as loan}
                    <li class="flex justify-between items-center">
                        <span>{loan.book_copy_id}</span>
                        <span class="text-sm"> {loan.due_date}</span>
                    </li>
                {/each}
            </ul>
        </div>

        <!-- Calendar Widget -->
        <div class="bg-base-200 p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-semibold mb-4">Upcoming Events</h2>
            <ul class="space-y-2">
                <li class="flex justify-between items-center">
                    <span>Math Exam</span>
                    <span class="text-sm">Sep 25, 2024</span>
                </li>
                <li class="flex justify-between items-center">
                    <span>Literature Essay Due</span>
                    <span class="text-sm">Oct 1, 2024</span>
                </li>
                <li class="flex justify-between items-center">
                    <span>Science Fair</span>
                    <span class="text-sm">Oct 15, 2024</span>
                </li>
            </ul>
        </div>
    </div>
</div>

<style>
    .radial-progress {
        transition: stroke-dashoffset 0.35s;
    }
</style>
