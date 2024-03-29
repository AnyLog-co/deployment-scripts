#!/bin/bash
cat <<EOF | kubectl apply -f -
apiVersion: security.kubearmor.com/v1
kind: KubeArmorPolicy
metadata:
  name: audit-apt-nginx-access3
spec:
  selector:
    matchLabels:
      app: nginx3
  process:
    matchPaths:
    - path: /usr/bin/apt
    - path: /usr/bin/apt-get
  message: Alert! Use of apt/apt-get detected!
  action:
    Audit
EOF
