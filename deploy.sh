#/bin/bash
exec /bin/bash -ec "export IMAGE_URI=$1"
exec /bin/bash -ec "if [ -n "$2" ]; then
export IMAGE_TAG=$2
else
export IMAGE_TAG=$(git log -1 --pretty=%H)
fi"
exec /bin/bash -ec "export KUBE_CONFIG_DATA=$3"
exec /bin/bash -ec "export KUBE_APPLY_DIR=$4"
exec /bin/bash -ec "docker build . -t $IMAGE_URI:$IMAGE_TAG"
exec /bin/bash -ec "aws ecr get-login --no-include-email | sh"
exec /bin/bash -ec "docker push $IMAGE_URI:$IMAGE_TAG"
exec /bin/bash -ec "echo $IMAGE_URI:$IMAGE_TAG"

exec /bin/bash -ec "export KUBECONFIG=/kubeconfig"
exec /bin/bash -ec "touch KUBECONFIG"
exec /bin/bash -ec "echo $KUBE_CONFIG_DATA | base64 -d > KUBECONFIG"
exec /bin/bash -ec "kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG"
exec /bin/bash -ec "kubectl apply -f $KUBE_APPLY_DIR"
