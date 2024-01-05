FROM cypress/included:6.2.0
# rsync & make
RUN apt-get --allow-releaseinfo-change update -y && \
    apt-get upgrade -y --fix-missing && \
    apt-get install -y \
                    rsync \
                    make \
                    gettext-base
# kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
ENV KUBECONFIG=/e2e/kubeconfig§
# dependencies
WORKDIR /e2e
COPY ./package.json /e2e/package.json
COPY ./package-lock.json /e2e/package-lock.json
COPY ./tsconfig.json /e2e/tsconfig.json
RUN npm install
# Utils
RUN apt install jq -y
RUN wget https://github.com/mikefarah/yq/releases/download/v4.31.2/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq
ENV SOPS_VERSION=3.7.3
RUN wget https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux -O /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops
ENTRYPOINT [ "cypress" ]
