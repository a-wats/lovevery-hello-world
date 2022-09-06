# Lovevery Hello World

## Requirements
* Docker
* minikube

## Build
0. Start minikube:
```
minikube start
```

1. Build the docker image:
```
docker build -t lovevery-hw:0.1.0 .
```

2. Import to minikube cluster:
```
minikube image load lovevery-hw:0.1.0
```


## Deploy
1. Run the helm chart:
```
helm package hw-chart
helm install hw-chart hw-chart-0.1.0.tgz
```

2. Port forward:
```
kubectl port-forward service/hw-chart 3000:3000
```

3. Load localhost:3000 in your browser

## Terraform
### Environments
How we manage terraform state is heavily dependent on other technical decisions like how the organization manages source code or the cloud provider being used. I'll make a few assumptions here:
 - We're operating in AWS.
 - The helm chart is deployed using terraform.
 - The terraform configuration for the runtime environment, such as the VPC, k8s cluster, and other common infrastructure, is defined in a separate repository.
 - We want fine grained control over deployments to each environment. For example, the whole development team wants to deploy to the demo environment but only the CD Pipeline should be able to deploy to production.

 For the core infrastructure, we'll use the S3 backend to store state in a Bucket with heavily restricted access. Infrastructure components are defined as modules that are imported by a separate root module for each environment.

The state for this application would be managed with the Kubernetes backend to leverage existing permissions defined in the cluster.

### Variables
Environment specific config should live within tfvars files when possible, with each root module having a separate terraform.tfvars. If common configuration is necessary, and it can't be pushed down into the component modules, then we can create a `common.tfvars` file that is stored in a place all the root modules can access it, and pass it in as a second var-file in the apply command.

### Secrets
We can store secrets right alongside the rest of our terraform configuration using SOPS. This gives us the security of PGP with most of the convenience of a normal tfvars file, only requiring an extra step to decrypt the file before running terraform.

## Testing
 - Add test cases to the Hello Controller test to validate it always returns "hello world"
 - Expand the connection test in the helm chart in a similar manner to cover different endpoints, verbs, and other inputs
 - Perf/scale & chaos testing, 3 ways:
   - Applying resource limits & spamming with API requests, to understand how well the application scales
   - Similar test to above, but also kill 1, then both of the pods to understand how it fails over & recovers
   - Finally, deploy a noisy neighbor to the same node the Hello World pod is running on to see how it handles starvation & rescheduling.
