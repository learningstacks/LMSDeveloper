# Docker Containers

This project is designed to be used with Docker containers. Developing with containers provides a number of advantages:

- Testing with a different PHP version is as simple as changing an environment variable and restarting the containers

- You do not need to install a Web Server, Database server or PHP on your PC.

## File: Docker-Compose.yml

The Docker-Compose.yml file defines the containers to be run when launching containers for development.

## Directory: .containers

This directory defines the webserver container. All other containers are referenced unchanged from Docker Hub.

## File: .devcontainer/devcontainer.json

This file defines the container configuration used by VSCode when opening the project in the container. It also defines the VSCode extensions to be installed by default in the container.
