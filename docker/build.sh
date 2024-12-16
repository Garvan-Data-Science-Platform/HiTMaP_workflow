#!/bin/bash

# Usage
helpmsg() {
    echo "Build the HiTMaP docker image."
    echo -e "\nUsage: ./build.sh [-c|--commit COMMIT_HASH]"
    echo -e "Display this help message: $0 -h\n"
    echo -e "\tCOMMIT_HASH:    Commit hash or git tag of HiTMaP version to install. Defaults to 'df20be1'."
}

# Command line arguments
COMMIT_HASH="df20be1"
TAG="latest"

# Arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
        key="$1"
        case ${key} in
                -h|--help)
                        helpmsg
                        exit 0
                        ;;
                -c|--commit)
                        COMMIT_HASH="${2}"
                        TAG="${2}"
                        shift
                        shift
                        ;;
                *)
                        POSITIONAL+=("$1")
                        shift
                        ;;
        esac
done

set -- "${POSITIONAL[@]}"

set -euo pipefail

# Copy install.template.R to install.R and
# replace placeholder values with actual values
sed -e "s/HITMAPCOMMIT/${COMMIT_HASH}/" install.template.R > install.R

# Build the docker image
docker build -t hitmap:${TAG} -f Dockerfile_use_build_script .