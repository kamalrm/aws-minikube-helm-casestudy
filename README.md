# Case study with AWS, Minikube and Helm

### What it contains?
- A spring boot application which returns data from properties configured in Configmap and Secrets of Kubernetes (which is configurable through 'values.yaml' file) as a Map.
- The above application is built and dockerized using Gradle.
- Once built, the docker image is published to my Docker hub account.
- Using Helm, I'm deploying the application with 3 replicas (which is configurable through 'values.yaml' file) into the kubernetes cluster (from Minikube).
- A shell script which will install (all requires software from JDK to minikube,..), configure, build, publish, deploy and configures reverse-proxy for the application is also available (trimble-case-study-setup.sh)
- The script will also install the dashboard, but it gives Unauthorized error for all logins. Working on it!

### Where to run?
- The script is for Ubuntu 18.04 x64.
- AWS instance (t2.medium - as 2 vCPUs is the minimum requirement).
- Please open port 22/TCP and 80/TCP for the applications to work.

### How to run?
Please execute the below commands for installation to begin:
```sh
chmod +x trimble-case-study-setup.sh
touch setup.log
nohup ./trimble-case-study-setup.sh > setup.log 2>&1 < /dev/null &
```

### What to expect?
- Kubernetes dashboard should be accessible through http://PUBLIC_DNS
- Demo application should be accessible through http://PUBLIC_DNS/demo-app/

## Developer
- [Kamalakannan R M](mailto:InboxKamalakannan@outlook.com)
