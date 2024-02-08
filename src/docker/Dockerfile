FROM debian:bookworm-20240130-slim

LABEL MAINTAINER=deb4sh@github
LABEL org.opencontainers.image.source=https://github.com/deB4SH/KubernetesAzureAgent

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64
ENV DEBIAN_FRONTEND=noninteractive

# add user
RUN mkdir /azp \
    && useradd -ms /bin/bash worker \
    && mkdir -p /home/worker/.local/bin \
    && chown -R worker:worker /azp \
    && chown -R worker:worker /home/worker/.local
ENV PATH="$PATH:/home/worker/.local/bin"

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
    unzip \
    wget

#Install Kubernetes
RUN   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" --output-dir /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl


#Install KubeSeal
RUN curl -L https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.4/kubeseal-0.19.4-linux-amd64.tar.gz -o kubeseal-0.19.4-linux-amd64.tar.gz \
    && tar xfv kubeseal-0.19.4-linux-amd64.tar.gz -C /usr/local/bin

#Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

#Install Helm-Diff
ENV HELM_PLUGINS="/home/worker/.local/helm-plugin"
RUN  helm plugin install https://github.com/databus23/helm-diff \
    && chown -R worker:worker /home/worker/.local/helm-plugin

#Install Helmfile
RUN curl -L https://github.com/helmfile/helmfile/releases/download/v0.150.0/helmfile_0.150.0_linux_amd64.tar.gz -o  helmfile_0.150.0_linux_amd64.tar.gz && \
    tar xfv helmfile_0.150.0_linux_amd64.tar.gz -C /usr/local/bin

#Install argocd cli
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64

#Install Kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.0.0/kustomize_v5.0.0_linux_amd64.tar.gz -o kustomize_v5.0.0_linux_amd64.tar.gz && \
    tar xfv kustomize_v5.0.0_linux_amd64.tar.gz -C /usr/local/bin

#Install DotNet
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-8.0

#Install AzureCli
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Install vcluster CLI
RUN curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" \
    && install -c -m 0755 vcluster /usr/local/bin

#Install ms odbc 18 drivers and sqlcmd
#https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=debian18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc \
    && curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    #odbc driver
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    #sqlcmd and bcp
    && ACCEPT_EULA=Y apt-get install -y mssql-tools18
#add directory to path
ENV PATH="$PATH:/opt/mssql-tools18/bin"

WORKDIR /azp

COPY /src/docker/azure-scripts/start.sh .
#COPY /src/docker/azure-scripts/installdependencies.sh .
COPY /src/docker/scripts/entrypoint.sh .
RUN chmod +x start.sh entrypoint.sh


# install dependencies for dotNetcore
RUN apt install -y libssl3 libkrb5-3 zlib1g debsums

#clean up leftovers
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

USER worker
ENTRYPOINT [ "./entrypoint.sh", "-f", "/azp/init" ]
# FOR DEBUG PURPOSES
# ENTRYPOINT ["tail", "-f", "/dev/null"]
