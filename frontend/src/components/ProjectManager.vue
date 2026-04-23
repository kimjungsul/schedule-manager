<template>
  <div class="max-w-4xl mx-auto p-6">
    <div class="flex justify-between items-center mb-6"><h2 class="text-2xl font-bold">:file_folder: 프로젝트 관리</h2><button @click="showCreateModal = true" class="bg-indigo-600 text-white px-4 py-2 rounded text-sm font-bold">+ 새 프로젝트 생성</button></div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div v-for="p in projects" :key="p.projectId" class="bg-white p-4 rounded shadow"><h3 class="font-bold text-lg">{{ p.projectName }}</h3><p class="text-gray-600 text-sm">{{ p.description }}</p></div>
    </div>
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div class="bg-white p-6 rounded-lg shadow-xl max-w-md w-full">
        <h3 class="text-xl font-bold mb-4">새 프로젝트 생성</h3>
        <input v-model="newP.projectName" type="text" class="w-full p-2 border rounded mb-2" placeholder="프로젝트명">
        <textarea v-model="newP.description" class="w-full p-2 border rounded mb-2" placeholder="설명"></textarea>
        <input v-model="newP.startDate" type="date" class="w-full p-2 border rounded mb-2">
        <input v-model="newP.endDate" type="date" class="w-full p-2 border rounded mb-2">
<div class="flex gap-2"><button @click="showCreateModal = false" class="flex-1 p-2 bg-gray-200 rounded">취소</button><button @click="create" class="flex-1 p-2 bg-indigo-600 text-white rounded">저장</button></div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'; import { api } from '../api';
const projects = ref([]); const showCreateModal = ref(false); const newP = ref({ projectName: '', description: '', startDate: '', endDate: '' });
const fetch = async () => { const res = await api.getProjects(); projects.value = res.data; };
const create = async () => { await api.createProject(newP.value); showCreateModal.value = false; await fetch(); };
onMounted(fetch);
</script>
