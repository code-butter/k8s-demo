#!/usr/bin/env bash

set -euo pipefail

minikube start
minikube tunnel # required for external services to function