## ChangeLog

This document describes changes made when upgrading the Fedora OS.

# Fedora 33

No changes necessary.

# Fedora 34

## vnc 

1. Replaced `/usr/bin/vncserver` (which was deprecated in Fedora34) with a shell script that runs a custom python script to adjust user vnc settings (geometry, rfbport, and depth) and then runs `/usr/libexec/vncserver :1`
2. Added the following dependencies to vnc: python, (1) pip and python package regex for running custom script, (2) gedit for editing text files, (3) epiphany for web browsing

## xfce

1. Removed XFCE Power Manager Plugin (`dnf remove -y xfce4-power-manager`). Power management does not work correctly in container, and xfce power management panel leads to the startup error:  Plugin "Power manager plugin" unexpectedly left the panel...The plugin restarted more than once in the last 60 second"
2. Disabled XFCE Polykit autostart by adding  ~/.config/autostart/xfce-polkit.desktop. This is equivalent to unchecking `Settings > Session and Startup > Application Startup > XFCE PolKit`. This change eliminates the startup error message "XFCE PolicyKit Agent"
3. Disabled automatic startup of the following services: 
    - xfce4 power manager (does not start properly in container)
    - xfce4 screensaver (prevents unnecessary screen locking in vnc)
    - org.mageia.dnfdragora-updater.desktop (automatic updates are not useful in container)
4. Disabled terminal paste warning by adding `.config/xfce4/terminal/terminalrc`. This is equivalent to checking and unchecking `Edit > Preferences > Show unsafe paste dialog` in Xfce Terminal.
5. Disabled screensaver and screen-lock in vnc by adding `/home/user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml`)
6. Added flag --security-opt seccomp=unconfined (necessary for xfce terminal until https://github.com/mviereck/x11docker/issues/346 is resolved). For additional info see:
    - https://gitlab.xfce.org/apps/xfce4-terminal/-/issues/116#note_30805
    - https://github.com/mviereck/x11docker/issues/346
    - https://github.com/containers/podman/issues/10337