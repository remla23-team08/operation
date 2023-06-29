# Operation

This repository contains the required Docker-Compose file & other [Kubernetes](https://kubernetes.io/) and [Helm](https://helm.sh/) configuration files to deploy the application.

## 📑 **Table of Contents**

- [Operation](#operation)
  - [📑 **Table of Contents**](#-table-of-contents)
  - [💻 **Code Overview**](#-code-overview)
  - [🐳 **Docker-Compose**](#-docker-compose)
  - [☸️ **Kubernetes Deployment with Istio (Manual)**](#️-kubernetes-deployment-with-istio-manual)
    - [1. Minikube and Istio Installation](#1-minikube-and-istio-installation)
    - [2. Monitoring](#2-monitoring)
    - [3. Application Deployment](#3-application-deployment)
  - [⚙️ **Kubernetes Deployment with Istio (Script)**](#️-kubernetes-deployment-with-istio-script)
  - [➕ **Additional Use Case**](#-additional-use-case)
  - [⚠️ **Alerts**](#️-alerts)
  - [🧪 **Continuous Experimentation**](#-continuous-experimentation)
  - [📚 **Versioning**](#-versioning)
  - [🌟 **Additional Resources**](#-additional-resources)

## 💻 **Code Overview**
Here is a brief overview of the project's codebase.
- `docker-compose.yml`: Contains the configuration for Docker-Compose.
- `charts/application`: Contains the Helm chart that serves as an alternative installation of the application.

## 🐳 **Docker-Compose**

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


3. The Docker-Compose file contains several parameters that can be customized:
- `ports`: Defines the ports inside the container that should be exposed and mapped to the corresponding ports on the host machine. For example, you can change the port mapping from 8083:8083 to another port if desired. Make sure other parameters such as `MODEL_SERVICE_URL` are consistent with the port changes.
- `environment`: Sets environment variables for the container. In the file, the environment variable `MODEL_SERVICE_URL` specifies the url the application should use to communicate with the model service.
- `volumes`: Specifies which directories or files on the host machine should be mounted as volumes inside the container. If you want to use custom models for serving the predictions, you can provide a `ml-model` directory to the container with the required files `c1_BoW_Sentiment_Model.pkl`, `c2_Classifier_Sentiment_Model`.

## ☸️ **Kubernetes Deployment with Istio (Manual)**
To deploy the application in a Kubernetes environment with Istio, follow these steps:
### 1. Minikube and Istio Installation
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/) and [minikube](https://minikube.sigs.k8s.io/docs/start/).
- Make sure your minikube cluster is up and running before proceeding. If not, run the following command:
```bash
minikube start --memory=16384 --cpus=4
```
- Enable the Ingress addon in your cluster.
```bash
minikube addons enable ingress
```

- Install Istio into the cluster. More detailed instructions can be found [here](https://istio.io/latest/docs/setup/install/istioctl/).
```bash
istioctl install
```

- Instruct Istio to automatically inject proxy containers to new pods in default namespace.
```bash
kubectl label ns default istio-injection=enabled
```

### 2. Monitoring
- To use monitoring tools such as Prometheus and Grafana, deploy the Istio addons.
```bash
kubectl apply -f addons
```

- Use the command below to access the monitoring dashboards, replacing `<addon-name>` with the desired addon. Possible addon names are: prometheus, grafana, kiali, jaeger.
```bash
istioctl dashboard <addon-name>
```

- The addon installation can be removed with:
```bash
kubectl delete -f addons
```

### 3. Application Deployment
- Make sure you have Helm installed. If not, follow the instructions [here](https://helm.sh/docs/intro/install/).

- Deploy the application with the command below.
```bash
helm install application charts/application
...
NAME: application
LAST DEPLOYED: Mon May 29 00:19:36 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

If istio injection is successful, app and model-service pods should have 2/2 containers running. It might take a while for them to start running so wait a bit and check their status.
```bash
kubectl get pods
...
app-deployment                    2/2     Running   0               1s
model-service-deployment-canary   2/2     Running   0               1s
model-service-deployment-stable   2/2     Running   0               1s

```

- Create a tunnel for the Istio Ingress Gateway:
```bash
minikube tunnel
```

- Access the app components at the following endpoints:
  - App frontend: [http://app.localhost](http://app.localhost)
  - Model-Service backend: [http://service.localhost](http://service.localhost)
  - API documentation: [http://service.localhost/apidocs](http://service.localhost/apidocs)

- If you want to easily clean the cluster from all the resources created by the Helm chart, you can run the following command:
```bash
helm uninstall application
...
release "application" uninstalled
```

## ⚙️ **Kubernetes Deployment with Istio (Script)**

To automatically deploy the application in a Kubernetes environment with Istio, follow the ensuing steps.
By doing this, you will effectively be running the same commands as in the previous section.

1. Make sure you have `kubectl` and `minikube` installed.
2. Run the following command while in the root directory of the repository:
```bash
./scripts/deploy_cluster.sh --memory=<specify-memory-here> --cpus=<specify-cpus-here>
```
> **Note**: You can omit specifying the `--memory` and `--cpu` parameters. The default values are `16384` MB and `4` CPUs respectively. However, it might be the case that your machine does not have enough resources to run the application with these default values. In that case, you can specify lower values for these parameters.

## 🧪 **Continuous Experimentation**
For a continuous experimentation, two versions of model-service are deployed. One acts as the `stable` release while the other as the `canary` that is being tested for an eventual full rollout.
The first time the user sends a request to model-service, the version that will serve the request is selected randomly.
Once this version has been selected, a cookie is set (`stable` or `canary`) to ensure the same version is used for future requests.
To send requests to the other version, the cookie should either be changed or cleared.
Customized requests can be sent using tools such as Postman or by executing curl commands as shown below.

For submitting a review:
```bash
curl -X POST "http://service.localhost/predict" -H "accept: application/json" -H "Content-Type: application/json" -H "Cookie: model-service-version=stable" -d "{ \"restaurantName\": \"Gourmet Haven\", \"review\": \"This excellent.\"}"
```

For submitting feedback on prediction accuracy:
```bash
curl -X POST "http://service.localhost/model-accuracy" -H "accept: application/json" -H "Content-Type: application/json" -H "Cookie: model-service-version=stable" -d "{ \"restaurantName\": \"Gourmet Haven\", \"accurate\": true, \"prediction\": 1}"
```

A word that can be tested between the models is "good". The stable release should return a negative sentiment prediction, while the canary a positive one.

The hypothesis is that this canary model should outperform the stable model in generating accurate predictions. If the hypothesis is correct, the canary model can be fully rolled out.
A custom Grafana dashboard is used to monitor and compare the relevant metrics for each deployed version.
Grafana can be accessed with the following command:
```bash
istioctl dashboard grafana
```
In the Grafana UI, the custom dashboard is automatically imported under `custom/Restaurant Metrics`.

These Prometheus metrics are used for the experiment:
- predictions_total
- neg_predictions_total
- pos_predictions_total
- true_neg_predictions_total
- true_pos_predictions_total
- false_pos_predictions_total
- false_neg_predictions_total
- model_accuracy

If model_accuracy is higher over an extended period of time, the hypothesis is accepted, otherwise rejected.


## ➕ **Additional Use Case**
As an additional use case, a rate limiter has been introduced that limits the request rate of the user.

The user can send a maximum of 20 requests per minute to the application's homepage ([http://app.localhost](http://app.localhost)). Once this limit is crossed, the user is blocked.

## ⚠️ **Alerts**
An alert will be fired if the user sends over 15 requests per minute for 2 minutes to the model-service backend. The alert can be viewed in Prometheus under the `Alerts` tab as `HighRequestRate`.

```bash
istioctl dashboard prometheus
```

## 📚 **Versioning**

Versioning of this repository is done automatically using GitHub Actions. The versioning is done using the standard Semantic Versioning (SemVer) format. Version bumps are done automatically when a PR is merged to the `main` branch. To achieve this, we are using the GitVersion tool. For more information on how to use GitVersion, see [this link](https://gitversion.net/docs/).

## 🌟 **Additional Resources**

* [Docker Compose Documentation](https://docs.docker.com/compose/)
* [GitHub Package Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry)
* [Semantic Versioning](https://semver.org/)
* [Release Engineerign TU Delft Course Website](https://se.ewi.tudelft.nl/remla/assignments/a1-images-and-releases/)
* [OpenLens Build Repo](https://github.com/MuhammedKalkan/OpenLens)
