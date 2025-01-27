#!/bin/bash
set -x
echo '//////===--- Welcome to DEVCMD container ---===\\\\\\'

DEVCMD_ENV="$1"
if [ -z "$DEVCMD_ENV" ]; then DEVCMD_ENV=dev; fi

if [ ! -f "/etc/profile.d/devcmd-profile.sh" ]; then
    ln -s "$DEVCMD_BIN_DIR/devcmd-profile.sh" /etc/profile.d/devcmd-profile.sh
fi

# ensure DEVCMD temp folder exists accross all containers:
mkdir -p "$DEVCMD_TEMP"

# expose DEVCMD CLI
for f in devcmd-env devcmd-db devcmd-build-service; do
    ln -sf "$DEVCMD_ROOT/devcmd-devops/devcmd/$f.sh" "/usr/local/bin/$f"
done

# setup git config
if [ -f "/home/$HOST_USER/.gitconfig" -a ! -e /root/.gitconfig ]; then
    ln -s /home/$HOST_USER/.gitconfig /root/.gitconfig
fi

# enable GCP integration
if [ -f "$DEVCMD_GCP_KEY" -a "$DEVCMD_GCP_PROJECT_ID" != "" ]; then
    echo "Connecting to $DEVCMD_ENV environment on GCP, please wait..."
    gcloud auth activate-service-account "--key-file=$$DEVCMD_GCP_KEY"
    gcloud auth configure-docker "$DEVCMD_GCP_AR_REPO" --quiet
    gcloud config set project $DEVCMD_GCP_PROJECT_ID
    devcmd-env "$DEVCMD_ENV"
else
    echo "Note: DEVCMD-GCP integration disabled. Configure DEVCMD_GCP_PROJECT_ID, DEVCMD_GCP_KEY path in your .env file to enable."
fi

# setup non-root user
if [ "$HOST_UID" != "" -a "$HOST_UID" != "1000" ]; then
    existing_group=`getent group "$HOST_GID"`
    if [ $? -eq 2 ]; then
        echo "Linking host user group $HOST_GROUP ($HOST_GID) to new container group $existing_group"
        echo "Adding unix group $HOST_GROUP ($HOST_GID)"
        addgroup -q --gid $HOST_GID "$HOST_GROUP"
    else
        echo "Linking host user group $HOST_GROUP ($HOST_GID) to existing container group $existing_group"
    fi
    echo "Linking host user $HOST_USER ($HOST_UID) with container"
    adduser -q --uid $HOST_UID --gid "$HOST_GID" --home "/home/$HOST_USER" --no-create-home --disabled-password --gecos "" "$HOST_USER"
    su "$HOST_USER"
else
    bash --login
fi
