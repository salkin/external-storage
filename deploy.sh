#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

export REGISTRY=quay.io/external_storage/

docker login -e="${QUAY_EMAIL}" -u "${QUAY_USERNAME}" -p "${QUAY_PASSWORD}" quay.io

provisioners=(
efs-provisioner
cephfs-provisioner
glusterblock-provisioner
iscsi-controller
local-volume-provisioner-bootstrap
local-volume-provisioner
nfs-client-provisioner
nfs-provisioner
rbd-provisioner
)

regex="^($(IFS=\|; echo "${provisioners[*]}"))-(v[0-9]\.[0-9]\.[0-9])$"
if [[ "${TRAVIS_TAG}" =~ $regex ]]; then
	PROVISIONER="${BASH_REMATCH[1]}"
	export VERSION="${BASH_REMATCH[2]}"
	if [[ "${PROVISIONER}" = nfs-provisioner ]]; then
		export REGISTRY=quay.io/kubernetes_incubator/
	fi
	echo "Pushing image '${PROVISIONER}' with tags '${VERSION}' and 'latest' to '${REGISTRY}'."
	make push-"${PROVISIONER}"
else
	echo "Nothing to deploy"
fi

