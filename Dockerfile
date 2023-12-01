ARG GROUP="awscurl"
ARG USER="user"
ARG USER_GROUP="${USER}:${GROUP}"
ARG HOME_DIR="/home/${USER}"

FROM python:3.12.0-alpine3.17 AS builder

ARG AWSCURL_VERSION="0.32"
ARG GROUP
ARG USER
ARG USER_GROUP
ARG HOME_DIR

RUN \
  set -ex && \
  apk add --no-cache --update \
    build-base \
    libffi-dev \
    libxml2-dev \
    openssl-dev \
    && \
  addgroup -g 10001 -S "${GROUP}" && \
  adduser -u 10000 -S "${USER}" -G "${GROUP}"

USER "${USER_GROUP}"

WORKDIR "${HOME_DIR}"

RUN \
  pip install --user botocore && \
  wget -q "https://github.com/okigan/awscurl/archive/refs/tags/v${AWSCURL_VERSION}.zip" -O ./awscurl.zip && \
  unzip -q ./awscurl.zip && \
  pip install --verbose --user "./awscurl-${AWSCURL_VERSION}"

FROM python:3.12.0-alpine3.17

ARG GROUP
ARG USER
ARG USER_GROUP
ARG HOME_DIR
ARG LOCAL="${HOME_DIR}/.local"
ARG BASHRC="${HOME_DIR}/.bashrc"

RUN \
  apk add --no-cache --update \
    aws-cli \
    bash \
    jq \
    && \
  sed -e 's/ash/bash/' -i /etc/passwd && \
  rm -rf \
    /var/cache/apk/* \
    && \
  addgroup -g 10001 -S "${GROUP}" && \
  adduser -u 10000 -S "${USER}" -G "${GROUP}" && \
  echo -e "complete -C aws_completer aws\nexport PATH=${LOCAL}/bin:\${PATH}" >> "${HOME_DIR}/.bashrc"

COPY --from=builder "${LOCAL}" "${LOCAL}"

USER "${USER_GROUP}"

WORKDIR "${HOME_DIR}"

ENTRYPOINT ["/bin/bash", "-l", "-c"]
