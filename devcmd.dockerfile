FROM ubuntu

RUN apt-get update &&\
	apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release openssh-client wget zip software-properties-common vim python3-venv python3-pip gettext

RUN mkdir -m 0755 -p /etc/apt/keyrings

# https://docs.docker.com/engine/install/ubuntu/
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
	echo \
  		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  		$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null &&\
	apt-get update &&\
	apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# https://cloud.google.com/sdk/docs/install-sdk#deb
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - &&\
	apt-get update && apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# https://www.mongodb.com/docs/v5.0/tutorial/install-mongodb-on-ubuntu/
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add - &&\
	echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list &&\
	apt-get update &&\
	apt-get install -y mongodb-mongosh mongodb-org-tools

# RUN curl -s https://deb.nodesource.com/setup_18.x | bash &&\
# 	apt-get update &&\
# 	apt install -y nodejs &&\
# 	npm install -g yarn

# RUN cd /tmp &&\
# 	curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh -o install_nvm.sh &&\
# 	chmod +x install_nvm.sh &&\
# 	./install_nvm.sh

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

ENV IS_DEVCMD=true
ENV DEVCMD_ROOT=/code
ENV DEVCMD_TEMP=$DEVCMD_ROOT/temp
ENV HOST_UID=1000
ENV USER=root
ENV DEVCMD_BIN_DIR=/opt/devcmd

# ADD devcmd-start.sh /usr/local/bin/devcmd-start
# ADD devcmd-k8s-env.sh /usr/local/bin/devcmd-k8s-env
# ADD devcmd-mongo.sh /usr/local/bin/devcmd-mongo-utils
# RUN chmod +x /usr/local/bin/devcmd*
# ADD devcmd-profile.sh /etc/profile.d/

WORKDIR $DEVCMD_ROOT
ENTRYPOINT [ "bash", "/opt/devcmd/devcmd-start.sh" ]
