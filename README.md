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

### Testing the application

```
for i in {1..35}; do
   kubectl exec --namespace=kube-public curl -- sh -c 'test=`wget -qO- -T 2  http://webapp-service.default.svc.cluster.local:8080/info 2>&1` && echo "$test OK" || echo "Failed"';
   echo ""
done
```

### Configmap

```
k create configmap [config-map-name] --from-literal=key1=config1
k create secret generic <secret-name> --from-literal=key=value
```

```
echo -n 'secret_value' | base64
echo 'encoded' | base64 --decode
```

### OS Upgrades

```
k drain node01 --ignore-daemonsets
k uncordon node01
k cordon node01
```

### Kubeadm Commands

```
kubeadm upgrade plan
apt-get upgrade -y kubeadm=1.12.0-00
kubeadm upgrade apply v1.12.0
apt-get upgrade -y kubelet=1.12.0-00
kubeadm upgrade node config --kubelet-version v1.12.0
systemctl restart kubelet
```

```
[master node]
apt update
apt install kubeadm=1.20.0-00
kubeadm upgrade apply v1.20.0
apt install kubelet=1.20.0-00
systemctl restart kubelet
kubelet --version

[node]
k cordon node01 - In master node
apt update
apt install kubeadm=1.20.0-00
kubeadm upgrade node
apt install kubelet=1.20.0-00
k uncordon node01 - In master node
```

### Backup and restorations

```
k get all -A -o yaml > all-deploy-service.yaml
ETCDCTL_API=3 etcdctl snapshot save snapshot.db
service kube-apiserver stop
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir /var/lib/etcd-from-backup
service kube-apiserver start
```

### Manage/create user certificates and approve

```
k get csr
k describe csr csr-78hrx
cat akshay.csr | base64 -w 0
k create -f akshay.yaml 
k certificate approve akshay

k config view
k config --kubeconfig=/root/my-kube-config use-context research
k config --kubeconfig=/root/my-kube-config current-context

k auth can-i list pods -n default --as dev-user

k get clusterroles
k get clusterrolebindings
k get serviceaccounts
```

### PV and PVS

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  persistentVolumeReclaimPolicy: Retain
  capacity:
    storage: 100Mi
  hostPath:
    path: /pv/log
  accessModes:
    - ReadWriteMany
```

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-log-1
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 50Mi
  volumeMode: Filesystem
  volumeName: pv-log
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Mi
  phase: Bound
```

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
allowVolumeExpansion: true
mountOptions:
  - debug
volumeBindingMode: Immediate
```

### Networking in Kube

```
ip a | grep -B3 -A3 10.0.202.10
arp node01
ip link
ip route
route
cat /etc/resolve.conf
cat /etc/hosts
cat /etc/nsswitch.conf
cat /etc/network/interfaces
netstat -natulp (t - tcp, u - udp)
nestat -anp | grep etcd (number of connection to each socket)
netstat -anp | grep etcd | grep 2379 | wc -l
```

```
ip link add v-net-0 type bridge
ip link set dev v-net-0 up
ip addr add 192.168.15.5/24 dev v-net-0
ip link add veth-red type veth peer name veth-red-br
ip link set veth-red netns red
ip -n red addr add 192.168.15.1 dev veth-red
ip -n red link set veth-red up
ip link set veth-red-br master v-net-0
ip netns exec blue ip route add 192.168.1.0/24 via 192.168.15.5
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE
ip route add 10.244.2.3 via 192.168.1.12
```

```
# Create veth pair
ip link add ....

# Attach veth pair
ip link set ...
ip link set ...

# Assign IP Address
ip -n <namespace> addr add ...
ip -n <namespace> route add ...

# Bring Up Interface
ip -n <namespace> link set ...
```

```
ipcalc -b 10.16.60.6/24

Address:   10.16.60.6           
Netmask:   255.255.255.0 = 24   
Wildcard:  0.0.0.255            
=>
Network:   10.16.60.0/24        
HostMin:   10.16.60.1           
HostMax:   10.16.60.254         
Broadcast: 10.16.60.255         
Hosts/Net: 254                   Class A, Private Internet
```

```
    - -c
    - while true; do echo -e "HTTP/1.1 200 OK\n\n This is the PayRoll server!" | nc
      -l -p 80 -q 1; done
    command:
    - /bin/sh
    image: nicolaka/netshoot
```


