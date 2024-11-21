import { defaultApiClient } from '$lib/api/client';
import type { ChartConfiguration } from 'chart.js';

// Types
export interface DashboardMetrics {
    total_sales: number;
    inventory_items: number;
    sales_count: number;
    prescriptions_count: number;
}

export interface DailySalesData {
    sale_day: string;
    sales_count: number;
    total_sales_amount: string;
}

interface WeekSalesData {
    weekStart: Date;
    totalSales: number;
    salesCount: number;
}

// Chart configuration
export const chartOptions: ChartConfiguration<'line'>['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: {
            display: false,
        },
        tooltip: {
            mode: 'index' as const,
            intersect: false,
            callbacks: {
                label: (context) => {
                    return `Sales: $${context.parsed.y.toFixed(2)}`;
                }
            }
        },
    },
    scales: {
        y: {
            beginAtZero: true,
            grid: {
                color: 'rgba(0,0,0,0.1)',
            },
            ticks: {
                callback: (value) => `$${value}`
            }
        },
        x: {
            grid: {
                display: false,
            },
            ticks: {
                maxRotation: 45,
                minRotation: 45
            }
        },
    },
    interaction: {
        intersect: false,
        mode: 'index' as const,
    },
};

// Helper functions
function getWeekStart(date: Date): Date {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust for Sunday
    return new Date(d.setDate(diff));
}

function formatDate(date: Date): string {
    return new Intl.DateTimeFormat('en-US', {
        month: 'short',
        day: 'numeric'
    }).format(date);
}

function groupSalesByWeek(sales: DailySalesData[]): WeekSalesData[] {
    const weekMap = new Map<string, WeekSalesData>();

    sales.forEach(sale => {
        const saleDate = new Date(sale.sale_day);
        const weekStart = getWeekStart(saleDate);
        const weekKey = weekStart.toISOString();

        const existingWeek = weekMap.get(weekKey);
        if (existingWeek) {
            existingWeek.totalSales += parseFloat(sale.total_sales_amount);
            existingWeek.salesCount += sale.sales_count;
        } else {
            weekMap.set(weekKey, {
                weekStart,
                totalSales: parseFloat(sale.total_sales_amount),
                salesCount: sale.sales_count
            });
        }
    });

    return Array.from(weekMap.values())
        .sort((a, b) => a.weekStart.getTime() - b.weekStart.getTime());
}

// Service class
export class AnalyticsService {
    private static instance: AnalyticsService;

    private constructor() {}

    public static getInstance(): AnalyticsService {
        if (!AnalyticsService.instance) {
            AnalyticsService.instance = new AnalyticsService();
        }
        return AnalyticsService.instance;
    }

    async fetchDashboardMetrics(): Promise<DashboardMetrics> {
        console.log('Fetching dashboard metrics...');
        try {
            const response = await defaultApiClient.request<DashboardMetrics[]>('/analytics/v_dashboard_metrics');
            console.log('Dashboard metrics response:', response);
            
            if (!response || response.length === 0) {
                throw new Error('No metrics data available');
            }
            return response[0];
        } catch (error) {
            console.error('Error fetching dashboard metrics:', error);
            throw error;
        }
    }

    async fetchDailySales(): Promise<ChartConfiguration<'line'>['data']> {
        console.log('Fetching daily sales data...');
        try {
            // Get sales data
            const response = await defaultApiClient.request<DailySalesData[]>('/analytics/v_daily_sales_summary');
            console.log('Daily sales response:', response);

            if (!response || response.length === 0) {
                console.warn('No sales data available, returning empty chart data');
                return {
                    labels: [],
                    datasets: [{
                        label: 'Weekly Sales',
                        data: [],
                        borderColor: 'rgb(20, 184, 166)',
                        tension: 0.3,
                        fill: false,
                    }]
                };
            }

            // Group sales by week
            const weeklyData = groupSalesByWeek(response);

            // Transform data for chart
            const chartData: ChartConfiguration<'line'>['data'] = {
                labels: weeklyData.map(week => {
                    const weekEnd = new Date(week.weekStart);
                    weekEnd.setDate(weekEnd.getDate() + 6);
                    return `${formatDate(week.weekStart)} - ${formatDate(weekEnd)}`;
                }),
                datasets: [{
                    label: 'Weekly Sales',
                    data: weeklyData.map(week => week.totalSales),
                    borderColor: 'rgb(20, 184, 166)',
                    backgroundColor: 'rgba(20, 184, 166, 0.1)',
                    tension: 0.3,
                    fill: true,
                    pointBackgroundColor: 'rgb(20, 184, 166)',
                    pointRadius: 4,
                    pointHoverRadius: 6,
                }]
            };

            console.log('Processed chart data:', chartData);
            return chartData;
        } catch (error) {
            console.error('Error fetching daily sales:', error);
            throw error;
        }
    }
}

// Export singleton instance
export const analyticsService = AnalyticsService.getInstance();
