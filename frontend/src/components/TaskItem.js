import React from 'react';
import './TaskItem.css';
import { FaTrash, FaCheck } from 'react-icons/fa';

function TaskItem({ task, onToggle, onDelete }) {
  return (
    <li className={`task ${task.completed ? 'completed' : ''}`}>
      <label className="task-checkbox">
        <input
          type="checkbox"
          checked={task.completed}
          onChange={(e) => onToggle(task.id, e.target.checked)}
        />
        <span className="checkmark">
          {task.completed && <FaCheck />}
        </span>
      </label>
      <span className="task-title">{task.title}</span>
      <button className="task-delete" onClick={() => onDelete(task.id)}>
        <FaTrash />
      </button>
    </li>
  );
}

export default TaskItem;
