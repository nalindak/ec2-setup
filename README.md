## Setup `ec2` Instance

```
curl -s 'https://raw.githubusercontent.com/nalindak/ec2-setup/main/install.sh' | sh
```

### Install eks cluster

- Setup instance IAM role with following policies - https://eksctl.io/usage/minimum-iam-policies/
- Install eksctl tool,

```
curl --silent --location https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin
```

- Install new eks cluster

```
./eks-cluster-create.sh
```

### Kube Commands

```
k run nginx --image=nginx --restart=Never --dry-run=client -o yaml > pod.yml
k create -f pod.yml
k create deploy webapp --image=nginx:1.16-alpine-perl --dry-run=client -o yaml > webapp1.yml
k create -f webapp1.yml
k apply -f webapp2.yml
k get deployment
k get deployment -o wide
k get pod
k port-forward [pod-id] [local-port]:[remote-port]
k config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'
k config current-context
k config use-context [cluster-context]
k get endpoints metric-server -n kube-system
k describe deployment metrics-server -n kube-system
k describe deploy metrics-server -n kube-system
k logs -n <namespace> -l app=metrics-server
k get service -o wide
k exec --tty --stdin [pod-id] -- sh
k explain replicaset
k scale rs [replica-set-name] --replicas=5
k edit rs [replica-set-name]
k get all
k create namespace [dev]

k set image deployment/my-app nginx=nginx:1.9.1

k config get-clusters
k config get-contexts
k config view
k config current-context
k create namespace dev
k get namespace
k config set-context $(k config current-context) --namespace=dev

k expose pod redis --name=redis-service --port=6379 --dry-run=client -o yaml
k expose pod nginx --name=nginx-service --type=NodePort --port=80 --dry-run=client -o yaml

k create service clusterip [name] --clusterip="None"

k get pods --watch
k get pods --selector run=nginx
k get pods --selector env=dev --no-headers | wc -l
k get all --selector env=dev --no-headers | wc -l
```

### To make creation of kube yaml files

```
k run nginx --image=nginx --dry-run=client -o yaml > nginx-pod.yaml
k run busybox --image=busybox --dry-run=client -o yaml --command ---- sleep 1000 > busybox.yaml
k create deployment --image=nginx nginx --relicas=3 --dry-run=client -o yaml > nginx-deployment.yaml
k create -f nginx-deployment.yaml
```

### Create a pod and a service

```
k run [pod-name] --image=[image] --port=[port-ip] --expose=true
```

### Delete existing pod and recreating it

```
k replace --force -f nginx.yaml
```

## Node taints and Pod tolerations

```
k taint node node-name key=value:taint-effect
k taint node node1 app=blue:NoSchedule
k taint node node1 app=blue:NoSchedule- [ending with - makes it to remove the taint]
```

## Label Nodes

```
k label nodes node-1 size=Large
k get nodes --show-labels
```

## Static path to kubelet configs

```
cat /var/lib/kubelet/config.yaml
```

### Container logs

```
k logs webapp-2 --all-containers=true
```

### Rollout

```
k rollout status deployment/webapp
k rollout history deployment/nginx
k rollout undo deployment/my-app
```

### Deployment Strategy

- Default Deployment Strtegy `Rolling Update`

```

```

### Testing the application

```
for i in {1..35}; do
   kubectl exec --namespace=kube-public curl -- sh -c 'test=`wget -qO- -T 2  http://webapp-service.default.svc.cluster.local:8080/info 2>&1` && echo "$test OK" || echo "Failed"';
   echo ""
done
```