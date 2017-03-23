FROM alpine:3.3
MAINTAINER "Titan Lien" <titan.lien@gmail.com>

ENV ANSIBLE_VERSION=2.2.1.0

RUN set -ex && \
    buildDeps="python-dev build-base libffi-dev openssl-dev" && \
    apk add --no-cache $buildDeps python py-pip ca-certificates bash tar && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir ansible==${ANSIBLE_VERSION} && \
    apk del --purge $buildDeps

CMD ["ansible"]
