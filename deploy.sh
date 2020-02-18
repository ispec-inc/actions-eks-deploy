#/bin/bash -l
export IMAGE_URI=$1
if [ -n "$2" ]; then
export IMAGE_TAG=$2
else
export IMAGE_TAG=$(git log -1 --pretty=%H)
fi
export KUBE_CONFIG_DATA=$3
export KUBE_APPLY_DIR=$4
export AWS_ACCESS_KEY_ID=$5
export AWS_SECRET_ACCESS_KEY=$6
export AWS_DEFAULT_REGION=$7

if [ -n "$8" ]; then
export BUILD_ARGS="--build-arg $8"
fi

docker build . -t $IMAGE_URI:$IMAGE_TAG $BUILD_ARGS
aws ecr get-login --no-include-email | sh
docker push $IMAGE_URI:$IMAGE_TAG

export KUBECONFIG=/kubeconfig
touch $KUBECONFIG
echo $KUBE_CONFIG_DATA | base64 -d > $KUBECONFIG
cd $KUBE_APPLY_DIR
kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG
kubectl apply -k .
