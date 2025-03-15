const express = require('express');
const path = require('path');
const app = express();

// Serve static files from the 'web' directory
app.use(express.static(__dirname, {
  setHeaders: (res, path) => {
    // Set the correct MIME type for .wasm files
    if (path.endsWith('.wasm')) {
      res.set('Content-Type', 'application/wasm');
    }
    // Disable caching for development
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  }
}));

// Handle all routes by serving index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
}); 