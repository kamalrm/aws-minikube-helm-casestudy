#!/bin/bash

#
#
# Configuration
#
dockerUsername=kamalakannanrm
dockerPassword=kamalakannanrm@1308

#
#
# Install Java 8
#
sudo apt-get update -y && sudo apt-get install build-essential -y
sudo apt install openjdk-8-jdk -y

#
#
# Install SOCAT
#
sudo apt install socat -y

#
#
# Install kubectl
#
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo cp ./kubectl /usr/local/bin/kubectl

#
#
# Install Docker
#
sudo apt-get update -y && sudo apt-get install docker.io -y
sudo docker login --username=$dockerUsername --password=$dockerPassword

#
#
# Install minikube
#
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo chmod +x minikube && sudo cp minikube /usr/local/bin/

#
#
# Run minikube
#
# Note:
# 	Official docs says that you need to enable virtualization by accessing the computer’s BIOS. 
#	For EC2 Instances we do not have access to the BIOS since AWS EC2 instance is a Virtual Machine. 
#	Thus we are using the --vm-driver=none tag.
#
sudo minikube start --vm-driver=none --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf

#
#
# Create admin users and roles for the cluster
#
sudo kubectl apply -f dashboard-adminuser.yaml
sudo kubectl apply -f clusterrolebinding-adminuser.yaml

#
#
# Install and initialize Helm
#
curl -LO https://git.io/get_helm.sh
sudo chmod +x get_helm.sh
sudo ./get_helm.sh
sudo helm init

#
#
# Build the application using Gradle
#
sudo chmod +x ./gradlew
./gradlew build docker
sudo docker push kamalakannanrm/demo-app

#
#
# Helm install application and get its IP/Port details
#
sudo helm install --name demo-app ./demo-app/
demoAppIP=$(kubectl get services --all-namespaces | grep demo-app | sed 's/|/ /' | awk '{print $4}')
demoAppPort=$(kubectl get services --all-namespaces | grep demo-app | sed 's/|/ /' | awk '{print $6}')
demoAppPort=${demoAppPort%"/TCP"}

#
#
# Install Kubernetes dashboard and get its IP/port details
#
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
#sudo minikube dashboard > minikube-dashboard.log 2>&1 < /dev/null & 
dashboardIP=$(kubectl get services --all-namespaces | grep kubernetes-dashboard | sed 's/|/ /' | awk '{print $4}')
dashboardPort=$(kubectl get services --all-namespaces | grep kubernetes-dashboard | sed 's/|/ /' | awk '{print $6}')
dashboardPort=${dashboardPort%"/TCP"}

#
#
# Install nginx (to reverse proxy Kubernetes dashboard and Demo App)
#
sudo apt-get install nginx -y
sudo rm -f /etc/nginx/sites-available/default
sudo cp nginx-config.template /etc/nginx/sites-available/default

#
#
# Update nginx default config and reload nginx
#
if [ $dashboardPort -eq 80 ]
then
    sed -i "s/protocol/http/g" /etc/nginx/sites-available/default
else
	if [ $dashboardPort -eq 443 ]
	then
		sed -i "s/protocol/https/g" /etc/nginx/sites-available/default
	fi
fi
sed -i "s/dashboardIP/${dashboardIP}/g" /etc/nginx/sites-available/default
sed -i "s/dashboardPort/${dashboardPort}/g" /etc/nginx/sites-available/default
sed -i "s/demoAppIP/${demoAppIP}/g" /etc/nginx/sites-available/default
sed -i "s/demoAppPort/${demoAppPort}/g" /etc/nginx/sites-available/default
sudo systemctl reload nginx
sudo systemctl restart nginx
