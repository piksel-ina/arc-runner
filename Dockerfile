FROM ghcr.io/actions/actions-runner:latest
USER root

ARG TF_VERSION=1.14.8

RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
      -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin && rm terraform.zip

RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip \
    && unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

RUN KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)" \
    && curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl

RUN curl -fsSL "https://deb.nodesource.com/setup_20.x" | bash - \
    && apt-get install -y nodejs

RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
       python3.12 python3.12-venv python3.12-dev python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages checkov detect-secrets yamllint

ARG TFDOCS_VERSION=v0.20.0
RUN curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-linux-amd64.tar.gz" \
      -o tfdocs.tar.gz \
    && tar -xzf tfdocs.tar.gz -C /usr/local/bin terraform-docs && rm tfdocs.tar.gz

RUN curl -s https://fluxcd.io/install.sh | bash

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -s /root/.local/bin/uv /usr/local/bin/uv

USER runner
