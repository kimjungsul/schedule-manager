#!/bin/bash

# 1. 폴더 구조 생성
mkdir -p backend/ScheduleManager.Api/Controllers backend/ScheduleManager.Api/Models backend/ScheduleManager.Api/Data db frontend/src/components

# 2. Docker Compose
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: schedule_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/schema.sql:/docker-entrypoint-initdb.d/schema.sql
  api:
    build:
      context: .
      dockerfile: backend/Dockerfile
    environment:
      - ConnectionStrings__DefaultConnection=Host=db;Database=schedule_db;Username=postgres;Password=postgres
    depends_on:
      - db
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    depends_on:
      - api
volumes:
  postgres_data:
EOF

# 3. DB 설계도
cat <<EOF > db/schema.sql
CREATE TABLE Users (UserId SERIAL PRIMARY KEY, Name VARCHAR(100) NOT NULL, Email VARCHAR(255) UNIQUE NOT NULL, Role VARCHAR(20) NOT NULL, SlackId VARCHAR(100), CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE Projects (ProjectId SERIAL PRIMARY KEY, ProjectName VARCHAR(200) NOT NULL, Description TEXT, StartDate DATE NOT NULL, EndDate DATE NOT NULL, CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE Tasks (TaskId SERIAL PRIMARY KEY, ProjectId INTEGER REFERENCES Projects(ProjectId), UserId INTEGER REFERENCES Users(UserId), Title VARCHAR(255) NOT NULL, Description TEXT, StartDate TIMESTAMP NOT NULL, EndDate TIMESTAMP NOT NULL, Status VARCHAR(20) DEFAULT 'Todo', Priority INTEGER DEFAULT 3, UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE Notifications (NotiId SERIAL PRIMARY KEY, TaskId INTEGER REFERENCES Tasks(TaskId), UserId INTEGER REFERENCES Users(UserId), Message TEXT NOT NULL, SentAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Status VARCHAR(20) DEFAULT 'Sent');
EOF

# 4. 백엔드 설정
cat <<EOF > backend/Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ScheduleManager.Api/ScheduleManager.Api.csproj", "ScheduleManager.Api/"]
RUN dotnet restore "ScheduleManager.Api/ScheduleManager.Api.csproj"
COPY . .
WORKDIR "/src/ScheduleManager.Api"
RUN dotnet publish -c Release -o /app/publish
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ScheduleManager.Api.dll"]
EOF

cat <<EOF > backend/ScheduleManager.Api/ScheduleManager.Api.csproj
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup><TargetFramework>net8.0</TargetFramework><Nullable>enable</Nullable><ImplicitUsings>enable</ImplicitUsings></PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.0" />
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.0" />
<PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>
</Project>
EOF

cat <<EOF > backend/ScheduleManager.Api/Models/User.cs
using System.ComponentModel.DataAnnotations;
namespace ScheduleManager.Api.Models {
    public class User { [Key] public int UserId { get; set; } [Required] public string Name { get; set; } = ""; [Required] public string Email { get; set; } = ""; [Required] public string Role { get; set; } = "Dev"; public string? SlackId { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Models/Project.cs
using System.ComponentModel.DataAnnotations;
namespace ScheduleManager.Api.Models {
    public class Project { [Key] public int ProjectId { get; set; } [Required] public string ProjectName { get; set; } = ""; public string? Description { get; set; } [Required] public DateTime StartDate { get; set; } [Required] public DateTime EndDate { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Models/TaskItem.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace ScheduleManager.Api.Models {
    public class TaskItem { [Key] public int TaskId { get; set; } [Required] public int ProjectId { get; set; } [ForeignKey("ProjectId")] public Project? Project { get; set; } public int? UserId { get; set; } [ForeignKey("UserId")] public User? User { get; set; } [Required] public string Title { get; set; } = ""; public string? Description { get; set; } [Required] public DateTime StartDate { get; set; } [Required] public DateTime EndDate { get; set; } [Required] public string Status { get; set; } = "Todo"; public int Priority { get; set; } = 3; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow; }
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Data/ApplicationDbContext.cs
using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Models;
namespace ScheduleManager.Api.Data {
    public class ApplicationDbContext : DbContext {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }
        public DbSet<User> Users => Set<User>();
        public DbSet<Project> Projects => Set<Project>();
        public DbSet<TaskItem> Tasks => Set<TaskItem>();
    }
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Program.cs
using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data;
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers(); builder.Services.AddEndpointsApiExplorer(); builder.Services.AddSwaggerGen();
var conn = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseNpgsql(conn));
builder.Services.AddCors(options => options.AddPolicy("AllowAll", p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));
var app = builder.Build();
app.UseCors("AllowAll"); app.UseAuthorization(); app.MapControllers(); app.Run();
EOF
cat <<EOF > backend/ScheduleManager.Api/appsettings.json
{ "ConnectionStrings": { "DefaultConnection": "Host=db;Database=schedule_db;Username=postgres;Password=postgres" } }
EOF
cat <<EOF > backend/ScheduleManager.Api/Controllers/UsersController.cs
using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data; using ScheduleManager.Api.Models;
[ApiController] [Route("api/v1/[controller]")] public class UsersController : ControllerBase {
    private readonly ApplicationDbContext _ctx; public UsersController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpPost("register")] public async Task<IActionResult> Reg([FromBody] User u) { _ctx.Users.Add(u); await _ctx.SaveChangesAsync(); return Ok(u); }
[HttpGet] public async Task<IActionResult> Get() => Ok(await _ctx.Users.ToListAsync());
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Controllers/ProjectsController.cs
using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data; using ScheduleManager.Api.Models;
[ApiController] [Route("api/v1/[controller]")] public class ProjectsController : ControllerBase 
private readonly ApplicationDbContext _ctx; public ProjectsController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpGet] public async Task<IActionResult> Get() => Ok(await _ctx.Projects.ToListAsync());
    [HttpPost] public async Task<IActionResult> Post([FromBody] Project p) { _ctx.Projects.Add(p); await _ctx.SaveChangesAsync(); return Ok(p); }
}
EOF
cat <<EOF > backend/ScheduleManager.Api/Controllers/TasksController.cs
using Microsoft.AspNetCore.Mvc; using Microsoft.EntityFrameworkCore; using ScheduleManager.Api.Data; using ScheduleManager.Api.Models;
[ApiController] [Route("api/v1/[controller]")] public class TasksController : ControllerBase {
    private readonly ApplicationDbContext _ctx; public TasksController(ApplicationDbContext ctx) => _ctx = ctx;
    [HttpGet("my")] public async Task<IActionResult> My([FromQuery] int userId) => Ok(await _ctx.Tasks.Where(t => t.UserId == userId).ToListAsync());
    [HttpGet] public async Task<IActionResult> All() => Ok(await _ctx.Tasks.Include(t => t.User).ToListAsync());
    [HttpPost] public async Task<IActionResult> Post([FromBody] TaskItem t) { _ctx.Tasks.Add(t); await _ctx.SaveChangesAsync(); return Ok(t); }
    [HttpPut("{id}")] public async Task<IActionResult> Put(int id, [FromBody] TaskItem t) {
        var exist = await _ctx.Tasks.FindAsync(id); if(exist == null) return NotFound();
        exist.Status = t.Status; exist.Title = t.Title; await _ctx.SaveChangesAsync(); return Ok(exist);
    }
    [HttpDelete("{id}")] public async Task<IActionResult> Del(int id) {
        var tsk = await _ctx.Tasks.FindAsync(id); if(tsk == null) return NotFound();
        _ctx.Tasks.Remove(tsk); await _ctx.SaveChangesAsync(); return NoContent();
    }
}
EOF

# 5. 프론트엔드 설정
cat <<EOF > frontend/Dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
cat <<EOF > frontend/package.json
{ "name": "schedule-manager-frontend", "version": "0.1.0", "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview" }, "dependencies": { "vue": "^3.4.0", "axios": "^1.6.0" }, "devDependencies": { "@vitejs/plugin-vue": "^5.0.0", "vite": "^5.0.0", "tailwindcss": "^3.4.0", "autoprefixer": "^10.4.0", "postcss": "^8.4.0" } }
EOF
cat <<EOF > frontend/index.html
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Schedule Manager</title></head><body><div id="app"></div><script type="module" src="/src/main.js"></script></body></html>
EOF
cat <<EOF > frontend/vite.config.js
import { defineConfig } from 'vite'; import vue from '@vitejs/plugin-vue';
export default defineConfig({ plugins: [vue()] });
EOF
cat <<EOF > frontend/src/main.js
import { createApp } from 'vue'; import App from './App.vue';
createApp(App).mount('#app');
EOF
cat <<EOF > frontend/src/api.js
import axios from 'axios';
const API_BASE_URL = 'http://localhost:5000/api/v1';
export const api = {
  registerUser: (d) => axios.post(\\${API_BASE_URL}/Users/register\, d),
  getUsers: () => axios.get(\\${API_BASE_URL}/Users\),
  getProjects: () => axios.get(\\${API_BASE_URL}/Projects\),
  createProject: (d) => axios.post(\\${API_BASE_URL}/Projects\, d),
  getMyTasks: (uid) => axios.get(\\${API_BASE_URL}/Tasks/my?userId=\${uid}\),
  getAllTasks: () => axios.get(\\${API_BASE_URL}/Tasks\),
  createTask: (d) => axios.post(\\${API_BASE_URL}/Tasks\, d),
  updateTask: (id, d) => axios.put(\\${API_BASE_URL}/Tasks/\${id}\, d),
  deleteTask: (id) => axios.delete(\\${API_BASE_URL}/Tasks/\${id}\),
};
EOF

# 프론트엔드 UI 구현
cat <<EOF > frontend/src/App.vue
<template>
  <div class="min-h-screen bg-gray-100">
    <nav class="bg-indigo-600 text-white p-4 flex justify-between items-center shadow-lg">
      <div class="text-xl font-bold">:date: Schedule Manager</div>
      <div class="flex gap-4">
        <button @click="currentView = 'register'" class="hover:underline">User Registration</button>
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
EOF
cat <<EOF > frontend/src/components/UserRegister.vue
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
EOF
cat <<EOF > frontend/src/components/ProjectManager.vue
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
EOF
cat <<EOF > frontend/src/components/MySchedule.vue
<template>
  <div class="p-6 bg-gray-100 min-h-screen">
    <div class="flex justify-between items-center mb-4"><h1 class="text-2xl font-bold">:bust_in_silhouette: 내 스케줄</h1><button @click="showModal = true" class="bg-indigo-600 text-white px-4 py-2 rounded text-sm font-bold">+ 작업 추가</button></div>
    <div class="bg-white p-4 rounded shadow">
      <table class="w-full text-left"><thead class="border-b"><tr class="text-gray-500 text-sm"><th class="py-2">작업명</th><th class="py-2">프로젝트</th><th class="py-2">상태</th><th class="py-2">관리</th></tr></thead>
      <tbody><tr v-for="t in myTasks" :key="t.taskId" class="border-b">
        <td class="py-2">{{ t.title }}</td><td class="py-2">{{ getPName(t.projectId) }}</td>
        <td class="py-2"><select :value="t.status" @change="upd(t.taskId, \$event.target.value)" class="px-2 py-1 rounded text-xs text-white"><option value="Todo">Todo</option><option value="Doing">Doing</option><option value="Done">Done</option></select></td>
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
EOF
cat <<EOF > frontend/src/components/MasterDashboard.vue
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
EOF

# 6. 최종 깃허브 업로드
git config --global user.email "pm@example.com"
git config --global user.name "PM-User"
git add .
git commit -m ":rocket: FINAL COMPLETE DEPLOYMENT - Clean Version"
git push origin main
EOF
