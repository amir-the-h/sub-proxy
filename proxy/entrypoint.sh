#!/bin/sh

# Check if there is no .template file is in /templates/conf.d/
if [ ! -f /templates/conf.d/*.template ]; then
  echo "No Nginx configuration template found."
  exit 1
fi

# Check if there is no /templates/openssl.cnf.template file
if [ ! -f /templates/openssl.cnf.template ]; then
  echo "openssl.cnf.template file not found."
  exit 1
fi

# Check all the .template files in /templates/conf.d/ and substitute environment variables and remove the .template extension
for file in /templates/conf.d/*.template; do
  envsubst '${HTTP_PORT} ${HTTPS_PORT} ${SUBDOMAIN} ${SDL} ${TLD}' <$file >/etc/nginx/conf.d/$(basename $file)
  # Announce the file has been processed
  echo "Processed $(basename $file)"
done

# Get the domain from the environment variables
DOMAIN=$SUBDOMAIN.$SDL.$TLD

# Do the same for the openssl.cnf.template file
envsubst '${HTTP_PORT} ${HTTPS_PORT} ${SUBDOMAIN} ${SDL} ${TLD}' </templates/openssl.cnf.template >/openssl/certs/$DOMAIN.cnf

# Check if the certificate already exists, and not force the generation of a new one by FORCE_RENEW environment variable
if [ -f /openssl/certs/$DOMAIN.crt ] && [ -z $FORCE_RENEW ] && openssl x509 -checkend 86400 -noout -in /openssl/certs/$DOMAIN.crt; then
  # Certificate is still valid
  echo "Certificate exists and is still valid"
else
  # Generate the private key and CSR
  echo "Generating private key and CSR for $DOMAIN"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /openssl/certs/$DOMAIN.key \
    -out /openssl/certs/$DOMAIN.crt \
    -config /openssl/certs/$DOMAIN.cnf

  # Generate the certificate signed by the private key
  echo "Generating certificate signed by the private key"
  openssl req -new -key /openssl/certs/$DOMAIN.key \
    -out /openssl/certs/$DOMAIN.csr \
    -config /openssl/certs/$DOMAIN.cnf

  # Generate an X.509 certificate for 365 days
  echo "Generating X.509 certificate"
  openssl x509 -req -days 365 -in /openssl/certs/$DOMAIN.csr \
    -signkey /openssl/certs/$DOMAIN.key \
    -out /openssl/certs/$DOMAIN.crt \
    -extensions v3_req -extfile /openssl/certs/$DOMAIN.cnf

fi

nginx -g 'daemon off;'
