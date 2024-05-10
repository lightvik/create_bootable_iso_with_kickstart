ARG OS_VERSION

FROM oraclelinux:${OS_VERSION:-9}-slim

ARG IMAGE_AUTHOR='lightvik@yandex.ru'

LABEL org.opencontainers.image.authors="${IMAGE_AUTHOR}"

RUN microdnf install -y xorriso genisoimage isomd5sum

WORKDIR /workdir

RUN mkdir --parents /workdir/extracted_iso

COPY --chmod=755 --chown=root:root entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "" ]