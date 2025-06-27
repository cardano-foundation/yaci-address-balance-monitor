VERSION 0.8

IMPORT --allow-privileged github.com/cardano-foundation/cf-gha-workflows/./earthfiles/functions:main AS functions

ARG --global DOCKER_IMAGES_TARGETS="yaci-address-balance-monitor"

ARG --global DOCKER_IMAGES_PREFIX=""
ARG --global DOCKER_IMAGES_EXTRA_TAGS=""
ARG --global DOCKER_IMAGES_LABELS=""
ARG --global DOCKER_REGISTRIES=""
ARG --global RELEASE_TAG=""
ARG --global TARGET_PLATFORM=""
ARG --global PUSH=false

all:
  LOCALLY
  FOR image_target IN $DOCKER_IMAGES_TARGETS
    BUILD +$image_target --PUSH=$PUSH
  END

docker-publish:
  BUILD +all --PUSH=$PUSH

docker-manifests-merge:
  ARG PLATFORMS
  LOCALLY
  FOR image_target IN $DOCKER_IMAGES_TARGETS
    DO functions+DOCKER_MANIFESTS_MERGE \
       --PLATFORMS="${PLATFORMS}" \
       --DOCKER_REGISTRIES="${DOCKER_REGISTRIES}" \
       --DOCKER_IMAGE_NAME="${DOCKER_IMAGES_PREFIX}${image_target}" \
       --DOCKER_IMAGES_EXTRA_TAGS="${DOCKER_IMAGES_EXTRA_TAGS}" \
       --PUSH=$PUSH
  END

yaci-address-balance-monitor:
  ARG EARTHLY_TARGET_NAME
  LET DOCKER_IMAGE_NAME=${DOCKER_IMAGES_PREFIX}${EARTHLY_TARGET_NAME}

  WAIT
    FROM DOCKERFILE ./
  END
  WAIT
    DO functions+DOCKER_LABELS --LABELS="${DOCKER_IMAGES_LABELS}"
    SAVE IMAGE ${DOCKER_IMAGE_NAME}
  END
  DO functions+DOCKER_TAG_N_PUSH \
     --PUSH=$PUSH \
     --TARGET_PLATFORM=${TARGET_PLATFORM} \
     --DOCKER_REGISTRIES="${DOCKER_REGISTRIES}" \
     --DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME} \
     --DOCKER_IMAGES_EXTRA_TAGS="${DOCKER_IMAGES_EXTRA_TAGS}"
