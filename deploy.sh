#/bin/bash
export IMAGE_TAG=$(git log -1 --pretty=%H)
docker build . -t $IMAGE_URI:$IMAGE_TAG
aws ecr get-login --no-include-email | sh
docker push $IMAGE_URI:$IMAGE_TAG

export KUBECONFIG=/kubeconfig
touch KUBECONFIG
echo $KUBE_CONFIG_DATA | base64 -d > KUBECONFIG
curl -Lo kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v{$KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && chmod +x kustomize && mv kustomize /usr/local/bin
kustomize edit set image $IMAGE_URI=$IMAGE_URI:$IMAGE_TAG
kubectl apply -f $KUBE_APPLY_DIR
