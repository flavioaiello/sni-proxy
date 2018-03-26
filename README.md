[![Docker Build Status](https://img.shields.io/docker/build/flavioaiello/sni-proxy.svg?style=for-the-badge)](https://hub.docker.com/r/flavioaiello/sni-proxy/)
[![Docker Stars](https://img.shields.io/docker/stars/flavioaiello/sni-proxy.svg?style=for-the-badge)](https://hub.docker.com/r/flavioaiello/sni-proxy/)
[![Docker Pulls](https://img.shields.io/docker/pulls/flavioaiello/sni-proxy.svg?style=for-the-badge)](https://hub.docker.com/r/flavioaiello/sni-proxy/)

# DEPRECATION NOTICE
Use https://github.com/flavioaiello/swarm-router instead!

# SNI-Proxy
Very lean dynamic ingress traffic router based on alpine linux and inbound rules based URI and Port rewriting. Works for tls-sni and http-hostname based tcp traffic.

## Scope
Solving multiple requirements:
- Port overlapping on HTTP and HTTPS (eg. SNI on TLS or Hostname on HTTP)
- End to end encryption with TLS passthrough (This is the SNI part)
- Service name based routing
- Always up to date when further containers are spinned up or removed

## Docker Swarm Mode 1.12+
Built for docker swarm mode ingress networking: Secure service discovery using fqdn forwarding with dns resolution based on  embedded dns. Therefore there is no need to mount the docker socket and maintain labels on compose recipe. Just define your fully qualified service names per network as shown in the sample excerpts below. Lean and secure alternative to [Traefik](http://traefik.io), [Fabio](https://github.com/fabiolb/fabio), [Gobetween](http://gobetween.io/), [Dockerflow](http://proxy.dockerflow.com/), etc.

## Performance
This sniproxy-lib based project does NOT performs good as haproxy. For more throughput and less CPU usage, zero-copy and tcp-splicing needs to be implemented in the underlying library. Golang also lacks support: https://github.com/golang/go/issues/10948. (All golang based projects like Traefik etc. are also affected)

## Docker compose sample excerpts
```
version: '3.2'

services:

  sni-proxy:
    build: .
    environment:
      - LISTENERS=http;8080 tls;8443
      - RULES_HTTP=whoami.*;whoami:8000 .*;*:8080
      - RULES_TLS=.*;*:8443
    ports:
      - "80:8080"
      - "443:8443"
      - "8080:8080"
      - "8443:8443"

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