### Performance and CPU and Mem

```
lscpu
lsmem
lsns
```

  Warning  FailedCreatePodSandBox  3m13s                kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = [failed to set up sandbox container "d97f34d4506919cf0a5a5632935436133d493244e64d19e24d37e2e8311a33ae" network for pod "app": networkPlugin cni failed to set up pod "app_default" network: unable to allocate IP address: Post "http://127.0.0.1:6784/ip/d97f34d4506919cf0a5a5632935436133d493244e64d19e24d37e2e8311a33ae": dial tcp 127.0.0.1:6784: connect: connection refused, failed to clean up sandbox container "d97f34d4506919cf0a5a5632935436133d493244e64d19e24d37e2e8311a33ae" network for pod "app": networkPlugin cni failed to teardown pod "app_default" network: Delete "http://127.0.0.1:6784/ip/d97f34d4506919cf0a5a5632935436133d493244e64d19e24d37e2e8311a33ae": dial tcp 127.0.0.1:6784: connect: connection refused]
  Normal   SandboxChanged          2s (x16 over 3m13s)  kubelet            Pod sandbox changed, it will be killed and re-created.


    Warning  FailedCreatePodSandBox  51s                  kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "8b6df3450d693e7fe339114119574b46cbd34ebf9d4e29dcfdb59a68341c735a" network for pod "apt-loyalty-pulse-us-prod-web-7d47c679b6-4fwpb": networkPlugin cni failed to set up pod "apt-loyalty-pulse-us-prod-web-7d47c679b6-4fwpb_consumer" network: unable to create endpoint: Cilium API client timeout exceeded


    By default, the range of IP addresses and the subnet used by weave-net is 10.32.0.0/12 and it's overlapping with the host system IP addresses.
To know the host system IP address by running ip a command :-

root@controlplane:~# ip a | grep eth0
12396: eth0@if12397: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
    inet 10.40.56.3/24 brd 10.40.56.255 scope global eth0
If we deploy a weave manifest file directly without changing the default IP addresses it will overlap with the host system IP addresses and as a result, it's weave pods will go into an Error or CrashLoopBackOff state.

root@controlplane:~# kubectl get po -n kube-system | grep weave
weave-net-6mckb                        1/2     CrashLoopBackOff   6          6m46s
If we will go more deeper and inspect the logs then we can clearly see the issue :-

root@controlplane:~# kubectl logs -n kube-system weave-net-6mckb -c weave
Network 10.32.0.0/12 overlaps with existing route 10.40.56.0/24 on host
So we need to change the default IP address by adding &env.IPALLOC_RANGE=10.50.0.0/16 option at the end of the manifest file. It should be look like as follows :-

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.50.0.0/16"
then run the kubectl get pods -n kube-system to see the status of weave-net pods.
Note :- 10.40.56.3 IP address is used here as an example. It may be different in your assigned lab.

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.50.0.0/16"
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  labels:
    name: webapp
spec:
  selector:
    matchLabels:
      name: webapp
  template:
    metadata:
      labels:
        name: webapp
    spec:
      containers:
      - name: simple-webapp-mysql
        image: mmumshad/simple-webapp-mysql
        ports:
        - containerPort: 8080
        env:
          - name: DB_Host
            value: mysql
          - name: DB_User
            value: root
          - name: DB_Password
            value: paswrd

---
kind: Service
apiVersion: v1
metadata:
  name: webapp-service
spec:
  selector:
    name: webapp
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
```

### Ingress

```
k create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"
```

```
kubectl expose -n ingress-space deployment ingress-controller --type=NodePort --port=80 --name=ingress --dry-run=client -o yaml > ingress.yaml
k describe role ingress -n ingress-space
```

### Installation of K8s

- master and worker nodes
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
```

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00
sudo apt-mark hold kubelet kubeadm kubectl
```

- master node

```
ETH0_IP=$(ip addr|grep eth0|grep inet|awk '{print $2}'| cut -d '/' -f1)
kubeadm init --apiserver-cert-extra-sans=controlplane --apiserver-advertise-address $ETH0_IP --pod-network-cidr=10.244.0.0/16
```

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm token create --print-join-command
```


- worker nodes

```
kubeadm join 10.31.95.3:6443 --token xxxxxxxxxxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxx
```

- master node - install CNI

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
