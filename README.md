# SNI-Proxy
Very lean dynamic ingress traffic router based on alpine linux and inbound rules based URI and Port rewriting. Works for tls-sni and http-hostname based tcp traffic.

## Scope
This service discovery is based on docker embedded dns and solving multiple requirements:
- Port overlapping on HTTP and TCP (eg. SNI on TLS)
- End to end encryption with TLS passthrough
- Always up to date when further containers are spinned up or removed

## Warning
For more throughput and less CPU usage, zero-copy and tcp-splicing needs to be implemented in the underlying library. Golang also lacks support: https://github.com/golang/go/issues/10948

## Docker compose sample excerpts
```
version: '3.2'

services:

  sni-proxy:
    build: .
    environment:
      - LISTENERS=http;8080 tls;8443
      - RULES=portainer.*;portainer:9000 .*;*:8000
    ports:
      - "8080:8080"
      - "443:443"

  whoami-a:
    image: jwilder/whoami:latest
    networks:
      default:
        aliases:
          - whoami-a.vcap.me  

  whoami-b:
    image: jwilder/whoami:latest
    networks:
      default:
        aliases:
          - whoami-b.vcap.me  

  portainer:
    image: portainer/portainer
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --no-auth
    networks:
      default:
        aliases:
          - porainer.vcap.me

networks:
  default:
    driver: overlay
```

