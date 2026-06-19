const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files
app.use(express.static('public'));

// API endpoint for health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// API endpoint for portfolio data
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Student Portfolio',
    title: 'Full Stack Developer',
    description: 'Kubernetes & ArgoCD Demo Project',
    version: 'v1.0.0',
    hostname: require('os').hostname(),
    timestamp: new Date().toISOString()
  });
});

// Serve index.html for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Portfolio server running on port ${PORT}`);
});