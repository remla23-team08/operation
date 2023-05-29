# Operation

This repository contains the required Docker-Compose file & other [Kubernetes](https://kubernetes.io/) and [Helm](https://helm.sh/) configuration files to deploy the application.

## **Usage with Monitoring (Helm)**

To deploy the application in a Kubernetes environment using Helm, follow these steps:

1. Besides `kubectl` and `minikube`, make sure you have Helm installed. If not, follow the instructions [here](https://helm.sh/docs/intro/install/).
2. Make sure your minkube cluster is up and running before proceeding. If not, run the following command:
```bash
minikube start
```
3. Make sure you have the application's Helm chart repository added to your local Helm installation. If not, run the following command:
```bash
helm repo add remla23-team08 https://remla23-team08.github.io/operation
```

4. Ensure that all the repository dependencies are fulfilled and updated.
``` bash
helm repo update
```

5. Once the team's help repo was added, the application can be deployed. To do so, run the following command:
```bash
helm install application remla23-team08/application
```

If everything went well, you should see the following output:
```bash
NAME: application
LAST DEPLOYED: Mon May 29 00:19:36 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
```
> **NOTE**: 
> If you already have the kube-prometheus stack installed, go to `charts/application/values.yaml` and change `deploy-prom-stack` to false. This will skip the installation of the prometheus stack.
> 
> By default, the cluster is not exposed to the outside world (that also means you cannot access the dashboard from your host machine). To expose the cluster to the outside world using port-forwarding, open a new terminal and run the following command:
> ```bash
> kubectl port-forward svc/app-svc 8083:8083 & kubectl port-forward svc/model-service-svc 8080:8080 & kubectl port-forward svc/application-grafana 3000:80
> ```
> This will allow you to access the application at [http://localhost:8083](http://localhost:8083). The Grafana dashboard is accessible at [http://localhost:3000](http://localhost:3000)

6. To use the custom Grafana dashboard, open the `metrics-vis.json` inside charts/application/templates, and copy all its contents. Open the Grafana dashboard at [http://localhost:3000](http://localhost:3000) and login (username: admin, password: prom-operator). Then import the metrics-vis.json file found in ./charts/application/, and the custom dashboard will load. 

7. If you want to easily clean the cluster from all the resources created by the Helm chart, you can run the following command:
```bash
helm uninstall application
```

If everything went well, you should see the following output:
```bash
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

To deploy the application in a local Docker environment, follow these steps:

1. Clone the repository:
```bash
# When using SSH keys (recommended)
git clone git@github.com:remla23-team08/operation.git

# When using HTTPS
git clone https://github.com/remla23-team08/operation.git
```

2. Navigate to the `operation` directory:
```bash
cd operation
```

3. Login to GitHub Package Registry:
```bash
docker login ghcr.io
```

> **Note:** You will have to login with your GitHub username and have a personal access token with the `read:packages` scope.
> For more information on how to create a personal access token, see [this link](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token).

4. Once the login to GitHub Package Registry is successful, you can deploy the application by running the following command:
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
