<script lang="ts">
    let activeTab = 'low-stock';
    </script>
    
    <div class="dashboard">
      <h1>Pharmacy Dashboard</h1>
    
      <!-- Key Metrics -->
      <div class="card-grid">
        <div class="card">
          <h3>Total Revenue</h3>
          <p class="large">$45,231.89</p>
          <p class="small">+20.1% from last month</p>
        </div>
        <div class="card">
          <h3>Active Prescriptions</h3>
          <p class="large">2,345</p>
          <p class="small">+180 new this week</p>
        </div>
        <div class="card">
          <h3>Registered Patients</h3>
          <p class="large">12,234</p>
          <p class="small">+2.6% from last month</p>
        </div>
        <div class="card">
          <h3>Inventory Status</h3>
          <p class="large">86.2%</p>
          <p class="small">+2,450 items in stock</p>
        </div>
      </div>
    
      <!-- Revenue Overview and Recent Activities -->
      <div class="card-row">
        <div class="card wide">
          <h2>Revenue Overview</h2>
          <div class="placeholder-chart"></div>
        </div>
        <div class="card">
          <h2>Recent Activities</h2>
          <p>You have 3 unread notifications</p>
          <ul class="activity-list">
            <li>Prescription filled for John Doe</li>
            <li>New inventory received</li>
            <li>Staff meeting scheduled</li>
          </ul>
        </div>
      </div>
    
      <!-- Inventory Management and Upcoming Refills -->
      <div class="card-row">
        <div class="card wide">
          <h2>Inventory Management</h2>
          <div class="tabs">
            <button class={activeTab === 'low-stock' ? 'active' : ''} on:click={() => activeTab = 'low-stock'}>Low Stock</button>
            <button class={activeTab === 'expiring' ? 'active' : ''} on:click={() => activeTab = 'expiring'}>Expiring Soon</button>
          </div>
          {#if activeTab === 'low-stock'}
            <ul class="inventory-list">
              <li>Amoxicillin <div class="progress-bar"><div class="progress" style="width: 20%"></div></div></li>
              <li>Ibuprofen <div class="progress-bar"><div class="progress" style="width: 30%"></div></div></li>
              <li>Metformin <div class="progress-bar"><div class="progress" style="width: 40%"></div></div></li>
            </ul>
          {:else}
            <ul class="inventory-list">
              <li>Aspirin <span>Expires in 30 days</span></li>
              <li>Lisinopril <span>Expires in 25 days</span></li>
              <li>Levothyroxine <span>Expires in 20 days</span></li>
            </ul>
          {/if}
        </div>
        <div class="card">
          <h2>Upcoming Refills</h2>
          <ul class="refill-list">
            <li>Sarah Johnson - Lisinopril <button>Process</button></li>
            <li>Michael Smith - Metformin <button>Process</button></li>
            <li>Emily Brown - Levothyroxine <button>Process</button></li>
          </ul>
        </div>
      </div>
    
      <!-- Alerts, Top Selling Medications, and Quick Actions -->
      <div class="card-grid">
        <div class="card">
          <h2>Alerts</h2>
          <ul class="alert-list">
            <li>Drug interaction detected</li>
            <li>Temperature excursion in storage</li>
            <li>Recall notice received</li>
          </ul>
        </div>
        <div class="card">
          <h2>Top Selling Medications</h2>
          <ul class="medication-list">
            <li>Amoxicillin <span class="trend up">↑</span></li>
            <li>Lisinopril <span class="trend down">↓</span></li>
            <li>Metformin <span class="trend up">↑</span></li>
            <li>Amlodipine <span class="trend down">↓</span></li>
            <li>Omeprazole <span class="trend up">↑</span></li>
          </ul>
        </div>
        <div class="card">
          <h2>Quick Actions</h2>
          <div class="button-grid">
            <button>New Prescription</button>
            <button>Refill Request</button>
            <button>Inventory Check</button>
            <button>Generate Report</button>
          </div>
        </div>
      </div>
    </div>
    
    <style>
      .dashboard {
        padding: 2rem;
        font-family: Arial, sans-serif;
      }
      h1 {
        font-size: 2rem;
        margin-bottom: 1.5rem;
      }
      h2 {
        font-size: 1.2rem;
        margin-bottom: 1rem;
      }
      h3 {
        font-size: 1rem;
        color: #666;
        margin-bottom: 0.5rem;
      }
      .card-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 1.5rem;
        margin-bottom: 1.5rem;
      }
      .card-row {
        display: flex;
        gap: 1.5rem;
        margin-bottom: 1.5rem;
      }
      .card {
        background-color: white;
        padding: 1.5rem;
        border-radius: 0.5rem;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .wide {
        flex-grow: 1;
      }
      .large {
        font-size: 2rem;
        font-weight: bold;
        margin-bottom: 0.25rem;
      }
      .small {
        font-size: 0.9rem;
        color: #666;
      }
      .placeholder-chart {
        height: 300px;
        background: #f0f0f0;
        border-radius: 0.5rem;
      }
      .tabs {
        display: flex;
        margin-bottom: 1rem;
      }
      .tabs button {
        background: none;
        border: none;
        padding: 0.5rem 1rem;
        cursor: pointer;
        border-bottom: 2px solid transparent;
      }
      .tabs button.active {
        border-bottom: 2px solid #007bff;
        font-weight: bold;
      }
      .progress-bar {
        height: 8px;
        background-color: #e0e0e0;
        border-radius: 4px;
        overflow: hidden;
      }
      .progress {
        height: 100%;
        background-color: #007bff;
      }
      .alert-list li {
        color: #ff9800;
        margin-bottom: 0.5rem;
      }
      .trend {
        font-weight: bold;
      }
      .trend.up {
        color: green;
      }
      .trend.down {
        color: red;
      }
      .button-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 1rem;
      }
      button {
        padding: 0.75rem;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 0.25rem;
        cursor: pointer;
        font-size: 0.9rem;
      }
      .activity-list, .inventory-list, .refill-list, .medication-list {
        list-style-type: none;
        padding: 0;
      }
      .activity-list li, .inventory-list li, .refill-list li, .medication-list li {
        margin-bottom: 0.75rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .refill-list button {
        padding: 0.25rem 0.5rem;
        font-size: 0.8rem;
      }
    </style>
