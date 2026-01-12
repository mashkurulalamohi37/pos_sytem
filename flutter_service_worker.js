'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "95c381d14d2c7d1bb6fe926748d00fff",
".git/config": "d86a80c6fee34b16a1ff421cc5267fdb",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "0dea6b5cc6e5fb7d1b59bfb080ad3fc1",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "81b9fd8f43764158eff90d019f72af39",
".git/logs/refs/heads/gh-pages": "7418fae11d8164e085a9a5c7cb4885a6",
".git/logs/refs/remotes/origin/gh-pages": "91a8513c82fc4a596a09e8d6fea9b1e5",
".git/objects/02/46b750d1a768bef7b4024a439f126920fed5b9": "ead6628d0991e928c5dfa55812851c16",
".git/objects/03/5f7bd9df8c53e9b6124f6dfeedd8759e27dd5a": "7ef186fe0f29e97e2979d1faf7f0f950",
".git/objects/0f/70223caaeef281e1cef11f8bb5783ffd82b87a": "14f5500d43e5761b56c6483ec60e08e8",
".git/objects/18/621410a1251820b2fb39b43e5259d52f170283": "0cac16d6bda35fb3e920fdb5d6b26a74",
".git/objects/1a/804c6475b9f9b701b249096e6de102877d2a20": "7bcc0e9e5817cdc919d4cb9353077f1e",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/25/6b59c2e975e583ba81c4eee5db92f7284bf781": "d269ebd4bffefcb6eaa8152daf9a0202",
".git/objects/28/3334535b7b492224ce6542d3d751140a200f1e": "0b58dea3433104b85067eb786356807d",
".git/objects/2b/8240dc74d281709ff574569f50d3f4e94747e6": "c973028b13219c338972539f0dcda164",
".git/objects/36/a88a92c964d110d390eae96577bbd50657f8ab": "61f7224d61fc6fbd63a659f1a6aaddcc",
".git/objects/37/75653b4fd60fd4681e6965fee9c1f0920013cb": "c033db92c67ca74d304a9c339676d13d",
".git/objects/41/22332f9e6de6debce8c0a7b73f7475d6fda805": "5036ecaeda03d5c2c5e843769407e660",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/4c/a0ff80527a8c62400f4ec10fb14e1d5bb1a664": "41b77b9032cb65a8c179f6a96460088e",
".git/objects/50/8df0070e053d5e4103cf3da1e4097d6562e4ea": "8dc49af745e5ba1c8e39779cf20d67ad",
".git/objects/52/141931c8ec5e5e3bb80a910c3a76e5d2670d29": "f49cd4af745ea0a84b7887080f0faf68",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/62/c5b4698d6132846bc598ad9e143c127b0dbae2": "84e3e3e4177f4987e5837712ba32f1a9",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/79/78bae759b750837e9e1a2ccc1c06347899a892": "a55d54f48ed48723d38efd8aebfb265f",
".git/objects/81/db311a4a13d8bd64c8bf0ea14c26afe756d1a1": "6eb4604d1abb9307d78951d2ef307bbd",
".git/objects/83/61a03ab8af6223efd2376525e0c0e609378a1d": "80f5c697b5e28e11a95ea7c93ca504df",
".git/objects/86/6e2601a9e099dfaaf6c9fc985d2bd08e2ba182": "3eefdea8bc9474ee6501d64324ffcda6",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/a7/12cc55e0764e4974a63acb107cc48a2cb6c73b": "52473fc1546600cd4c933bff983447e0",
".git/objects/b0/091860094ebc4ef0f719a3e44ae44a78bb0f92": "11e95963ca654dbfb716056768ff81d2",
".git/objects/b1/29c20b16c9586bdf2f648ced2a2b4371d78b62": "f3033464f2a34cb353be1fe6c97140ee",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/ba/4cd5712412f546c8517d502a7049925d4cbc6c": "1811495bd716fc002dc01940b34f4c79",
".git/objects/c7/b608a5ebf66539ce9c88307541aa321d7285a7": "fd007dee7bb10fdce1f9655f08f180af",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/cd/23a0fb92bc6b714b4ebc3f55ef25d024f6e735": "e7b1f76967652fde7096a14b088b5d7a",
".git/objects/ce/512fe09c210e30fe57cf5aa2018297b8930360": "e82bf15b569aec97f4c118637717e6f6",
".git/objects/d1/8e5765c5246426e3325407be5982eab9da0c2b": "cbc54d4dc11fc9811e7d057badc59995",
".git/objects/d4/3163a2a530a84652e3b91cbfd38b24d207cded": "1d6a205c220bb5917a52815bf67ad5c8",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/55bf88a57c51ed0968f21ff37465e80a3ae518": "f3fe0b17be1c296edc19ddf4c3711b32",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e6/cc9c6a07cc689779057b10743957da4fcf4d16": "04fca2b401a0ce690c1a3a59c0c02d28",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/381df25b6c9bb2fad36a376012a3b1d17e8f3b": "97194fbcf8f3fe515065368a0bbf5464",
".git/objects/ef/9c8f0266d5657374f16c51e15c1831df9f8b6f": "d82adf3f5516a4cd459458f5c421351b",
".git/objects/f0/c3c82f56a56e4892ae3dd7df9b85d7d0ee8b9d": "6c561c855228edb1b0dae501d28df89a",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/refs/heads/gh-pages": "5e4205ed562f6494417b1acf8d3cc7b9",
".git/refs/remotes/origin/gh-pages": "5e4205ed562f6494417b1acf8d3cc7b9",
"assets/AssetManifest.bin": "8ac2455f155c8db94b276c1035d3eb26",
"assets/AssetManifest.bin.json": "171567ba4f750e7e1293efaab998384d",
"assets/AssetManifest.json": "33a5c87f0c34a1ba1f0daae06301544e",
"assets/assets/pos-system.png": "6200b8fa89d585077ddb668d32d02dbc",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "2a5988e2efb7641055d586c5b2cb2698",
"assets/NOTICES": "0390e41bdfe187424b3ee1b790f2cb21",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "bd02dea201a1f8df4cba5854b2127d94",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "aa65d6bdbe6a74fa275a13fa08df9f09",
"/": "aa65d6bdbe6a74fa275a13fa08df9f09",
"main.dart.js": "10791d9a6cbe99691da572c5beea1a08",
"manifest.json": "2847aa7d53fda00ca875ba4c9f0ebb3c",
"vercel.json": "d9a7ce65ae15c9b56ba55be0407d9e30",
"version.json": "1bb2316cc54d256b92a47e8fcdd91bc6",
"_redirects": "6a0a8d88b4e918e5dfc0618b40b57510"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
