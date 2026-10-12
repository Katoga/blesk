FROM nginxinc/nginx-unprivileged:mainline-alpine AS runner

USER root

ARG NGINX_ENVSUBST_TEMPLATE_DIR
ARG NGINX_ENVSUBST_OUTPUT_DIR

RUN apk --no-cache upgrade \
  && mkdir -p "$NGINX_ENVSUBST_TEMPLATE_DIR" \
  && mkdir -p "$NGINX_ENVSUBST_OUTPUT_DIR" \
  && chown nginx:root "$NGINX_ENVSUBST_TEMPLATE_DIR" "$NGINX_ENVSUBST_OUTPUT_DIR" \
  # && /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
  && sed -i -E 's~((\s+)listen(\s+)8080;)~\1\n\2listen\3[::]:8080;~' /etc/nginx/conf.d/default.conf

USER nginx

COPY --chown=nginx:root ./nginx.conf /etc/nginx/

COPY --chown=nginx:root  ./*.conf.template "$NGINX_ENVSUBST_TEMPLATE_DIR"
