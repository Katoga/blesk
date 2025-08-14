FROM nginx:mainline-alpine AS runner

ARG NGINX_ENVSUBST_OUTPUT_DIR
RUN apk --no-cache upgrade \
  && mkdir -p "$NGINX_ENVSUBST_OUTPUT_DIR"

COPY ./nginx.conf /etc/nginx/

COPY ./*.conf.template /etc/nginx/templates/
