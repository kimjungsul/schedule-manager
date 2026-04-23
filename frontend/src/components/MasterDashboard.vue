<template>
  <div class="p-6 bg-gray-100 min-h-screen">
    <h1 class="text-2xl font-bold mb-4">:date: 통합 스케줄 보드</h1>
    <div class="grid grid-cols-1 gap-4">
      <div v-for="u in users" :key="u.userId" class="bg-white p-4 rounded shadow">
<div class="font-semibold mb-2">{{ u.name }} ({{ u.role }})</div>
        <div class="flex gap-2 overflow-x-auto pb-2">
          <div v-for="t in getT(u.userId)" :key="t.taskId" class="p-2 rounded text-xs text-white bg-blue-500">{{ t.title }} ({{ t.status }})</div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'; import { api } from '../api';
const users = ref([]); const allT = ref([]);
const fetch = async () => { const [uRes, tRes] = await Promise.all([api.getUsers(), api.getAllTasks()]); users.value = uRes.data; allT.value = tRes.data; };
const getT = (uid) => allT.value.filter(t => t.userId === uid);
onMounted(fetch);
</script>
