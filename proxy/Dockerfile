# Use the official nginx base image
FROM nginx:alpine

# Install envsubst (part of the gettext package)
RUN apk --no-cache add gettext
# Install OpenSSL
RUN apk --no-cache add openssl

# Make the /templates directory
RUN mkdir -p /proxy/conf.d
# Make the /openssl directory
RUN mkdir -p /proxy/openssl/certs

# Copy nginx configuration templates
COPY conf.d/* /proxy/conf.d
# Copy openssl configuration template
COPY openssl.cnf.template /proxy/openssl.cnf.template
# Copy certificates and private keys
COPY certs/* /proxy/openssl/certs/
# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
