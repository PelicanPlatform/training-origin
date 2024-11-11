#!/bin/bash

# Making sure you are in the right directory, and that the right files exist.
# (bad things with Docker and permissions can happen otherwise..)
needed_files=$(cat << EOF
$(pwd)/config/issuer.jwk
$(pwd)/config/issuer-pub.jwks
/etc/hostcert.pem
/etc/hostkey.pem
$(pwd)/config/pelican.yaml
EOF
)

for needed_file in $needed_files ; do
    if [[ ! -f "$needed_file" ]] ; then
        echo "Necessary file not found: $needed_file"
        echo "Are you in the correct directory?"
        exit 1
    fi
done

if [[ ! -d "$(pwd)/data" ]] ; then
    echo "Necessary directory not found: $(pwd)/data"
    echo "Are you in the correct directory?"
    exit 1
fi

# Should be good to go now.
docker run --rm -it \
    -p 8444:8444 -p 8443:8443 \
    -v $(pwd)/config/issuer.jwk:/etc/pelican/issuer.jwk \
    -v $(pwd)/config/issuer-pub.jwks:/etc/pelican/issuer-pub.jwks \
    -v /etc/hostcert.pem:/etc/hostcert.pem \
    -v /etc/hostkey.pem:/etc/hostkey.pem \
    -v $(pwd)/config/pelican.yaml:/etc/pelican/pelican.yaml \
    -v $(pwd)/data:/data \
    hub.opensciencegrid.org/pelican_platform/origin:v7.11.2 \
    serve -p 8444
