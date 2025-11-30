import React from 'react';
import './ErrorMessage.css';
import { FaExclamationTriangle } from 'react-icons/fa';

function ErrorMessage({ message }) {
  return (
    <div className="error">
      <FaExclamationTriangle /> {message}
    </div>
  );
}

export default ErrorMessage;
