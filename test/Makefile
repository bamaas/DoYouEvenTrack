ENV=prod
VIEWPORT=desktop
BROWSER=chrome
VERSION=0.0.14
IMAGE=bamaas/dyet-test:${VERSION}
CONFIG_FILE:=./cypress/env/cypress.${ENV}.dec.json
DISPLAY=:90
# KUBECONFIG=${HOME}/.kube/config

image:
	docker build -t ${IMAGE} .

push:
	docker push ${IMAGE}

NAMESPACE=default
POD_NAME=cypress
run-pod:
	kubectl -n ${NAMESPACE} get po ${POD_NAME} || \
	kubectl -n ${NAMESPACE} run ${POD_NAME} --image=${IMAGE} --command -- /bin/sleep 99999

exec-pod: run-pod
	kubectl -n ${NAMESPACE} wait --for=condition=Ready pod/${POD_NAME}
	kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -- /bin/sh

delete-pod:
	kubectl -n ${NAMESPACE} delete po ${POD_NAME}

TEST_RUN_CMD=DISPLAY=${DISPLAY} VIEWPORT=${VIEWPORT} cypress run --config-file ${CONFIG_FILE} --spec 'cypress/integration/${SUITE}/**' --browser ${BROWSER} --headless
TEST_RUN_RECORD_OPTS=--record --key ${CYPRESS_DASHBOARD_KEY} --group '${SUITE} | ${VIEWPORT}' --tag '${VIEWPORT}, ${SUITE}'
test:
	${TEST_RUN_CMD} ${TEST_RUN_RECORD_OPTS}

test-in-docker:
	docker run --rm --user root --name cypress -v ${KUBECONFIG}:/e2e/kubeconfig -v ${PWD}:/drone/src --entrypoint=/bin/sh ${IMAGE} /drone/src/pipeline/run-test-suite ${ENV} ${SUITE} ${VIEWPORT}

trigger-pipeline:
	drone build create Bas/dyet-test --branch master --param ENV=${ENV}
	sleep 10
	kubectl -n drone logs -l io.drone.repo.name=dyet-test,io.drone.build.event=custom --ignore-errors --all-containers --follow --max-log-requests=20