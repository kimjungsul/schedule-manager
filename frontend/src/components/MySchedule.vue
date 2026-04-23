<template>
  <div class="p-6 bg-gray-100 min-h-screen">
    <div class="flex justify-between items-center mb-4"><h1 class="text-2xl font-bold">:bust_in_silhouette: 내 스케줄</h1><button @click="showModal = true" class="bg-indigo-600 text-white px-4 py-2 rounded text-sm font-bold">+ 작업 추가</button></div>
    <div class="bg-white p-4 rounded shadow">
      <table class="w-full text-left"><thead class="border-b"><tr class="text-gray-500 text-sm"><th class="py-2">작업명</th><th class="py-2">프로젝트</th><th class="py-2">상태</th><th class="py-2">관리</th></tr></thead>
      <tbody><tr v-for="t in myTasks" :key="t.taskId" class="border-b">
        <td class="py-2">{{ t.title }}</td><td class="py-2">{{ getPName(t.projectId) }}</td>
        <td class="py-2"><select :value="t.status" @change="upd(t.taskId, $event.target.value)" class="px-2 py-1 rounded text-xs text-white"><option value="Todo">Todo</option><option value="Doing">Doing</option><option value="Done">Done</option></select></td>
        <td class="py-2"><button @click="del(t.taskId)" class="text-red-500 text-xs">삭제</button></td>
      </tr></tbody></table>
    </div>
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div class="bg-white p-6 rounded-lg shadow-xl max-w-md w-full">
        <h3 class="text-xl font-bold mb-4">새 작업 추가</h3>
        <input v-model="nT.title" type="text" class="w-full p-2 border rounded mb-2" placeholder="작업명">
        <select v-model="nT.projectId" class="w-full p-2 border rounded mb-2">
          <option v-for="p in projects" :key="p.projectId" :value="p.projectId">{{ p.projectName }}</option>
        </select>
        <input v-model="nT.startDate" type="datetime-local" class="w-full p-2 border rounded mb-2">
        <input v-model="nT.endDate" type="datetime-local" class="w-full p-2 border rounded mb-2">
        <div class="flex gap-2"><button @click="showModal = false" class="flex-1 p-2 bg-gray-200 rounded">취소</button><button @click="create" class="flex-1 p-2 bg-indigo-600 text-white rounded">저장</button></div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'; import { api } from '../api';
const props = defineProps(['userId']); const myTasks = ref([]); const projects = ref([]); const showModal = ref(false);
const nT = ref({ title: '', projectId: null, startDate: '', endDate: '', status: 'Todo', priority: 3 });
const fetch = async () => { const [tRes, pRes] = await Promise.all([api.getMyTasks(props.userId), api.getProjects()]); myTasks.value = tRes.data; projects.value = pRes.data; };
const getPName = (id) => projects.value.find(p => p.projectId === id)?.projectName || '없음';
const upd = async (id, s) => { await api.updateTask(id, { status: s }); await fetch(); };
const create = async () => { await api.createTask({ ...nT.value, userId: props.userId, startDate: new Date(nT.value.startDate).toISOString(), endDate: new Date(nT.value.endDate).toISOString() }); showModal.value = false; await fetch(); };
const del = async (id) => { await api.deleteTask(id); await fetch(); };
onMounted(fetch);
</script>
