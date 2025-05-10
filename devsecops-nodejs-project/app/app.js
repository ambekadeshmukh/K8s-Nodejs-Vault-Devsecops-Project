const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON and URL-encoded data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from the public directory
app.use(express.static('public'));

// Root route - basic information about the app
app.get('/', (req, res) => {
  res.send(`
    <h1>DevSecOps Node.js Application</h1>
    <p>This is a secure Node.js application deployed using a DevSecOps pipeline with Jenkins, Docker, and Kubernetes.</p>
    <p>Server time: ${new Date()}</p>
    <p>Environment: ${process.env.NODE_ENV || 'development'}</p>
    <h2>Available API Endpoints:</h2>
    <ul>
      <li><a href="/api/info">/api/info</a> - General information about the application</li>
      <li><a href="/api/health">/api/health</a> - Health check endpoint</li>
      <li><a href="/api/secret">/api/secret</a> - Display secret message (requires valid authentication)</li>
    </ul>
  `);
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: Date.now()
  });
});

// Application info endpoint
app.get('/api/info', (req, res) => {
  res.status(200).json({
    name: 'devsecops-nodejs-app',
    version: '1.0.0',
    description: 'Secure Node.js application deployed with DevSecOps pipeline',
    node_version: process.version,
    dependencies: {
      express: 'latest'
    }
  });
});

// Secret message endpoint - demonstrates accessing secrets securely
app.get('/api/secret', (req, res) => {
  // In a real application, you would validate authentication/authorization
  // For demo purposes, we're just checking if the secret exists
  const secretMessage = process.env.SECRET_MESSAGE || 'No secret message found. Make sure Vault is properly configured.';
  
  res.status(200).json({
    message: secretMessage,
    timestamp: new Date()
  });
});

// Start the server
app.listen(port, () => {
  console.log(`DevSecOps Node.js application listening at http://localhost:${port}`);
});