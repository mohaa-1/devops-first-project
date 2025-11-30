import React, { useState } from 'react';
import './TaskForm.css';
import { FaPlus } from 'react-icons/fa';

function TaskForm({ onAddTask }) {
  const [title, setTitle] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (title.trim()) {
      onAddTask(title);
      setTitle('');
    }
  };

  return (
    <form className="add-task" onSubmit={handleSubmit}>
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Enter a new task..."
      />
      <button type="submit">
        <FaPlus /> Add Task
      </button>
    </form>
  );
}

export default TaskForm;
