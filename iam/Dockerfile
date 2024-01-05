FROM jboss/keycloak:11.0.2

USER root

# Script for adding users based on environment vars
COPY ./scripts/add-dyet-users.sh /srv/dyet/add-users.sh
RUN chmod 777 /srv/dyet/add-users.sh

USER jboss

# Settings
ENV PROXY_ADDRESS_FORWARDING=true

# Theme
COPY ./themes/DoYouEvenTrack /opt/jboss/keycloak/themes/FitTrack

# Import realm
COPY ./realm-export.json /tmp/realm-export.json
ENV KEYCLOAK_IMPORT="/tmp/realm-export.json -Dkeycloak.profile.feature.upload_scripts=enabled"

# Plugin
COPY ./plugins/event_listener/target/event-listener.jar /opt/jboss/keycloak/standalone/deployments/