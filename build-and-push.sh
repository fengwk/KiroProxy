#!/usr/bin/env bash

set -euo pipefail

echo "[docker] start build and push"

repo_full="${GITHUB_REPOSITORY:-}"
if [[ -z "${repo_full}" ]]; then
  echo "[docker] GITHUB_REPOSITORY is required" >&2
  exit 1
fi

repo_name="${repo_full##*/}"
repo_name_lc="$(printf '%s' "${repo_name}" | tr '[:upper:]' '[:lower:]')"
dockerhub_namespace="${DOCKERHUB_NAMESPACE:-${DOCKER_USERNAME:-}}"
if [[ -z "${dockerhub_namespace}" ]]; then
  echo "[docker] DOCKERHUB_NAMESPACE or DOCKER_USERNAME is required" >&2
  exit 1
fi
dockerhub_image="${dockerhub_namespace}/${repo_name_lc}"

ref="${GITHUB_REF:-}"
sha_short="$(printf '%s' "${GITHUB_SHA:-local}" | cut -c1-7)"

declare -a tags
if [[ "${ref}" == refs/tags/* ]]; then
  tag_name="${ref#refs/tags/}"
  tags=("${tag_name}" "latest")
elif [[ "${ref}" == "refs/heads/main" || "${ref}" == "refs/heads/docker" ]]; then
  tags=("latest" "sha-${sha_short}")
else
  tags=("sha-${sha_short}")
fi

echo "[docker] dockerhub image: ${dockerhub_image}"
echo "[docker] tags: ${tags[*]}"

first_tag="${tags[0]}"
docker build -t "${dockerhub_image}:${first_tag}" .

for tag in "${tags[@]}"; do
  if [[ "${tag}" != "${first_tag}" ]]; then
    docker tag "${dockerhub_image}:${first_tag}" "${dockerhub_image}:${tag}"
  fi
  docker push "${dockerhub_image}:${tag}"
done

echo "[docker] done"
