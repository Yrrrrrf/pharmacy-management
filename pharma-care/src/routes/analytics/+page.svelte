<!-- src/routes/dashboard/+page.svelte -->
<script lang="ts">
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';
    import { appName } from '$lib/stores/app';
    import Chart from 'chart.js/auto';
    import { 
        DollarSign,
        Package,
        Users,
        Pill,
        PlusCircle,
        Calendar,
        Bell
    } from 'lucide-svelte';
    
    let chartCanvas: HTMLCanvasElement;
    let chart: Chart;
    
    // Chart data
    const chartData = [
        { date: 'Jan 22', Sales: 2890 },
        { date: 'Feb 22', Sales: 2756 },
        { date: 'Mar 22', Sales: 3322 },
        { date: 'Apr 22', Sales: 3470 },
        { date: 'May 22', Sales: 3475 },
        { date: 'Jun 22', Sales: 3129 },
    ];
    
    // Stats cards data
    const statsCards = [
        { title: 'Total Sales', icon: DollarSign, value: '$12,345', color: 'bg-success text-success-content' },
        { title: 'Inventory Items', icon: Package, value: '1,234', color: 'bg-info text-info-content' },
        { title: 'Customers', icon: Users, value: '5,678', color: 'bg-secondary text-secondary-content' },
        { title: 'Prescriptions', icon: Pill, value: '910', color: 'bg-primary text-primary-content' },
    ];
    
    // Quick actions
    const quickActions = [
        { title: 'New Prescription', icon: PlusCircle, color: 'bg-info/20 text-info' },
        { title: 'Manage Inventory', icon: Package, color: 'bg-success/20 text-success' },
        { title: 'Patient Records', icon: Users, color: 'bg-secondary/20 text-secondary' },
        { title: 'Schedule Appointment', icon: Calendar, color: 'bg-warning/20 text-warning' },
    ];
    
    // Recent activities
    const recentActivities = [
        { title: 'New order received', description: 'Order #1234 for Patient John Doe', icon: Package, time: '2 minutes ago' },
        { title: 'Inventory alert', description: 'Paracetamol stock is running low', icon: Bell, time: '1 hour ago' },
        { title: 'Prescription refill', description: 'Sarah Connor requested a refill', icon: Pill, time: '3 hours ago' },
    ];
    
    // Team members
    const teamMembers = [
        { name: 'Dr. Jane Foster', role: 'Head Pharmacist', avatar: '/placeholder.svg?height=40&width=40' },
        { name: 'Mike Ross', role: 'Pharmacy Technician', avatar: '/placeholder.svg?height=40&width=40' },
        { name: 'Rachel Green', role: 'Pharmacy Assistant', avatar: '/placeholder.svg?height=40&width=40' },
    ];
    
    onMount(() => {
        // Initialize chart
        const ctx = chartCanvas.getContext('2d');
        if (ctx) {
            chart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: chartData.map(data => data.date),
                    datasets: [{
                        label: 'Monthly Sales',
                        data: chartData.map(data => data.Sales),
                        borderColor: 'rgb(20, 184, 166)',
                        tension: 0.3,
                        fill: false
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0,0,0,0.1)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });
        }

        return () => {
            if (chart) {
                chart.destroy();
            }
        };
    });
</script>

<div class="min-h-screen bg-base-200 p-8">
    <!-- Header -->
    <header class="mb-8" in:fly={{ y: -20, duration: 500 }}>
        <h1 class="text-4xl font-bold mb-2">{$appName} Dashboard</h1>
        <p class="text-base-content/80">Welcome back, Dr. Smith. Here's your pharmacy at a glance.</p>
    </header>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {#each statsCards as { title, icon: Icon, value, color }, i}
            <div class="card bg-base-100 shadow-xl" 
                 in:fly={{ y: 20, duration: 500, delay: i * 100 }}>
                <div class="card-body">
                    <div class="flex items-center justify-between">
                        <h2 class="card-title text-sm">{title}</h2>
                        <div class="rounded-full p-2 {color}">
                            <Icon class="w-6 h-6" />
                        </div>
                    </div>
                    <p class="text-2xl font-bold">{value}</p>
                </div>
            </div>
        {/each}
    </div>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <!-- Quick Actions -->
        <div class="card bg-base-100 shadow-xl" in:fly={{ x: -20, duration: 500 }}>
            <div class="card-body">
                <h2 class="card-title">Quick Actions</h2>
                <div class="grid grid-cols-2 gap-4">
                    {#each quickActions as { title, icon: Icon, color }}
                        <button class="btn btn-ghost h-24 flex flex-col items-center justify-center gap-2 hover:bg-base-200">
                            <div class="rounded-full p-2 {color}">
                                <Icon class="w-6 h-6" />
                            </div>
                            <span class="text-sm">{title}</span>
                        </button>
                    {/each}
                </div>
            </div>
        </div>

        <!-- Sales Chart -->
        <div class="card bg-base-100 shadow-xl" in:fly={{ x: 20, duration: 500 }}>
            <div class="card-body">
                <h2 class="card-title">Monthly Sales Overview</h2>
                <div class="h-[300px] mt-4">
                    <canvas bind:this={chartCanvas}></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Bottom Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Recent Activities -->
        <div class="lg:col-span-2 card bg-base-100 shadow-xl" in:fly={{ y: 20, duration: 500 }}>
            <div class="card-body">
                <h2 class="card-title">Recent Activities</h2>
                <p class="text-sm text-base-content/60">You have 3 unread notifications</p>
                <div class="space-y-4">
                    {#each recentActivities as { title, description, icon: Icon, time }}
                        <div class="flex items-start space-x-4">
                            <Icon class="w-6 h-6 mt-1 text-primary" />
                            <div class="flex-1">
                                <p class="font-medium">{title}</p>
                                <p class="text-sm text-base-content/60">{description}</p>
                            </div>
                            <span class="text-xs text-base-content/40">{time}</span>
                        </div>
                    {/each}
                </div>
            </div>
        </div>

        <!-- Team Members -->
        <div class="card bg-base-100 shadow-xl" in:fly={{ y: 20, duration: 500, delay: 200 }}>
            <div class="card-body">
                <h2 class="card-title">Team Members</h2>
                <div class="space-y-4">
                    {#each teamMembers as { name, role, avatar }}
                        <div class="flex items-center space-x-4">
                            <div class="avatar placeholder">
                                <div class="w-10 rounded-full bg-neutral-focus text-neutral-content">
                                    <span class="text-xs">{name.split(' ').map(n => n[0]).join('')}</span>
                                </div>
                            </div>
                            <div>
                                <p class="font-medium">{name}</p>
                                <p class="text-sm text-base-content/60">{role}</p>
                            </div>
                        </div>
                    {/each}
                </div>
            </div>
        </div>
    </div>
</div>