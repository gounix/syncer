IMAGE=syncer
IMAGE_VERSION=1.0.0
UBUNTU_VERSION=26.04


.PHONY: dockerhub

dockerhub:
	buildah build --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} --build-arg SYNCER_VERSION=${IMAGE_VERSION} -t ${IMAGE}:${IMAGE_VERSION} .
	buildah push ${IMAGE}:${IMAGE_VERSION} gounix/${IMAGE}:${IMAGE_VERSION}

