# AHS Tutorial

This repository holds the code of frameworks involved in the tutorial ["AHS: An EDA toolbox for Agile Chip Front-end Design"](https://ericlyun.me/tutorial-aspdac2025/en/master/#ahs-an-eda-toolbox-for-agile-chip-front-end-design).

## Installation

### Docker

We recommend using Docker to try out the frameworks.

#### Using Built Docker Image

We provide a built Docker image for the tutorial. You can pull it from Docker Hub:

```bash
docker pull uvxiao/ahs-tutorial:aspdac2025
```

#### Building Docker Image from Source

You can refer to [ahs-docker](https://github.com/pku-liang/ahs-docker) for instructions.

### Local Installation

We also provide a local installation script for the tutorial. Some prerequisites are required, please refer to [Dockerfile](https://github.com/pku-liang/ahs-docker/blob/main/Dockerfile) as a reference.

Then, you can run the following commands to install the frameworks:

```bash
git clone git@github.com:arch-of-shadow/ahs-tutorial.git
cd ahs-tutorial
git submodule update --init
bash install.sh
```

## First Taste

After installation, you can run the following commands to have the first taste of the frameworks (also validate the installation):

> [!NOTE]
> Fill this section.
