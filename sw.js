const CACHE_NAME = 'ypwi-absensi-v1';
const OFFLINE_URL = '/absensi/absensi.html';

const urlsToCache = [
  '/',
  '/absensi/absensi.html',
  '/absensi/index.html',
  '/index.html',
  '/login.html'
];

// Install event - cache assets with error handling
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Service Worker: Caching files');
        // Cache files one by one to handle failures gracefully
        const cachePromises = urlsToCache.map(url => {
          return fetch(url, { cache: 'no-cache' })
            .then(response => {
              if (response.ok) {
                return cache.put(url, response);
              } else {
                console.warn(`Service Worker: Skipping ${url} (status: ${response.status})`);
                return Promise.resolve(); // Skip failed requests
              }
            })
            .catch(error => {
              console.warn(`Service Worker: Failed to cache ${url}:`, error);
              return Promise.resolve(); // Continue with other files
            });
        });

        return Promise.all(cachePromises);
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cache => {
          if (cache !== CACHE_NAME) {
            console.log('Service Worker: Clearing old cache', cache);
            return caches.delete(cache);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', event => {
  // Skip API calls - always go to network
  if (event.request.url.includes('/api/')) {
    event.respondWith(
      fetch(event.request)
        .catch(() => {
          return new Response(JSON.stringify({ error: 'Offline' }), {
            headers: { 'Content-Type': 'application/json' }
          });
        })
    );
    return;
  }

  // For HTML pages, try network first, then cache
  event.respondWith(
    fetch(event.request)
      .catch(() => caches.match(event.request))
      .then(response => {
        if (response) return response;
        return caches.match(OFFLINE_URL);
      })
  );
});

// Background sync for offline attendance
self.addEventListener('sync', event => {
  if (event.tag === 'sync-attendance') {
    event.waitUntil(syncOfflineAttendance());
  }
});

async function syncOfflineAttendance() {
  // Get pending attendance from IndexedDB and send to server
  const db = await openDB();
  const tx = db.transaction('pending_attendance', 'readonly');
  const store = tx.objectStore('pending_attendance');
  const pending = await store.getAll();

  for (const record of pending) {
    try {
      await fetch('/api/standalone-attendance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(record.data)
      });
      
      // Remove from pending after successful sync
      const tx2 = db.transaction('pending_attendance', 'readwrite');
      await tx2.objectStore('pending_attendance').delete(record.id);
    } catch (e) {
      console.log('Failed to sync:', record.id);
    }
  }
}

function openDB() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open('YPWI-Offline', 1);
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    request.onupgradeneeded = event => {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('pending_attendance')) {
        db.createObjectStore('pending_attendance', { keyPath: 'id', autoIncrement: true });
      }
      if (!db.objectStoreNames.contains('users_cache')) {
        db.createObjectStore('users_cache', { keyPath: 'scan_id' });
      }
    };
  });
}