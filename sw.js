const CACHE_NAME = 'trustinmed-v2';
const ASSETS = ['./', './index.html', './manifest.json'];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE_NAME).then(c => c.addAll(ASSETS)));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  const isPage = req.mode === 'navigate' || req.destination === 'document' ||
    req.url.endsWith('/') || req.url.endsWith('/index.html') || req.url.endsWith('index.html');
  if (isPage) {
    // Network-first for the app shell so updates and security fixes reach users immediately.
    e.respondWith(
      fetch(req)
        .then(res => {
          const copy = res.clone();
          caches.open(CACHE_NAME).then(c => c.put('./index.html', copy));
          return res;
        })
        .catch(() => caches.match('./index.html'))
    );
    return;
  }
  // Cache-first for static assets, falling back to network.
  e.respondWith(caches.match(req).then(r => r || fetch(req)));
});
