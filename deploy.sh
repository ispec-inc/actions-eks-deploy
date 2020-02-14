#/bin/bash
export IMAGE_URI=$1
if [ -n "$2" ]; then
export IMAGE_TAG=$2
else
export IMAGE_TAG=$(git log -1 --pretty=%H)
fi
export KUBE_CONFIG_DATA=$3
export KUBE_APPLY_DIR=$4
exec /bin/bash -ec "docker build . -t $IMAGE_URI:$IMAGE_TAG"
exec /bin/bash -ec "aws ecr get-login --no-include-email | sh"
exec /bin/bash -ec "docker push $IMAGE_URI:$IMAGE_TAG"

export KUBECONFIG=/kubeconfig
touch KUBECONFIG
echo $KUBE_CONFIG_DATA | base64 -d > KUBECONFIG
exec /bin/bash "kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG"
exec /bin/bash "kubectl apply -f $KUBE_APPLY_DIR"
