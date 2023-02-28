#!/bin/bash

#########################################################
#                                                       #
#   ./check_kube_pods.sh                                #
#                                                       #
#       Nagios check script for kubernetes cluster      #
#       pods health.  Uses kubectl or API to check      #
#       status for each pod                             #
#                                                       #
#                                                       #
#       Author:  Abdul Basith                           #
#                                                       #
#########################################################


export KUBECONFIG=/home/basith/.kube/config
node=$3
object=$4

ok=0
warning=1
critical=2
unknown=3

usage="./check_kube_pods.sh -n namespace node function"


# Check prereqs
kubectl_check=`which kubectl`
if [ -z "$kubectl_check" ]; then
  echo "kubectl not found. Cannot continue"
  exit $unknown
fi

# Get input parameters and validate
while getopts "n:" input; do
  case $input in
    n)
      namespace=$OPTARG
      ;;
    *)
      echo $usage
      exit $unknown
      ;;
  esac
done


# Usage check
if [ -z "$namespace" ]; then
  echo $usage
  exit $unknown
fi

# Pod health check 
check_pode_status () {
health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $3'} | uniq`
if [ "$health" == "Running" ]; then
        health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $1,$3'}`
        echo "$health"
        exit $ok
else
        health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $1,$3'}`
        echo "$health"
        exit $critical
fi
}


# Pod health ready check 
check_pode_ready () {
health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $2'} | uniq`
if [ "$health" == "1/1" ]; then
  health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $1,$2'}`
  echo "$health"
  exit $ok
else
  health=`kubectl get pods -n $namespace -o wide | grep "$node" | awk {'print $1,$2'}`
  echo "$health"
  exit $critical
fi
}

# Function call
$object
