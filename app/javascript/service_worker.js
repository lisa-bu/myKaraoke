const CACHE_NAME = "mykaraoke-v1";

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return cache.addAll([
        "/",
        OFFLINE_URL
      ]);
    })
  );
});
