#/bin/bash -l
echo $*
export IMAGE_URI=$1
echo IMAGE URL $IMAGE_URI
if [ -n "$2" ]; then
export IMAGE_TAG=$2
else
export IMAGE_TAG=$(git log -1 --pretty=%H)
fi
echo IMAGE TAG $IMAGE_TAG
export KUBE_CONFIG_DATA=$3
echo $KUBE_CONFIG_DATA
export KUBE_APPLY_DIR=$4
export AWS_ACCESS_KEY_ID=$5
echo $AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$6
echo $AWS_SECRET_ACCESS_KEY
export AWS_REGION=$7

docker build . -t $IMAGE_URI:$IMAGE_TAG
aws ecr get-login --no-include-email | sh
docker push $IMAGE_URI:$IMAGE_TAG
echo $IMAGE_URI:$IMAGE_TAG

echo $KUBE_CONFIG_DATA | base64 -d
export KUBECONFIG=/kubeconfig
touch $KUBECONFIG
echo $KUBE_CONFIG_DATA | base64 -d > KUBECONFIG
cd $KUBE_APPLY_DIR
kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG
kubectl apply -k .
