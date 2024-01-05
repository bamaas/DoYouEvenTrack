#!/bin/bash
START=0
END=$(env | grep DOYOUEVENTRACK_EMAIL | wc -l)
((END=${END}-1))

for (( c=$START; c<=$END; c++ ))
do

    PASSWORD="DOYOUEVENTRACK_PASSWORD_${c}"
    PASSWORD=$(echo "${!PASSWORD}")

    FIRSTNAME="DOYOUEVENTRACK_FIRSTNAME_${c}"
    FIRSTNAME=$(echo "${!FIRSTNAME}")

    LASTNAME="DOYOUEVENTRACK_LASTNAME_${c}"
    LASTNAME=$(echo "${!LASTNAME}")

    EMAIL="DOYOUEVENTRACK_EMAIL_${c}"
    EMAIL=$(echo "${!EMAIL}")

    /opt/jboss/keycloak/bin/kcadm.sh create users -r FitTrack -s enabled=true -s username=${EMAIL} -s firstName=${FIRSTNAME} -s lastName=${LASTNAME} -s email=${EMAIL} -s emailVerified=true
    /opt/jboss/keycloak/bin/kcadm.sh set-password -r FitTrack --username ${EMAIL} --new-password ${PASSWORD}
done