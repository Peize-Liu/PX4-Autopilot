#! /bin/bash

docker run -it --privileged \
    --env=LOCAL_USER_ID="$(id -u)" \
    -v ~/workspace/NxtPX4/PX4-Autopilot:/src/PX4-Autopilot/:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -e DISPLAY=:0 \
    -p 14556:14556/udp \
    --name=NxtCompileContainer px4io/px4-dev-nuttx-focal:2021-09-08 bash;
