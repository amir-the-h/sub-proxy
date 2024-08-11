# Use the official nginx base image
FROM nginx:alpine

ARG HTTP_PORT=80
ARG HTTPS_PORT=443
ARG SUBDOMAIN=subdomain
ARG SDL=example
ARG TLD=com
ARG FORCE_RENEW=false
# Upstreams names as an array
ARG UPSTREAMS=""
ENV HTTP_PORT=$HTTP_PORT
ENV HTTPS_PORT=$HTTPS_PORT
ENV SUBDOMAIN=$SUBDOMAIN
ENV SDL=$SDL
ENV TLD=$TLD
ENV FORCE_RENEW=$FORCE_RENEW
ENV UPSTREAMS=$UPSTREAMS

# Install envsubst (part of the gettext package)
RUN apk --no-cache add gettext
# Install OpenSSL
RUN apk --no-cache add openssl

# Make the /proxy directory
RUN mkdir -p /proxy/certs

# Copy nginx configuration templates
COPY conf.d/default.conf /proxy/default.conf
# Copy openssl configuration template
COPY openssl.cnf /proxy/openssl.cnf
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

EXPOSE 80:$HTTP_PORT
EXPOSE 443:$HTTPS_PORT

VOLUME ["/proxy"]

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
