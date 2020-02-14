FROM gcr.io/cloud-builders/kubectl
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN apt-get update -y
RUN apt-get install -y libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev libreadline-dev libsqlite3-dev && \
    curl https://bootstrap.pypa.io/get-pip.py | python && \
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc

ARG pip_installer="https://bootstrap.pypa.io/get-pip.py"
ARG awscli_version="1.17.9"
ARG VERSION=3.5.4

# Install awscli
RUN pip install awscli==${awscli_version}

RUN curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin
RUN curl -Lo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v{$VERSION}/kustomize_${VERSION}_linux_amd64 && chmod +x kustomize && mv kustomize /usr/local/bin

RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN apt-get update
RUN apt-get -y install docker-ce

COPY deploy.sh /deploy.sh

ENTRYPOINT ["/bin/bash", "/deploy.sh"]
