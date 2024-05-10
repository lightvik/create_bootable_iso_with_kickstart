WIP

```
DOCKER_IMAGE='create_bootable_iso_with_kickstart'
DOCKER_TAG='1.0.0'
ISO_LABEL='OL-9-4-0-BaseOS-x86_64'
INPUT_ISO_FILENAME='OracleLinux-R9-U4-x86_64-dvd.iso'
OUTPUT_ISO_FILENAME='OracleLinux-R9-U4-x86_64-dvd_kickstart.iso'
```

```
docker build \
--tag "${DOCKER_IMAGE}:${DOCKER_TAG}" \
.
```

```
docker run \
--interactive \
--tty \
--rm \
--volume "${PWD}:/workdir" \
"${DOCKER_IMAGE}:${DOCKER_TAG}" "${ISO_LABEL}" "${INPUT_ISO_FILENAME}" "${OUTPUT_ISO_FILENAME}"
```