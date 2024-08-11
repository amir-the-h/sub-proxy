#!/bin/sh

# Function to handle the SIGTERM signal
handle_term() {
    echo "Received SIGTERM, shutting down..."
    exit 0
}

trap 'handle_term' TERM INT

# Sanity check for /proxy/default.conf
if [ ! -f /proxy/default.conf ]; then
  echo "default.conf file not found."
  exit 1
fi

# Sanity check for the openssl.cnf file
if [ ! -f /proxy/openssl.cnf ]; then
  echo "openssl.cnf file not found."
  exit 1
fi

# Ensure SERVICES is set
if [ -z "$SERVICES" ]; then
  echo "SERVICES environment variable not set."
  exit 1
fi

BLOCKS=""
UPSTREAMS=""
IFS=',' 
set -- $SERVICES

for UPSTREAM in "$@"; do
  # Break the UPSTREAM into SERVICE and PORT by splitting on the colon
  SERVICE=$(echo $UPSTREAM | cut -d':' -f1)
  PORT=$(echo $UPSTREAM | cut -d':' -f2)
  UPSTREAMS="${UPSTREAMS}upstream $SERVICE {\n"
  UPSTREAMS="${UPSTREAMS}    server $SERVICE:$PORT;\n"
  UPSTREAMS="${UPSTREAMS}}\n"
  BLOCKS="$BLOCKS      if (\$host ~* \"^$SERVICE\.${SUBDOMAIN}\.${SDL}\.${TLD}$\") {\n"
  BLOCKS="$BLOCKS          set \$upstream \"$SERVICE\";\n"
  BLOCKS="$BLOCKS      }\n"
done

# Replace the block variable in the default.conf file
sed -i "s|##BLOCKS##|$BLOCKS|g" /proxy/default.conf
sed -i "s|##UPSTREAMS##|$UPSTREAMS|g" /proxy/default.conf

# Make a compile function to replace the environment variables in the given file
compile() {
  envsubst '${HTTP_PORT} ${HTTPS_PORT} ${SUBDOMAIN} ${SDL} ${TLD}' <$1 >$2
}

# Get the domain from the environment variables
DOMAIN=$SUBDOMAIN.$SDL.$TLD

# Compile the default.conf files
compile /proxy/default.conf /etc/nginx/conf.d/default.conf
echo "Compiled default.conf"

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
    -config /proxy/certs/$DOMAIN.cnf > /dev/null 2>&1

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
