#!/bin/bash

# -- USER CREATE SCRIPT -------------------------------------------------------
# Adds a non root user. It responds to the following environmental variables:
#
#     USER_ID           ID for new linux user
#     GROUP_ID          Group ID for new linux user
#     USER_NAME         username for new linux user
#     USER_PASSWORD     password for new linux user
#     GRANT_SUDO        if "PASSWORDLESS" or TRUE" then the new linux user will 
#                       have sudo privilages. PASSWORDLESS enables passwordless 
#                       sudo, TRUE enables password-based sudo unless password 
#                       is empty in which case it grades passwordless sudo.
# ------------------------------------------------------------------------------

dnf install -y shadow-utils passwd cracklib-dicts
dnf clean all 

# -- Add User-------------------------------------------------------------------
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] ; then
    useradd -ml -s /bin/bash $USER_NAME
else
    groupadd -o --gid $GROUP_ID $USER_NAME
    useradd -mlo -s /bin/bash --uid $USER_ID --gid $GROUP_ID $USER_NAME
fi

# -- Set User Password ---------------------------------------------------------
if [ -n "$USER_PASSWORD" ] ; then
    echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME
fi

# -- Grant sudo ----------------------------------------------------------------
# passwordless sudo if PASSWORDLESS is specified, or if TRUE is specified and user password is empty
if [[ "$GRANT_SUDO" = "PASSWORDLESS" ||  ( "$GRANT_SUDO" = "TRUE" && -z "$USER_PASSWORD" ) ]] ; then    
    groupadd wheelnopw
    usermod -aG wheelnopw $USER_NAME
    # Fedora /etc/sudoers file already has "#includedir /etc/sudoers.d" for user modifications
    # Here we add a new config file that grants the group wheelnopw passwordless sudo
    SUDOCONFIG="## No password sudo group\n%wheelnopw        ALL=(ALL)       NOPASSWD: ALL"
    echo -e $SUDOCONFIG >> /etc/sudoers.d/npconfig
elif [ "$GRANT_SUDO" = "TRUE" ] ; then
    usermod -aG wheel $USER_NAME
fi

# -- add user to shared group ---------------------------------------------------
groupadd shared
usermod -aG shared $USER_NAME
if [ -n "$SHARED_STORAGE_DIR" ] ; then
    mkdir -p "$SHARED_STORAGE_DIR"
    chown :shared "$SHARED_STORAGE_DIR"
    chmod 774 "$SHARED_STORAGE_DIR"
fi