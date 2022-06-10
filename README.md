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
```