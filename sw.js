// sw.js — rend la page des presets utilisable hors ligne une fois installée sur l'écran d'accueil.
//
// Page et fichiers du site : réseau d'abord (une nouvelle version poussée sur GitHub s'affiche à
// l'ouverture suivante), copie locale si le réseau est absent ou trop lent.
// Polices Google : copie locale d'abord, elles ne changent pas.

var CACHE = "presets-x-h2s-v2";
var SHELL = ["./", "selection.js", "manifest.webmanifest", "icons/apple-touch-icon.png", "icons/icon-192.png", "icons/icon-512.png"];
var NETWORK_TIMEOUT_MS = 4000;

self.addEventListener("install", function (event) {
  event.waitUntil(
    caches.open(CACHE)
      .then(function (cache) { return cache.addAll(SHELL); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (event) {
  event.waitUntil(
    caches.keys()
      .then(function (keys) {
        return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
      })
      .then(function () { return self.clients.claim(); })
  );
});

function isFont(url) {
  return url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com";
}

// Va chercher sur le réseau et garde la réponse pour le hors-ligne.
function fetchAndStore(request, options) {
  return fetch(request, options).then(function (response) {
    // « opaque » : la feuille de style des polices, chargée sans CORS par la balise <link>.
    if (response.ok || response.type === "opaque") {
      var copy = response.clone();
      caches.open(CACHE).then(function (cache) { cache.put(request, copy); });
    }
    return response;
  });
}

function cacheFirst(request) {
  return caches.match(request).then(function (cached) {
    return cached || fetchAndStore(request);
  });
}

function networkFirst(request) {
  return caches.match(request, { ignoreSearch: true }).then(function (cached) {
    // « no-cache » : revalide auprès du serveur au lieu de se fier au cache HTTP de 10 min de GitHub Pages.
    var fromNetwork = fetchAndStore(request, { cache: "no-cache" });
    if (!cached) return fromNetwork;
    var fallback = new Promise(function (resolve) {
      setTimeout(function () { resolve(cached); }, NETWORK_TIMEOUT_MS);
    });
    return Promise.race([fromNetwork.catch(function () { return cached; }), fallback]);
  });
}

self.addEventListener("fetch", function (event) {
  var request = event.request;
  if (request.method !== "GET") return;
  var url = new URL(request.url);
  if (isFont(url)) {
    event.respondWith(cacheFirst(request));
  } else if (url.origin === self.location.origin) {
    event.respondWith(networkFirst(request));
  }
});
