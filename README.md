# Operation

This repository contains the required Docker-Compose file & other [Kubernetes](https://kubernetes.io/) and [Helm](https://helm.sh/) configuration files to deploy the application.

## **Kubernetes Deployment with Istio**
To deploy the application in a Kubernetes environment with Istio, follow these steps:
### 1. Minikube Installation and Start-up
- Install `kubectl` and `minikube`, if not already done.
- Make sure your minikube cluster is up and running before proceeding. If not, run the following command:
```bash
minikube start --memory=16384 --cpus=4
```
- Enable the Ingress addon in your cluster, if not already done.
```bash
minikube addons enable ingress
```

### 2. Prometheus Installation
- Make sure you have Helm installed. If not, follow the instructions [here](https://helm.sh/docs/intro/install/).
- Add the prometheus Helm chart repository to your local Helm installation:
```bash
helm repo add prom-repo https://prometheus-community.github.io/helm-charts
```

- Ensure that all the repository dependencies are fulfilled and updated.
``` bash
helm repo update
```

- Once the helm repo has been added, prometheus can be deployed:
```bash
helm install prometheus prom-repo/kube-prometheus-stack
```

### 3. Istio Installation
- Install Istio into the cluster. More detailed instructions can be found [here](https://istio.io/latest/docs/setup/install/istioctl/)
```bash
istioctl install
```
- Instruct Istio to automatically inject proxy containers to new pods in default namespace.
```bash
kubectl label ns default istio-injection=enabled
```

### 3. Application Deployment

- Deploy the application with the command below. If istio injection is successful, app and model-service pods should have 2/2 containers running:
```bash
helm install application ./charts/application
...
NAME: application
LAST DEPLOYED: Mon May 29 00:19:36 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

- Create a tunnel for the Istio Ingress Gateway:
```bash
minikube tunnel
```

- Access features at the following endpoints:
    - App: [http://app.localhost](http://app.localhost)
    - Model-Service: [http://service.localhost](http://service.localhost)
    - Prometheus: [http://prometheus.localhost](http://prometheus.localhost)
    - Grafana: [http://grafana.localhost](http://grafana.localhost) (username: admin, password: prom-operator). The custom dashboard is automatically imported under Restaurant Metrics.

- If you want to easily clean the cluster from all the resources created by the Helm chart, you can run the following command:
```bash
helm uninstall application
...
release "application" uninstalled
```

## **Versioning**

Versioning of this repository is done automatically using GitHub Actions. The versioning is done using the standard Semantic Versioning (SemVer) format. Version bumps are done automatically when a PR is merged to the `main` branch. To achieve this, we are using the GitVersion tool. For more information on how to use GitVersion, see [this link](https://gitversion.net/docs/).

## **Additional Resources**

* [Docker Compose Documentation](https://docs.docker.com/compose/)
* [GitHub Package Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry)
* [Semantic Versioning](https://semver.org/)
* [Release Engineerign TU Delft Course Website](https://se.ewi.tudelft.nl/remla/assignments/a1-images-and-releases/)
* [OpenLens Build Repo](https://github.com/MuhammedKalkan/OpenLens)

# Alternative Installation Methods
## **Docker-Compose**

The `docker-compose.yml` file contains the required configuration to deploy the application in a local Docker environment. The file contains the following services:
* `app`: The frontend application itself that sends requests to the backend.
* `model-service`: The embedded ML model in a Flask webservice

To deploy the application in a local Docker environment, follow these steps while in the root directory of the repository:

1. Login to GitHub Package Registry:
```bash
docker login ghcr.io
```

> **Note:** You will have to login with your GitHub username and have a personal access token with the `read:packages` scope.
> For more information on how to create a personal access token, see [this link](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token).

2. Once the login to GitHub Package Registry is successful, you can deploy the application by running the following command:
```bash
docker compose up
```

The aforementioned command will pull the required images from GitHub Package Registry and start the application. The first time you run this command, it will take a while to download the images. You should be able to see the containers starting up in the terminal. To check the status of the containers, you can run the following command:
```bash
docker ps
```

and ideally see the following output:
```bash
CONTAINER ID   IMAGE                                       COMMAND                   CREATED          STATUS          PORTS                                      NAMES
c0b6b0b0b0b0   ghcr.io/remla23-team08/app:latest           "docker-entrypoint.sh"    1 minute ago     Up 1 minute     0.0.0.0:8083->8083/tcp, :::8083->8083/tcp  operation-app-1
b0b0b0b0b0b0   ghcr.io/remla23-team08/mode-service:latest  "python app.py"           1 minute ago     Up 1 minute     0.0.0.0:8080->8080/tcp, :::8080->8080/tcp  operation-model-service-1
```

Assuming everything went well, you should be able to access the application at [http://localhost:8083](http://localhost:8083). 

> **Note:** If you want to run the application in the background, you can use the `-d` flag: ```docker compose up -d```
> This will allow you to continue using the same terminal window without having to start a new process.

1. If you want to use a custom model for the `model-service` Docker image, there is the option to uncomment the `volumes` part from within the `docker-compose.yml` file. This will mount the `ml-model` directory to the container and allow you to use a custom model, provided this folder exists and contains the required files:

```yml
...
services:
  model-service:
    ...
    # volumes:
    #   - ./ml-model/c1_BoW_Sentiment_Model.pkl:/root/ml-model/c1_BoW_Sentiment_Model.pkl
    #   - ./ml-model/c2_Classifier_Sentiment_Model:/root/ml-model/c2_Classifier_Sentiment_Model
    ...
...
```

## **Kubernetes**

To deploy the application in a Kubernetes environment, follow these steps:

1. Make sure you have kubectl installed. If not, follow the instructions [here](https://kubernetes.io/docs/tasks/tools/).
2. Make sure you have minikube installed. If not, follow the instructions [here](https://minikube.sigs.k8s.io/docs/start/).
3. Start minikube by running the following command:
```bash
minikube start
```
4. Once minikube is started, you can deploy the application by running the following command:
```bash
kubectl apply -f k8s/app/ && kubectl apply -f k8s/model-service/
```
5. Besides the plethora of different `kubectl` commands that you can use from the official docs to view different parts of the system (i.e. pods, services, deployments, etc.), you can also use the Kubernetes dashboard to view the status of the system. To access the dashboard, run the following command:
```bash
minikube dashboard
```
> **NOTE**: By default, the cluster is not exposed to the outside world (that also means you cannot access the dashboard from your host machine). To expose the cluster to the outside world using port-forwarding, you can run the following command:
> ```bash
> kubectl port-forward svc/app-svc 8083:8083 & kubectl port-forward svc/model-service-svc 8080:8080
> ```
> This will allow you to access the application at [http://localhost:8083](http://localhost:8083).
