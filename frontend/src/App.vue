<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-indigo-600 text-white p-4 flex justify-between items-center shadow-lg">
      <div class="text-xl font-bold">:date: Schedule Manager</div>
      <div class="flex gap-4">[오후 12:31]<button @click="currentView = 'register'" class="hover:underline">User Registration</button>
        <button @click="currentView = 'projects'" class="hover:underline">Projects</button>
        <button @click="currentView = 'my'" class="hover:underline">My Schedule</button>
        <button @click="currentView = 'master'" class="hover:underline">Master Board</button>
      </div>
    </nav>
    <main class="p-4">
      <UserRegister v-if="currentView === 'register'" @success="handleRegisterSuccess" />
      <ProjectManager v-if="currentView === 'projects'" />
      <MySchedule v-if="currentView === 'my'" :userId="userId" />
      <MasterDashboard v-if="currentView === 'master'" />
    </main>
  </div>
</template>
<script setup>
import { ref } from 'vue'; import UserRegister from './components/UserRegister.vue'; import ProjectManager from './components/ProjectManager.vue'; import MySchedule from './components/MySchedule.vue'; import MasterDashboard from './components/MasterDashboard.vue';
const currentView = ref('register'); const userId = ref(localStorage.getItem('userId') || null);
const handleRegisterSuccess = (id) => { userId.value = id; localStorage.setItem('userId', id); currentView.value = 'my'; };
</script>
