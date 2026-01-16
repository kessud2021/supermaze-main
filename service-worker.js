/* SuperMaze Service Worker - Enables offline play via PWA */
const CACHE_VERSION = "v1.3.1";
const CACHE_NAME = `supermaze-${CACHE_VERSION}`;
const ASSETS_TO_CACHE = [
  "/",
  "/index.html",
  "/manifest.json",
  "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  "https://code.jquery.com/jquery-3.7.1.slim.min.js",
];

/* Install event: cache assets */
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache
        .addAll(ASSETS_TO_CACHE)
        .catch((error) => {
          console.warn("Cache addAll error:", error);
          return Promise.resolve();
        });
    })
  );
  self.skipWaiting();
});

/* Activate event: clean up old caches */
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

/* Fetch event: network first, fallback to cache */
self.addEventListener("fetch", (event) => {
  // Skip non-GET requests
  if (event.request.method !== "GET") {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Cache successful responses
        if (response.ok) {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        // Fall back to cache on network error
        return caches.match(event.request).then((response) => {
          return response || new Response("Offline - No cached response available");
        });
      })
  );
});
