import axios from 'axios';
const API_BASE_URL = 'http://localhost:5000/api/v1';
export const api = {
  registerUser: (d) => axios.post(\/Users/register\, d),
  getUsers: () => axios.get(\/Users\),
  getProjects: () => axios.get(\/Projects\),
  createProject: (d) => axios.post(\/Projects\, d),
  getMyTasks: (uid) => axios.get(\/Tasks/my?userId=${uid}\),
  getAllTasks: () => axios.get(\/Tasks\),
  createTask: (d) => axios.post(\/Tasks\, d),
  updateTask: (id, d) => axios.put(\/Tasks/${id}\, d),
  deleteTask: (id) => axios.delete(\/Tasks/${id}\),
};
