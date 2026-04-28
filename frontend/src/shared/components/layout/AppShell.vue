<template>
  <div class="app-shell">
    <header class="app-shell__header">
      <div class="brand">Versace HRMS</div>
      <nav class="app-shell__nav">
        <router-link to="/dashboard">Dashboard</router-link>
        <router-link to="/employees">Employees</router-link>
        <router-link to="/leave">Leave</router-link>
        <router-link to="/attendance">Attendance</router-link>
        <router-link to="/logout">Logout</router-link>
      </nav>
    </header>

    <main class="app-shell__main">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
.app-shell {
  min-height: 100vh;
  display: grid;
  grid-template-rows: auto 1fr;
}

.app-shell__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background: #0f172a;
  color: white;
}

.brand {
  font-weight: 700;
}

.app-shell__nav a {
  margin-left: 1rem;
  color: #d1d5db;
  text-decoration: none;
}

.app-shell__nav a.router-link-active {
  color: white;
}

.app-shell__main {
  padding: 2rem;
  background: #f8fafc;
}
</style>
