import React from 'react';
import './TaskList.css';
import TaskItem from './TaskItem';

function TaskList({ tasks, loading, onToggleTask, onDeleteTask }) {
  if (loading) {
    return <div className="loading">Loading tasks...</div>;
  }

  if (tasks.length === 0) {
    return <div className="empty-state">No tasks yet. Add one above! 📝</div>;
  }

  return (
    <ul className="tasks">
      {tasks.map(task => (
        <TaskItem
          key={task.id}
          task={task}
          onToggle={onToggleTask}
          onDelete={onDeleteTask}
        />
      ))}
    </ul>
  );
}

export default TaskList;
