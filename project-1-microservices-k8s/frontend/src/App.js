import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';
import Header from './components/Header';
import StatusCards from './components/StatusCards';
import TaskForm from './components/TaskForm';
import TaskList from './components/TaskList';
import ErrorMessage from './components/ErrorMessage';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

function App() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [health, setHealth] = useState({ api: 'checking', db: 'checking', cache: 'checking' });

  useEffect(() => {
    checkHealth();
    loadTasks();
    const healthInterval = setInterval(checkHealth, 30000);
    return () => clearInterval(healthInterval);
  }, []);

  const checkHealth = async () => {
    try {
      const response = await axios.get(`${API_URL}/health`);
      setHealth({
        api: 'connected',
        db: response.data.database === 'connected' ? 'connected' : 'error',
        cache: response.data.cache === 'connected' ? 'connected' : 'error'
      });
    } catch (err) {
      setHealth({ api: 'error', db: 'error', cache: 'error' });
      showError('Cannot connect to backend API');
    }
  };

  const loadTasks = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/api/tasks`);
      setTasks(response.data);
      setLoading(false);
    } catch (err) {
      setError('Failed to load tasks: ' + err.message);
      setLoading(false);
    }
  };

  const addTask = async (title) => {
    try {
      const response = await axios.post(`${API_URL}/api/tasks`, { title });
      setTasks([response.data, ...tasks]);
    } catch (err) {
      showError('Failed to add task: ' + err.message);
    }
  };

  const toggleTask = async (id, completed) => {
    try {
      await axios.put(`${API_URL}/api/tasks/${id}`, { completed });
      setTasks(tasks.map(task => 
        task.id === id ? { ...task, completed } : task
      ));
    } catch (err) {
      showError('Failed to update task: ' + err.message);
    }
  };

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_URL}/api/tasks/${id}`);
      setTasks(tasks.filter(task => task.id !== id));
    } catch (err) {
      showError('Failed to delete task: ' + err.message);
    }
  };

  const showError = (message) => {
    setError(message);
    setTimeout(() => setError(null), 5000);
  };

  return (
    <div className="App">
      <div className="container">
        <Header />
        <div className="content">
          <StatusCards health={health} />
          {error && <ErrorMessage message={error} />}
          <TaskForm onAddTask={addTask} />
          <TaskList 
            tasks={tasks} 
            loading={loading}
            onToggleTask={toggleTask}
            onDeleteTask={deleteTask}
          />
        </div>
      </div>
    </div>
  );
}

export default App;
