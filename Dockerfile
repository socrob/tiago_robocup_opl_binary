# Copyright (c) 2019 TOYOTA MOTOR CORPORATION
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

#  * Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#  notice, this list of conditions and the following disclaimer in the
#  documentation and/or other materials provided with the distribution.
#  * Neither the name of Toyota Motor Corporation nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
FROM devrt/ros-devcontainer-vscode:kinetic-desktop AS base

USER root

ENV DEBIAN_FRONTEND noninteractive
ENV CC /usr/bin/gcc
ENV CXX /usr/bin/g++

# install depending packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    mesa-utils htop imagemagick \
    python-scipy \
    ros-kinetic-gazebo9-ros ros-kinetic-gazebo9-plugins ros-kinetic-gazebo9-ros-control libgazebo9-dev libpoco-dev \
    ros-kinetic-slam-karto \
    ros-kinetic-rviz \
    ros-kinetic-dwa-local-planner \
    ros-kinetic-teleop-twist-joy \
    ros-kinetic-eigen-conversions \
    ros-kinetic-map-server \
    ros-kinetic-moveit-commander \
    ros-kinetic-joy \
    ros-kinetic-robot-state-publisher \
    ros-kinetic-moveit-core \
    ros-kinetic-moveit-ros-benchmarks \
    ros-kinetic-moveit-planners-ompl \
    ros-kinetic-moveit-ros-planning \
    ros-kinetic-moveit-ros-visualization \
    ros-kinetic-moveit-ros-move-group \
    ros-kinetic-moveit-simple-controller-manager \
    ros-kinetic-moveit-setup-assistant \
    ros-kinetic-urdfdom-py \
    ros-kinetic-roslint \
    ros-kinetic-teleop-twist-keyboard \
    ros-kinetic-joint-state-controller \
    ros-kinetic-joint-trajectory-controller \
    ros-kinetic-gmapping \
    ros-kinetic-move-base \
    ros-kinetic-xacro \
    ros-kinetic-joint-state-publisher \
    liburdfdom-tools \
    ros-kinetic-image-proc \
    ros-kinetic-scan-tools \
    ros-kinetic-depth-image-proc \
    ros-kinetic-amcl \
    ros-kinetic-effort-controllers \
    ros-kinetic-ros-controllers \
    ros-kinetic-hector-mapping && \
    pip install -U --ignore-installed pyassimp && \
    apt-get autoremove && \
    apt-get clean

FROM base AS build

SHELL ["/bin/bash", "-c"]

RUN rosdep update
RUN mkdir -p /wrs_ws/src
ADD src-upstream /wrs_ws/src-upstream
ADD src /wrs_ws/src
RUN cd /wrs_ws/src && source /opt/ros/$ROS_DISTRO/setup.bash && catkin_init_workspace || true
#RUN cd /wrs_ws && source /opt/ros/$ROS_DISTRO/setup.bash && rosdep install --from-paths src --ignore-src -r -y
RUN cd /wrs_ws && source /opt/ros/$ROS_DISTRO/setup.bash && catkin_make install -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/wrs -DCATKIN_ENABLE_TESTING=0

FROM base

RUN mv /entrypoint.sh /entrypoint-original.sh
ADD entrypoint-wrs.sh /entrypoint.sh

ADD start-simulator.sh /start-simulator.sh
ADD start-simulator-highrtf.sh /start-simulator-highrtf.sh
ADD start-simulator-fast.sh /start-simulator-fast.sh
ADD start-simulator-fast-highrtf.sh /start-simulator-fast-highrtf.sh

COPY --from=build /opt/wrs /opt/wrs
#ADD filterable-rosmaster.py /opt/ros/kinetic/bin/
#RUN rm /opt/ros/kinetic/bin/rosmaster && ln -s /opt/ros/kinetic/bin/filterable-rosmaster.py /opt/ros/kinetic/bin/rosmaster