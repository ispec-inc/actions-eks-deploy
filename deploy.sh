#/bin/bash -l
exec /bin/bash -ec "export IMAGE_URI=$1"
echo IMAGE URL ${IMAGE_URI}
exec /bin/bash -ec "if [ -n "$2" ]; then
export IMAGE_TAG=$2
else
export IMAGE_TAG=$(git log -1 --pretty=%H)
fi"
echo IMAGE TAG ${IMAGE_TAG}
exec /bin/bash -ec "export KUBE_CONFIG_DATA=$3"
exec /bin/bash -ec "export KUBE_APPLY_DIR=$4"

docker build . -t $IMAGE_URI:$IMAGE_TAG
aws ecr get-login --no-include-email | sh
docker push $IMAGE_URI:$IMAGE_TAG
echo $IMAGE_URI:$IMAGE_TAG

export KUBECONFIG=/kubeconfig
touch KUBECONFIG
echo $KUBE_CONFIG_DATA | base64 -d > KUBECONFIG
cd $KUBE_APPLY_DIR
kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG
kubectl apply -k .
