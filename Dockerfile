FROM fedora:latest

# ---- languages ---------------------------------------------------------------
ARG LANG_C
ARG LANG_FORTRAN
ARG LANG_PYTHON3
ARG LANG_JULIA
ARG LANG_R
ARG LANG_LATEX
# ---- libraries ---------------------------------------------------------------
ARG LIB_MATPLOTLIB
ARG LIB_LINALG
ARG LIB_OPENMPI
# ---- dev environemnts --------------------------------------------------------
ARG DEV_JUPYTER
ARG DEV_CLI
# ---- Package Managers --------------------------------------------------------
ARG PKGM_SPACK

# -- install root dependencies -------------------------------------------------
RUN mkdir /build-scripts
COPY build-scripts/root_install.sh /build-scripts
RUN chmod +x /build-scripts/root_install.sh
RUN /build-scripts/root_install.sh

# -- User arguments ------------------------------------------------------------
# Set USER_ID = $(id -u) and GROUP_ID = $(id -g) for correct bind permissions
ARG USER_NAME=user
ARG USER_PASSWORD=password
ARG GRANT_SUDO=false
ARG USER_ID
ARG GROUP_ID

# -- Generate restricted user account ------------------------------------------
RUN dnf install -y shadow-utils passwd cracklib-dicts
RUN if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] ; \
  then useradd -m -l -s /bin/bash $USER_NAME ; \
  else (groupadd -o --gid $GROUP_ID $USER_NAME) && (useradd -m -l -o -s /bin/bash --uid $USER_ID --gid $GROUP_ID $USER_NAME) ; fi
RUN echo "$USER_NAME:$USER_PASSWORD" | chpasswd
RUN if [ "$GRANT_SUDO" = "TRUE" ] ; \
  then (usermod -aG wheel $USER_NAME) ; fi

# -- Set up user user dependancies ---------------------------------------------
WORKDIR /home/$USER_NAME
RUN mkdir .build-scripts
COPY build-scripts/user_install.sh .build-scripts
RUN chown -R $USER_NAME: .build-scripts
USER $USER_NAME
RUN chmod +x .build-scripts/user_install.sh
RUN .build-scripts/user_install.sh

# -- install extra root & user dependencies here (Prevents full rebuild)--------
USER root
WORKDIR /
COPY build-scripts/root_install_extra.sh /build-scripts
RUN chmod +x /build-scripts/root_install_extra.sh
RUN /build-scripts/root_install_extra.sh

WORKDIR "/home/$USER_NAME"
COPY build-scripts/user_install_extra.sh .build-scripts
RUN chown -R $USER_NAME: .build-scripts
USER $USER_NAME
RUN chmod +x .build-scripts/user_install_extra.sh
RUN .build-scripts/user_install_extra.sh

ENTRYPOINT ["bash", "-c"]
