#!/bin/bash

#########################################################
#                                                       #
#   ./check_kube_cert_expiry.sh                         #
#                                                       #
#       Nagios check script for kubernetes cluster      #
#       kubeadm expiry.                                 #
#                                                       #
#       Author:  Abdul Basith                           #
#                                                       #
#########################################################

export KUBECONFIG=/home/basith/.kube/config

ok=0
warning=1
critical=2
unknown=3

# Check prereqs
kubectl_check=`which kubectl`
if [ -z "$kubectl_check" ]; then
  echo "kubectl not found. Cannot continue"
  exit $unknown
fi

check_kubeadm() {
    expiry_check=`kubeadm certs check-expiration | grep -w 'apiserver ' | awk {'print $7'} | sed 's/d//'`
    if [ "$expiry_check" -lt "20" ] && [ "$expiry_check" -gt "11" ]; then
        echo "WARNING! The Kubeadm Certificate expiring within ${expiry_check} days"
        exit $warning
    elif [ "$expiry_check" -lt "10" ]; then
        echo "CRITICAL! The Kubeadm Certificate expiring within ${expiry_check} days"
        exit $critical
    else
        echo "Kubeadm Certificate expiring within $expiry_check days"
        exit $ok
    fi
}

check_kubeadm
