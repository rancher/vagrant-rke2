mkdir -p /var/lib/rancher/rke2/server/manifests/

echo "apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-calico
  namespace: kube-system
spec:
  valuesContent: |-
    installation:
      calicoNetwork:
        nodeAddressAutodetectionV4:
          cidrs:
          - 192.168.121.0/24" >> /var/lib/rancher/rke2/server/manifests/e2e-calico.yaml

# Using eth1 as in https://github.com/rancher/rke2/blob/master/tests/e2e/scripts/ipv6.sh#L63-L64 is not a good idea because windows keeps picking the 192.168.121.0/24 interface and calico-windows is not controlled by this operator. The calico in windows is installed in a different way
