# How to handle dependency updates:
- When installing/removing a npm module be sure to change the version in Makefile, build the image, push the image and update the image on pipeline/.drone.yml

# To do:
- Add make targets to run pod in default namespace & rsync to files from local dir to there: https://serverfault.com/questions/741670/rsync-files-to-a-kubernetes-pod
- Create pipeline to build the docker image