FROM nginxinc/nginx-unprivileged:mainline-alpine AS runner

USER root

ARG NGINX_ENVSUBST_TEMPLATE_DIR
ARG NGINX_ENVSUBST_OUTPUT_DIR

RUN apk --no-cache upgrade \
  && mkdir -p "$NGINX_ENVSUBST_TEMPLATE_DIR" \
  && mkdir -p "$NGINX_ENVSUBST_OUTPUT_DIR" \
  && chown nginx:root "$NGINX_ENVSUBST_TEMPLATE_DIR" "$NGINX_ENVSUBST_OUTPUT_DIR"

USER nginx

COPY --chown=nginx:root ./nginx.conf /etc/nginx/

COPY --chown=nginx:root  ./*.conf.template "$NGINX_ENVSUBST_TEMPLATE_DIR"
