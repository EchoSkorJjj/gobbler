FROM kong/kong-gateway:3.2.1.0
USER root

ENV KONG_PLUGINS=authentication_plugin

COPY kong.yml /
COPY ./authentication_plugin /usr/local/share/lua/5.1/kong/plugins/authentication_plugin
COPY certs /etc/kong/ssl

USER kong

RUN cp /etc/kong/kong.conf.default /etc/kong/kong.conf
