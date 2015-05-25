#!/bin/sh

export DDNS_USERNAME=
export DDNS_TOKEN=
export DDNS_DOMAIN=

export SLACK_WEBHOOK=

export OAGR_NGINX_PASSWORD=
export OAGR_MYTARDIS_CHECKOUT=
export OAGR_TIMEZONE=
export OAGR_DEBUG=
export OAGR_ALLOWED_HOSTS=

export OAGR_DOI_APP_ID=
export OAGR_DOI_SHARED_SECRET=
export OAGR_DOI_URL=

export OAGR_USERNAME=
export OAGR_PASSWORD=

export OAGR_DB_USER=
export OAGR_DB_NAME=

export OAGR_S3_ID=
export OAGR_S3_SECRET=
export OAGR_S3_BUCKET=
export OAGR_S3_HOST=

read -d '' OAGR_HTTPS_BUNDLE << EOF
EOF

export OAGR_HTTPS_BUNDLE

version=master

curl --silent --location https://github.com/modc08/nectar-shell/raw/$version/run.sh | sh
