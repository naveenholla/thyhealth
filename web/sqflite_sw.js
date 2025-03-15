self.addEventListener('install', function(e) {
  console.log('[Service Worker] Install');
});

self.addEventListener('activate', function(e) {
  console.log('[Service Worker] Activate');
});

self.addEventListener('fetch', function(e) {
  console.log('[Service Worker] Fetch');
});