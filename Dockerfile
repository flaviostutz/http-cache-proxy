FROM nginx:1.17.0

RUN \
  apt-get update \
  && apt-get -y install gettext-base \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* 

ENV CORE_SEND_FILE 'on'

ENV PROXY_PASS_URL ''
ENV PROXY_READ_TIMEOUT '30s'
ENV PROXY_LIMIT_RATE_BYTES_PER_SECOND '0'

ENV CACHE_MAX_SIZE '1g'
ENV CACHE_KEY_SIZE '10m'
ENV CACHE_MIN_USES '1'
ENV CACHE_MAX_IDLE_HOURS '12'
ENV CACHE_INACTIVE_TIME '24h'
ENV CACHE_KEY '$scheme$proxy_host$uri$is_args$args'
ENV CACHE_LOCK 'on'
ENV CACHE_REVALIDATE 'off'
ENV CACHE_BYPASS '$http_pragma'
ENV CACHE_BACKGROUND_UPDATE 'on'
ENV CACHE_USE_STALE 'error timeout invalid_header updating http_500 http_502 http_503 http_504'
ENV CACHE_METHODS 'GET HEAD'
ENV CACHE_BYPASS '$cookie_nocache $arg_nocache $http_cache_control'
ENV UPSTREAM_CACHE_STATUS '$upstream_cache_status'

ADD /default.conf /etc/nginx/conf.d/
ADD /startup.sh /

VOLUME [ "/nginx/cache" ]

CMD ["/startup.sh"]
