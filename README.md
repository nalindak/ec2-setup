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