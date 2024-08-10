# Use the official nginx base image
FROM nginx:alpine

ENV HTTP_PORT=80
ENV HTTPS_PORT=443
ENV SUBDOMAIN=subdomain
ENV SDL=example
ENV TLD=com

# Install envsubst (part of the gettext package)
RUN apk --no-cache add gettext
# Install OpenSSL
RUN apk --no-cache add openssl

# Make the /templates directory
RUN mkdir -p /proxy/conf.d
# Make the /openssl directory
RUN mkdir -p /proxy/certs

# Copy nginx configuration templates
COPY conf.d/* /proxy/conf.d/
# Copy openssl configuration template
COPY openssl.cnf /proxy/openssl.cnf
# Copy certificates and private keys
COPY certs/* /proxy/certs/
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

EXPOSE 80:$HTTP_PORT
EXPOSE 443:$HTTPS_PORT

VOLUME ["/proxy"]

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
