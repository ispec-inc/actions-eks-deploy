FROM python:3.6

ARG pip_installer="https://bootstrap.pypa.io/get-pip.py"
ARG awscli_version="1.17.9"

# Install awscli
RUN pip install awscli==${awscli_version}

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN curl -Lo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v{$VERSION}/kustomize_${VERSION}_linux_amd64 && chmod +x kustomize && mv kustomize /usr/local/bin

COPY deploy.sh /deploy.sh

ENTRYPOINT ["/bin/bash", "/deploy.sh"]
