#!/bin/sh
#
# MIT License
#
# Copyright (c) 2026 gounix
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
EXIT_OK=0
EXIT_NO_ENV=1
EXIT_LOGIN_FAILED=2
EXIT_GIT_CLONE_FAILED=3
EXIT_GIT_CHECKOUT_FAILED=4
EXIT_GIT_DIR_NOT_FOUND=5
EXIT_MAKE_FAILED=6
EXIT_PULL_FAILED=7
EXIT_PUSH_FAILED=8

echo Starting syncer version: Development-version
if [ X${SRC_REGISTRY} = X ]; then
	echo variable SRC_REGISTRY not set
	exit $EXIT_NO_ENV
fi
if [ X${SRC_TLS_VERIFY} = X ]; then
	echo variable SRC_TLS_VERIFY not set
	exit $EXIT_NO_ENV
fi
if [ X${SRC_IMAGE} = X ]; then
	echo variable SRC_IMAGE not set
	exit $EXIT_NO_ENV
fi
if [ X${SRC_IMAGE_VERSION} = X ]; then
	echo variable SRC_IMAGE_VERSION not set
	exit $EXIT_NO_ENV
fi
if [ X${DST_REGISTRY} = X ]; then
	echo variable DST_REGISTRY not set
	exit $EXIT_NO_ENV
fi
if [ X${DST_TLS_VERIFY} = X ]; then
	echo variable DST_TLS_VERIFY not set
	exit $EXIT_NO_ENV
fi
if [ X${DST_IMAGE} = X ]; then
	echo variable DST_IMAGE not set
	exit $EXIT_NO_ENV
fi

if [ X${SRC_REGISTRY_AUTHENTICATED} = X ]; then
	echo variable SRC_REGISTRY_AUTHENTICATED not set
	exit $EXIT_NO_ENV
fi

if [ X${SRC_REGISTRY_AUTHENTICATED} = Xtrue ]; then
	if [ X${SRC_REGISTRY_USER} = X ]; then
		echo variable SRC_REGISTRY_USER not set
		exit $EXIT_NO_ENV
	fi
	if [ X${SRC_REGISTRY_PASSWORD} = X ]; then
		echo variable SRC_REGISTRY_PASSWORD not set
		exit $EXIT_NO_ENV
	fi
fi

if [ X${DST_REGISTRY_AUTHENTICATED} = X ]; then
	echo variable DST_REGISTRY_AUTHENTICATED not set
	exit $EXIT_NO_ENV
fi

if [ X${DST_REGISTRY_AUTHENTICATED} = Xtrue ]; then
	if [ X${DST_REGISTRY_USER} = X ]; then
		echo variable DST_REGISTRY_USER not set
		exit $EXIT_NO_ENV
	fi
	if [ X${DST_REGISTRY_PASSWORD} = X ]; then
		echo variable DST_REGISTRY_PASSWORD not set
		exit $EXIT_NO_ENV
	fi
fi

echo all variables set
echo SRC_REGISTRY=$SRC_REGISTRY
echo SRC_TLS_VERIFY=$SRC_TLS_VERIFY
echo SRC_IMAGE=$SRC_IMAGE
echo SRC_IMAGE_VERSION=$SRC_IMAGE_VERSION
echo DST_REGISTRY=$DST_REGISTRY
echo DST_TLS_VERIFY=$DST_TLS_VERIFY
echo DST_IMAGE=$DST_IMAGE

echo SRC_REGISTRY_USER=$SRC_REGISTRY_USER
echo SRC_REGISTRY_PASSWORD=XXXXXXX
echo SRC_REGISTRY_AUTHENTICATED=$SRC_REGISTRY_AUTHENTICATED

echo DST_REGISTRY_USER=$DST_REGISTRY_USER
echo DST_REGISTRY_PASSWORD=XXXXXXX
echo DST_REGISTRY_AUTHENTICATED=$DST_REGISTRY_AUTHENTICATED

SRC_ARGS=""
if [ X$SRC_TLS_VERIFY = Xfalse ]; then
	SRC_ARGS="--tls-verify=false"
fi

DST_ARGS=""
if [ X$DST_TLS_VERIFY = Xfalse ]; then
	DST_ARGS="--tls-verify=false"
fi

if [ X${SRC_REGISTRY_AUTHENTICATED} = Xtrue ]; then
	echo buildah login ${SRC_ARGS} ${SRC_REGISTRY}
	echo ${SRC_REGISTRY_PASSWORD} | buildah login ${SRC_ARGS} ${SRC_REGISTRY} --username ${SRC_REGISTRY_USER} --password-stdin
	if [ $? -ne 0 ]; then
		echo buildah login failed on ${SRC_REGISTRY}
		exit $EXIT_LOGIN_FAILED
	fi
fi

if [ X${DST_REGISTRY_AUTHENTICATED} = Xtrue ]; then
	echo buildah login ${DST_ARGS} ${DST_REGISTRY}
	echo ${DST_REGISTRY_PASSWORD} | buildah login ${DST_ARGS} ${DST_REGISTRY} --username ${DST_REGISTRY_USER} --password-stdin
	if [ $? -ne 0 ]; then
		echo buildah login failed on ${DST_REGISTRY}
		exit $EXIT_LOGIN_FAILED
	fi
fi

buildah pull ${SRC_ARGS} ${SRC_REGISTRY}/${SRC_IMAGE}:${SRC_IMAGE_VERSION}
if [ $? -ne 0 ]; then
	echo buildah pull failed
	exit $EXIT_PULL_FAILED
fi

buildah push ${DST_ARGS} ${SRC_REGISTRY}/${SRC_IMAGE}:${SRC_IMAGE_VERSION} docker://${DST_REGISTRY}/${DST_IMAGE}:${SRC_IMAGE_VERSION}
if [ $? -ne 0 ]; then
	echo buildah PUSH failed
	exit $EXIT_PUSH_FAILED
fi

exit $EXIT_OK
