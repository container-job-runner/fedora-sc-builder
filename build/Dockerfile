ARG DEV_THEIA
ARG THEIA_INSTALL_DIR=/opt/theia

# == 1. build stage: Theia =====================================================
FROM fedora:32 as theia_builder
ARG DEV_THEIA
ARG THEIA_INSTALL_DIR
WORKDIR /root/theia
RUN if [ "$DEV_THEIA" = "TRUE" ] ; then \
    dnf install -y wget make g++ ; \
    # --> install nvm
    curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash ; \
    source ~/.bash_profile ; \
    # --> install latest node 12 (erbium)
    nvm install lts/erbium ; \
    nvm use lts/erbium ; \
    # --> install yarn
    npm install -g yarn ; \
    wget https://github.com/container-job-runner/stack-config-files/releases/download/0.1.8-alpha/package.json ; \
    wget https://github.com/container-job-runner/stack-config-files/releases/download/0.1.8-alpha/yarn.lock ; \
    yarn --cache-folder ./ycache ; \
    rm -rf ./ycache ; \
    NODE_OPTIONS="--max_old_space_size=4096" ; \
    yarn theia build ; \
    yarn theia download:plugins ; \
    fi
RUN echo -e '#!/bin/bash\nyarn --cwd '$THEIA_INSTALL_DIR' start $@' > /root/theia_launcher ; \
    chmod a+x /root/theia_launcher ;

# == 2. main Dockerfile: Fedora ================================================
FROM fedora:32

# -- Directory for storing build scripts ---------------------------------------
RUN mkdir -p /opt/build-scripts

# == User Creation ==============================================================
ARG USER_NAME=user
ARG USER_PASSWORD=password
ARG GRANT_SUDO=false
ARG USER_ID
ARG GROUP_ID

# -- Generate restricted user account ------------------------------------------
COPY scripts/root/add-user.sh /opt/build-scripts/
RUN chmod +x /opt/build-scripts/add-user.sh && /opt/build-scripts/add-user.sh

# == Software Installation =====================================================

# ----> ARGS: languages
ARG LANG_C
ARG LANG_FORTRAN
ARG LANG_PYTHON3
ARG LANG_JULIA
ARG LANG_R
ARG LANG_OCTAVE
ARG LANG_LATEX
# ----> ARGS: libraries
ARG LIB_MATPLOTLIB
ARG LIB_LINALG
ARG LIB_OPENMPI
ARG LIB_X11
ARG LIB_RAY
# ----> ARGS: dev environments
ARG DEV_JUPYTER
ARG DEV_THEIA
ARG DEV_CLI
ARG DEV_VSCODE
# ----> ARGS: additional software
ARG ASW_SPACK
ARG ASW_VNC
ARG ASW_SSHD
ARG ASW_SLURM
# ----> ARGS: additional options
ARG THEIA_INSTALL_DIR
ARG ASW_VNC_PASSWORD=password
ARG SHARED_STORAGE_DIR=/opt/shared

# -- install root dependencies -------------------------------------------------
COPY scripts/root/install.sh /opt/build-scripts/install.sh
RUN chmod +x /opt/build-scripts/install.sh && /opt/build-scripts/install.sh
COPY --from=theia_builder /root/theia $THEIA_INSTALL_DIR
COPY --from=theia_builder /root/theia_launcher /usr/local/bin/theia

# -- install user dependencies -------------------------------------------------
ARG USER_BUILD_DIR="/home/$USER_NAME/.build"
RUN mkdir -p "$USER_BUILD_DIR/scripts" "$USER_BUILD_DIR/config"
# ----> Copy config scripts
COPY config/user/ "$USER_BUILD_DIR/config/"
RUN chown -R $USER_ID:$GROUP_ID "$USER_BUILD_DIR"
# ----> run install scripts
COPY scripts/user/install.sh "$USER_BUILD_DIR/scripts/"
RUN chown $USER_ID:$GROUP_ID "$USER_BUILD_DIR/scripts/install.sh"
USER $USER_NAME
RUN chmod u+x "$USER_BUILD_DIR/scripts/install.sh" && "$USER_BUILD_DIR/scripts/install.sh"

# -- install extra root dependencies (placed here to prevent full rebuild) -----
USER root
COPY scripts/root/install-extra.sh /opt/build-scripts/
RUN chmod +x /opt/build-scripts/install-extra.sh && /opt/build-scripts/install-extra.sh

# -- install extra user dependencies (placed here to prevent full rebuild) -----
COPY scripts/user/install-extra.sh "$USER_BUILD_DIR/scripts/"
RUN chown $USER_ID:$GROUP_ID "$USER_BUILD_DIR/scripts/install-extra.sh"
USER $USER_NAME
RUN chmod +x "$USER_BUILD_DIR/scripts/install-extra.sh" && "$USER_BUILD_DIR/scripts/install-extra.sh"

# -- remove user build directory
RUN rm -r /home/$USER_NAME/.build

WORKDIR "/home/$USER_NAME"
ENTRYPOINT ["bash", "-l", "-c"]