# DNS over HTTPS server

This Dockerfile builds a DoH (DNS-over-HTTPS) server from the [source](https://github.com/m13253/dns-over-https).

- The *dnsoverhttps* user inside the Docker image has the UID 1000.
- ```/etc/dns-over-https``` is available as volume and contains the configuration file ```doh-server.conf``` used by the server.
- The server itself is listening on port 80, which is exposed.
- Workdir is ```/```.
