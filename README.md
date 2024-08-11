[![Docker](https://github.com/amir-the-h/sub-proxy/actions/workflows/docker-publish.yml/badge.svg?branch=main)](https://github.com/amir-the-h/sub-proxy/actions/workflows/docker-publish.yml)
# SubdomainProxy

SubdomainProxy is a Dockerized Nginx server for routing HTTP/HTTPS traffic based on subdomains to specified upstream services. It automatically generates self-signed SSL certificates for secure connections, simplifying subdomain management and SSL termination in a containerized environment.

## Language Composition

- Shell: 74.6%
- Dockerfile: 25.4%

## Features

- Automatic subdomain routing
- Self-signed SSL certificate generation
- Simplified subdomain management
- SSL termination in a containerized environment

## Prerequisites

- Docker

## Getting Started

### Build Arguments
- `HTTP_PORT`: The port to listen for HTTP traffic. Default is 80.
- `HTTPS_PORT`: The port to listen for HTTPS traffic. Default is 443.
- `SUBDOMAIN`: The subdomain to route traffic to.
- `SDL`: The SDL part of domain.
- `TLD`: The TLD part of domain.
- `FORCE_RENEW`: Force renewing the SSL certificate. Default is false.
- `SERVICES`: The comma-separated list of pairs of service names and ports to route traffic to. Example: `frontend:3000,backend:9000`.

### Docker Compose
```yaml
services:
  proxy:
    image: amirtheh/sub-proxy
    build:
      args:
        HTTP_PORT: 8080 # OPTIONAL: To change the HTTP port to listen on. You can handle the port forwarding from Windows to WSL for example.
        HTTPS_PORT: 8443 # OPTIONAL: To change the HTTPS port to listen on. You can handle the port forwarding from Windows to WSL for example.
        SUBDOMAIN: local
        SDL: example
        TLD: com
        SERVICES: frontend:3000,backend:9000
    ports:
      - "80:8080" # The host port should be the same as the HTTP port
      - "443:8443" # The host port should be the same as the HTTPS port
    volumes:
      - ./certs:/proxy/certs # OPTIONAL: To persist SSL certificates and be able to reuse them or add them to the trusted certificates
      - ./conf.d:/etc/nginx/conf.d # OPTIONAL: To add custom Nginx configuration files or override the default ones
    networks:
      - proxy

networks:
  proxy:
    driver: bridge
```

```bash
docker-compose up -d
```

### License
This project is licensed under the MIT License - see the LICENSE file for details.

### Contributing
Contributions are welcome! Please open an issue or submit a pull request.

### Acknowledgments
[Docker](https://www.docker.com/)
[Nginx](https://www.nginx.com/)
[OpenSSL](https://www.openssl.org/)
