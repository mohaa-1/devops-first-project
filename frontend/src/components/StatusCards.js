import React from 'react';
import './StatusCards.css';
import { FaServer, FaDatabase, FaBolt } from 'react-icons/fa';

function StatusCards({ health }) {
  const getStatusIcon = (status) => {
    return status === 'connected' ? '✓' : status === 'checking' ? '...' : '✗';
  };

  const getStatusClass = (status) => {
    return status === 'connected' ? 'connected' : status === 'checking' ? 'checking' : 'error';
  };

  return (
    <div className="status">
      <div className={`status-card api ${getStatusClass(health.api)}`}>
        <FaServer className="status-icon" />
        <div className="status-label">API Status</div>
        <div className="status-value">{getStatusIcon(health.api)} {health.api}</div>
      </div>
      <div className={`status-card db ${getStatusClass(health.db)}`}>
        <FaDatabase className="status-icon" />
        <div className="status-label">Database</div>
        <div className="status-value">{getStatusIcon(health.db)} {health.db}</div>
      </div>
      <div className={`status-card cache ${getStatusClass(health.cache)}`}>
        <FaBolt className="status-icon" />
        <div className="status-label">Redis Cache</div>
        <div className="status-value">{getStatusIcon(health.cache)} {health.cache}</div>
      </div>
    </div>
  );
}

export default StatusCards;
