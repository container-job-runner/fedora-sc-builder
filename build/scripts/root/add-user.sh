#!/bin/bash

# -- USER CREATE SCRIPT -------------------------------------------------------
# Adds a non root user. It responds to the following environmental variables:
#
#     USER_ID         ID for new linux user
#     GROUP_ID        Group ID for new linux user
#     USER_NAME       username for new linux user
#     USER_PASSWORD   password for new linux user
#     GRANT_SUDO      if "TRUE" then new linux user will have sudo privilages
# ------------------------------------------------------------------------------

dnf install -y shadow-utils passwd cracklib-dicts

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
if [ "$GRANT_SUDO" = "TRUE" ] ; then
    if [ -n "$USER_PASSWORD" ] ; then
        (usermod -aG wheel $USER_NAME)
    else
        groupadd wheelnopw
        usermod -aG wheelnopw $USER_NAME
        # Fedora /etc/sudoers file already has "#includedir /etc/sudoers.d" for user modifications
        # Here we add a new config file that grants the group wheelnopw passwordless sudo
        SUDOCONFIG="## No password sudo group\n%wheelnopw        ALL=(ALL)       NOPASSWD: ALL"
        echo -e $SUDOCONFIG >> /etc/sudoers.d/npconfig
    fi
fi