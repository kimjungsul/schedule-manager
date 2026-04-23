<template>
  <div class="max-w-md mx-auto mt-10 p-6 bg-white rounded-lg shadow-md">
    <h2 class="text-2xl font-bold mb-6 text-center">:bust_in_silhouette: 사용자 등록</h2>
    <div class="space-y-4">
      <div><label class="block text-sm font-medium text-gray-700">이름</label><input v-model="form.name" type="text" class="w-full p-2 border rounded mt-1"></div>
      <div><label class="block text-sm font-medium text-gray-700">이메일</label><input v-model="form.email" type="email" class="w-full p-2 border rounded mt-1"></div>
      <div><label class="block text-sm font-medium text-gray-700">역할</label><select v-model="form.role" class="w-full p-2 border rounded mt-1"><option value="Dev">개발자</option><option value="PM">PM</option></select></div>
      <button @click="register" class="w-full bg-indigo-600 text-white p-2 rounded font-bold">등록하기</button>
    </div>
  </div>
</template>
<script setup>
import { reactive } from 'vue'; import { api } from '../api';
const emit = defineEmits(['success']); const form = reactive({ name: '', email: '', role: 'Dev' });
const register = async () => { try { const res = await api.registerUser(form); emit('success', res.data.userId); } catch(e) { alert('오류 발생'); } };
</script>
