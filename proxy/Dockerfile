# Use the official nginx base image
FROM nginx:alpine

# Install envsubst (part of the gettext package)
RUN apk --no-cache add gettext
# Install OpenSSL
RUN apk --no-cache add openssl

# Make the /templates directory
RUN mkdir -p /templates/conf.d
# Make the /openssl directory
RUN mkdir -p /openssl/certs

# Copy nginx configuration templates
COPY conf.d.templates/* /templates/conf.d
# Copy openssl configuration template
COPY openssl.cnf.template /templates/openssl.cnf.template
# Copy certificates and private keys
COPY certs/* /openssl/certs/
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
