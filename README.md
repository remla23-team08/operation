# Operation

This repository contains the required Docker-Compose file & other Kubernetes configuration files to deploy the application.

## **Docker-Compose**

The `docker-compose.yml` file contains the required configuration to deploy the application in a local Docker environment. The file contains the following services:
* `app`: The frontend application itself that sends requests to the backend.
* `model-service`: The embedded ML model in a Flask webservice

## **Usage**

To deploy the application in a local Docker environment, follow these steps:

1. Clone the repository:
```bash
# When using SSH keys (recommended)
git clone git@github.com:remla23-team14/operation.git

# When using HTTPS
git clone https://github.com/remla23-team14/operation.git
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

> **Note:** If you want to run the application in the background, you can use the `-d` flag: ```docker compose up -d```
> This will allow you to continue using the same terminal window without having to start a new process.

## **Versioning**

Versioning of this repository is done automatically using GitHub Actions. The versioning is done using the standard Semantic Versioning (SemVer) format. Version bumps are done automatically when a PR is merged to the `main` branch. To achieve this, we are using the GitVersion tool. For more information on how to use GitVersion, see [this link](https://gitversion.net/docs/).

## **Additional Resources**

* [Docker Compose Documentation](https://docs.docker.com/compose/)
* [GitHub Package Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry)
* [Semantic Versioning](https://semver.org/)
* [Release Engineerign TU Delft Course Website](https://se.ewi.tudelft.nl/remla/assignments/a1-images-and-releases/)
  