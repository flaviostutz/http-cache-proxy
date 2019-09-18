# nginx-cache-proxy
This enables any HTTP service to employ a front cache to minimize unnecessary calls by employing a front cache with nginx

## Usage

* Create a docker-compose.yml file

```yml
version: '3.7'
services:
  nginx-cache-proxy:
    image: flaviostutz/nginx-cache-proxy
    ports:
      - 8282:80
    environment:
      - PROXY_PASS_URL=http://map-demos/

  map-demos:
    image: flaviostutz/map-demos
    ports: 
      - 8181:80
    restart: always
```

* Run 'docker-compose up'

* Open 'http://localhost:8282'

* Open network tab in your browser and check for the header "X-Cache-Status"
  * On first call it is meant to be 'MISS' and in the following calls 'HIT'

## ENV configurations

All ENV configurations have the same name as in NGINX documentation. Check http://nginx.org/en/docs/http/ngx_http_proxy_module.html for details

* CORE_SEND_FILE 'on'
* CORS_ALLOW_ORIGIN '*'

* PROXY_PASS_URL ''
* PROXY_READ_TIMEOUT '30s'
* PROXY_LIMIT_RATE_BYTES_PER_SECOND '0'
* PROXY_COOKIE_DOMAIN 'www.test.com localhost'

* SERVE_PATH '/_www' - custom http path for serving files under dir /www
* REDIR_FROM_PATH '/_test' - path from which to redirect to serve path so that the request will be handled by a file in this proxy

* CACHE_MAX_SIZE '1g'
* CACHE_KEY_SIZE '10m'
* CACHE_MIN_USES '1'
* CACHE_MAX_IDLE_HOURS '12'
* CACHE_INACTIVE_TIME '24h'
* CACHE_KEY '$scheme$proxy_host$uri$is_args$args'
* CACHE_LOCK 'on'
* CACHE_REVALIDATE 'off'
* CACHE_BYPASS '$http_pragma'
* CACHE_BACKGROUND_UPDATE 'on'
* CACHE_USE_STALE 'error timeout invalid_header updating http_500 http_502 http_503 http_504'
* CACHE_METHODS 'GET HEAD'
* CACHE_BYPASS '$cookie_nocache $arg_nocache'
* UPSTREAM_CACHE_STATUS '$upstream_cache_status'
