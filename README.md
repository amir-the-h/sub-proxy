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
- Docker Compose

## Getting Started

### Clone the repository

```bash
git clone https://github.com/amir-the-h/sub-proxy.git
cd sub-proxy
```

### Configuration
Update the `nginx.conf` file to configure your subdomain routing rules.
Add your upstream services in the `upstreams.conf` file and docker-compose services in the `docker-compose.yml` file.

### Build and run the Docker container
```bash
docker-compose up --build -d
```

### License
This project is licensed under the MIT License - see the LICENSE file for details.

### Contributing
Contributions are welcome! Please open an issue or submit a pull request.

### Acknowledgments
[Docker](https://www.docker.com/)
[Nginx](https://www.nginx.com/)
[OpenSSL](https://www.openssl.org/)
