#!/bin/sh

# Sanity check for the .conf files
if [ ! "$(ls -A /proxy/conf.d)" ]; then
  echo "No .conf files found in /proxy/conf.d"
  exit 1
fi

# Sanity check for the openssl.cnf file
if [ ! -f /proxy/openssl.cnf ]; then
  echo "openssl.cnf file not found."
  exit 1
fi

# Make a compile function to replace the environment variables in the given file
compile() {
  envsubst '${HTTP_PORT} ${HTTPS_PORT} ${SUBDOMAIN} ${SDL} ${TLD}' <$1 >$2
}

# Get the domain from the environment variables
DOMAIN=$SUBDOMAIN.$SDL.$TLD

# Compile the .conf files
for file in /proxy/conf.d/*.conf; do
  compile $file /etc/nginx/conf.d/$(basename $file)
  echo "Compiled $(basename $file)"
done

# Compile the openssl.cnf file
compile /proxy/openssl.cnf /proxy/certs/$DOMAIN.cnf
echo "Compiled openssl.cnf"

# Check if the certificate already exists, and not force the generation of a new one by FORCE_RENEW environment variable
if [ -f /proxy/certs/$DOMAIN.crt ] && [ -z $FORCE_RENEW ] && openssl x509 -checkend 86400 -noout -in /proxy/certs/$DOMAIN.crt; then
  # Certificate is still valid
  echo "Certificate exists and is still valid"
else
  # Generate the private key and CSR
  echo "Generating private key and CSR for $DOMAIN"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /proxy/certs/$DOMAIN.key \
    -out /proxy/certs/$DOMAIN.crt \
    -config /proxy/certs/$DOMAIN.cnf

  # Generate the certificate signed by the private key
  echo "Generating certificate signed by the private key"
  openssl req -new -key /proxy/certs/$DOMAIN.key \
    -out /proxy/certs/$DOMAIN.csr \
    -config /proxy/certs/$DOMAIN.cnf

  # Generate an X.509 certificate for 365 days
  echo "Generating X.509 certificate"
  openssl x509 -req -days 365 -in /proxy/certs/$DOMAIN.csr \
    -signkey /proxy/certs/$DOMAIN.key \
    -out /proxy/certs/$DOMAIN.crt \
    -extensions v3_req -extfile /proxy/certs/$DOMAIN.cnf

fi

nginx -g 'daemon off;'
