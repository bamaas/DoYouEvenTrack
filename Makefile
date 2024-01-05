.PHONY: $(MAKECMDGOALS)
.EXPORT_ALL_VARIABLES:

SHELL := /bin/bash

# Helm
CHART_NAME=doyoueventrack
CHART_PATH=${PWD}/chart/doyoueventrack
NAMESPACE?=dev
RELEASE_NAME=${CHART_NAME}
CHART_VERSION=$(shell cat ${CHART_PATH}/Chart.yaml | grep 'version:' | cut -d ":" -f 2 | cut -c 2- | head -n 1)

help:           										## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/:.*##/;/' | column -t -s';'

# Development
VENV_DIR?=.venv
RUN_IN_VENV=test -d ${VENV_DIR} || python3 -m venv ${VENV_DIR} && source ${VENV_DIR}/bin/activate

develop: venv install_deps githooks						## Setup Python virtualenv, install dev package in editable mode and setup Git hooks

githooks:												## Setup Git hooks with Python pre-commit package
	${RUN_IN_VENV}; \
	pre-commit install --hook-type pre-commit --hook-type commit-msg

install_deps:                                           ## Install dependencies required when developing on this project
	${RUN_IN_VENV}; \
    pip3 install -r requirements.txt;

venv:                                					## Create Python virtualenv
	test -d ${VENV_DIR} || python3 -m venv ${VENV_DIR}

# Helm
helm_release: helm_package helm_push_chart

helm_package: helm_dependency_update
	helm package ${CHART_PATH} -d ./dist;

helm_dependency_update:
	helm dependency update ${PWD}/chart/charts/database
	helm dependency update ${PWD}/chart/charts/backend
	helm dependency update ${PWD}/chart/charts/frontend
	helm dependency update ${PWD}/chart/charts/iam
	helm dependency update ${CHART_PATH}

helm_registry_login:
	@echo "${HELM_REGISTRY_PASSWORD}" | helm registry login registry-1.docker.io -u ${HELM_REGISTRY_USERNAME} --password-stdin

helm_push_chart: helm_registry_login
	helm push "./dist/${CHART_NAME}-${CHART_VERSION}.tgz" oci://registry-1.docker.io/bamaas

HELM_VALUES_FILE?=${PWD}/chart/dev.values.yaml
install: helm_dependency_update
	envsubst '$${NAMESPACE}' < ${HELM_VALUES_FILE} > /tmp/${NAMESPACE}-values.yaml
	helm -n ${NAMESPACE} upgrade ${RELEASE_NAME} ${CHART_PATH} --create-namespace --install \
	--set frontend.image.tag=${IMAGE_TAG} \
	--set backend.image.tag=${IMAGE_TAG} \
	--set iam.image.tag=${IMAGE_TAG} \
	--set landing.image.tag=${IMAGE_TAG} \
	--set database.liquibase.image.tag=${IMAGE_TAG} \
	--wait --timeout=15m -f /tmp/${NAMESPACE}-values.yaml

install_prev:
	$(eval PREV_VERSION=$(shell git tag | sort -V | tail -n 1))
	helm repo add chartmuseum https://chartmuseum.kubernetes.lan.basmaas.nl
	helm repo update chartmuseum
	envsubst '$${NAMESPACE}' < ${HELM_VALUES_FILE} > /tmp/${NAMESPACE}-values.yaml
	helm upgrade doyoueventrack chartmuseum/doyoueventrack \
	-n ${NAMESPACE} \
	--version ${PREV_VERSION} \
	--create-namespace \
	--install \
	--wait \
	-f /tmp/${NAMESPACE}-values.yaml

uninstall: clean-test-resources
	helm -n ${NAMESPACE} uninstall ${RELEASE_NAME}
	kubectl delete ns ${NAMESPACE}

helm_template: helm_dependency_update
	helm template ${CHART_PATH}

# Testing
test:
	cd test && ./run-test-suite ${CYPRESS_DASHBOARD_KEY} ${TEST_ENV} ${TEST_SUITE} ${TEST_VIEWPORT}

helm_test: install
	helm -n ${NAMESPACE} test ${RELEASE_NAME} || \
	{ kubectl -n ${NAMESPACE} logs -l release=${RELEASE_NAME},test=true,chart=${CHART_NAME}-${CHART_VERSION}; exit 1; }

dyet-test:
	drone build create Bas/dyet-test --branch master --param ENV=dev
	sleep 10
	kubectl -n drone logs -l io.drone.repo.name=dyet-test,io.drone.build.event=custom --ignore-errors --all-containers --follow --max-log-requests=20

trigger-deployment-acc:
	drone build create Bas/dyet-env --branch acc --param APP=doyoueventrack --param VERSION=${HELMVERSION}

# Linting
lint: helm_lint drone_lint

drone_lint:
	drone lint

helm_lint: helm_dependency_update
	helm lint ${CHART_PATH}

# Cleaning
clean: clean_helm clean_venv

clean_helm:
	rm -rf ./dist/*;

clean_venv:                                             ## Remove Python virtualenv
	rm -rf ${VENV_DIR}

clean-test-resources:
	kubectl -n ${NAMESPACE} delete po -l app.kubernetes.io/instance=${RELEASE_NAME},app.kubernetes.io/version=${CHART_VERSION},app.kubernetes.io/managed-by=Helm

# Releasing
bump:
	cz -nr 21 bump --changelog

commit-msg-check:                                       ## Validate that the commit message is according to the expected format
	@echo "Checking if commit message is according to expected format"
	@echo "-------"
	@echo "fix: A bug fix. Correlates with PATCH in SemVer"
	@echo "feat: A new feature. Correlates with MINOR in SemVer"
	@echo "docs: Documentation only changes"
	@echo "style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)"
	@echo "refactor: A code change that neither fixes a bug nor adds a feature"
	@echo "perf: A code change that improves performance"
	@echo "test: Adding missing or correcting existing tests"
	@echo "build: Changes that affect the build system or external dependencies (example scopes: pip, docker, npm)"
	@echo "ci: Changes to our CI configuration files and scripts (example scopes: Azure Pipelines)"
	@echo "-------"
	@cz check --commit-msg-file .git/COMMIT_EDITMSG