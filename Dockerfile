ARG ALPINE_VERSION="3.18"
FROM alpine:${ALPINE_VERSION}

ARG AWSCURL_VERSION="0.2.1"
ARG GROUP="awscurl"
ARG USER="user"

RUN \
  apk add --no-cache --update \
    aws-cli \
    bash \
    jq \
  && sed -e 's/ash/bash/' -i /etc/passwd \
  && wget -q https://github.com/legal90/awscurl/releases/download/${AWSCURL_VERSION}/awscurl_${AWSCURL_VERSION}_linux_amd64.zip -O awscurl.zip \
  && unzip -q awscurl.zip -x LICENSE \
  && mv awscurl /bin \
  && rm -rf \
    ./awscurl.zip \
    /var/cache/apk/* \
  && addgroup -g 10001 -S ${GROUP} \
  && adduser -u 10000 -S ${USER} -G ${GROUP} \
  && echo "complete -C aws_completer aws" >> /home/${USER}/.bashrc

USER ${USER}:${GROUP}

ENTRYPOINT ["/bin/bash", "-l", "-c"]
