FROM debian:bullseye-20220527-slim

LABEL MAINTAINER=deb4sh@github
LABEL org.opencontainers.image.source=https://github.com/deB4SH/KubernetesAzureAgent

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
ENV DEBIAN_FRONTEND=noninteractive

#Install general dependencies
RUN apt-get update && apt-get upgrade -y \
 && apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    gnupg \
    software-properties-common \
    gettext-base \
    wget

#Install Kubernetes
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y -qq --no-install-recommends kubectl

#Install KubeSeal
RUN curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/kubeseal-0.18.0-linux-amd64.tar.gz -o kubeseal-0.18.0-linux-amd64.tar.gz \
    && tar xfv kubeseal-0.18.0-linux-amd64.tar.gz -C /usr/local/bin

#Install DotNet
RUN wget https://dot.net/v1/dotnet-install.sh && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh -c 3.1
ENV PATH="$PATH:/root/.dotnet/"

#Install AzureCli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /azp

COPY /src/docker/azure-scripts/start.sh .
COPY /src/docker/azure-scripts/installdependencies.sh .
COPY /src/docker/scripts/entrypoint.sh .
RUN chmod +x start.sh installdependencies.sh entrypoint.sh

RUN /azp/installdependencies.sh

# clean up apt lists
RUN rm -rf /var/lib/apt/lists/*

# add user
RUN useradd -ms /bin/bash worker

RUN chown -R worker:worker /azp

USER worker

ENTRYPOINT [ "./entrypoint.sh", "-f", "/azp/init" ]
# FOR DEBUG PURPOSES
#ENTRYPOINT ["tail", "-f", "/dev/null"]