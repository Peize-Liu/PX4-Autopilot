#!/bin/bash
source ./nxt_px4_version_info.sh

pull_docker(){
  docker pull "${DOCKER_IMAGE_VERSION}"
}

check_image(){
  docker_image_exist=$(docker images ${DOCKER_IMAGE_VERSION})
  if [ -n "$docker_image_exist" ]
  then
    echo "Docker image is downloaded will build the containter"
    return 0
  else
    echo "erro: Docker images need to be downloaded"
    return 1
  fi
}

stop_container(){
  docker stop ${DOCEKR_NAME};
}

start_containter(){
  docker start ${DOCEKR_NAME};
}

build_frameware(){
  docker exec -it ${DOCEKR_NAME} bash -c "cd /src/NxtPX4/PX4-Autopilot; make clean ; make $1";
  stop_container
}

build_run_container(){
  # check mount dir
  VOLUME_PATH=$(pwd)/../../NxtPX4;
  echo "Mount ${VOLUME_PATH} to docker:/src/NxtPX4/ "
  if [ ! -d $VOLUME_PATH ]
    then
      echo "Path: ${VOLUME_PATH} is not NxtPX4 repo please run this script under xxx/NxtPX4/PX4-Autopilot/"
  fi
  # check mount dir

  docker run -dit --privileged \
  --env=LOCAL_USER_ID="$(id -u)" \
  -v ${VOLUME_PATH}:/src/NxtPX4/:rw \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -e DISPLAY=:0 \
  -p 14556:14556/udp \
  --name=${DOCEKR_NAME} ${DOCKER_IMAGE_VERSION};
  # bash -c "cd /src/NxtPX4/PX4-Autopilot";
  bash -c "cd /src/NxtPX4/PX4-Autopilot; make clean ; make hkust_nxt";
  return 0
}

help(){
  echo "Usage:    ./start_docker.sh [target]"
  echo "Example:  ./start_docker.sh hkust_nxt"
  echo "          ./start_docker.sh hkust_nxt_bootloader"
}

main(){
  docker_exist=$(docker ps -a|grep ${DOCEKR_NAME})
  if [ -n "$docker_exist" ]
    then
      echo "Docker container exist start container to compile"
      # stop_container;
      # docker rm NxtCompileContainer
      start_containter;
      build_frameware $1;
    else
      echo "############ error: Docker container does not exist, setup container#############"
      check_image
      if [ $? == 0 ]
        then
          echo "build run container"
          build_run_container
          stop_container
        else
          echo "download image"
          pull_docker
          echo "build container"
          build_run_container
          echo "stop container"
          stop_container
      fi
  fi
}

if [ $# -ne 1 ]
  then
    help
  else
    main $1
fi



