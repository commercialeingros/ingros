// sw.js - Gestione Cache e Aggiornamento Forzato
const CACHE_NAME = 'ingros-v2.1'; // <--- CAMBIA QUESTO NUMERO OGNI VOLTA CHE FAI UNA MODIFICA

// File da salvare in cache per il funzionamento offline
const urlsToCache = [
  './',
  './index.html',
  './data/users.json',
  './manifest.json'
];

// Installazione: crea la cache
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(urlsToCache);
    })
  );
  self.skipWaiting(); // Forza l'attivazione immediata del nuovo SW
});

// Attivazione: cancella la vecchia cache e aggiorna l'app
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log("Elimino vecchia cache:", cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  return self.clients.claim(); // Prende il controllo immediato delle pagine aperte
});

// Fetch: serve i file dalla cache o scarica i nuovi
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
