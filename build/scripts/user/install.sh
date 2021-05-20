#!/bin/bash

# -- USER INSTALL SCRIPT -------------------------------------------------------
# Installs dependencies for Fedora using the dnf package manager and additional
# manual installations. This script installs all the dependancies as a standard
# user. It responds to the following environmental variables:
#
# ---- languages ---------------------------------------------------------------
#     LANG_C          TRUE => C language packages installed
#     LANG_FORTRAN    TRUE => Fortran language installed
#     LANG_PYTHON3    TRUE => Python3 language installed
#     LANG_JULIA      TRUE => Julia language installed
#     LANG_R          TRUE => R languag installed
#     LANG_LATEX      TRUE => Latex installed
#
# ---- libraries ---------------------------------------------------------------
#     LIB_MATPLOTLIB  TRUE => matplotlib
#     LIB_LINALG      TRUE => Linear algebra libraries BLAS, LAPACK and FFTW
#     LIB_OPENMPI     TRUE => openmpi (loaded using module load mpi)
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#     DEV_THEIA       TRUE -> Theia IDE with support for selected languages.
#     DEV_CLI         TRUE => CLI development tools: git, tmux, vim, emac
# ---- Package Managers --------------------------------------------------------
#     ASW_SPACK      TRUE => Spack
#
# NOTE: Additional dependancies can be placed in the script
# user_install_extra.sh or written directly within this bash script.
# ------------------------------------------------------------------------------

# Certain Julia Packages do not install as root. Install them here instead
# -- Julia Packages ------------------------------------------------------------
if [ "$LANG_JULIA" = "TRUE" ] ; then
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        export JULIA_DEPOT_PATH="$SHARED_STORAGE_DIR/julia-depot"
        mkdir -p "$JULIA_DEPOT_PATH"
        echo "export JULIA_DEPOT_PATH='$JULIA_DEPOT_PATH'" >> ~/.bashrc
    fi
    # ----> plotters
    if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
        julia -e 'import Pkg; Pkg.add("PyPlot"); using PyPlot'
    fi
    julia -e 'import Pkg; Pkg.add("GR"); using GR'
    julia -e 'import Pkg; Pkg.add("UnicodePlots"); using UnicodePlots'
    julia -e 'import Pkg; Pkg.add("Plots"); using Plots'
    julia -e 'import Pkg; Pkg.add("LaTeXStrings"); using LaTeXStrings'
    # ----> debug and language server
    julia -e 'import Pkg; Pkg.add("LanguageServer"); using LanguageServer'
    julia -e 'import Pkg; Pkg.add("JuliaInterpreter"); using JuliaInterpreter'
    # -----> MPI.jl (https://github.com/JuliaParallel/MPI.jl)
    if [ "$LIB_OPENMPI" = "TRUE" ] ; then
        source /etc/profile.d/modules.sh
        module load mpi/openmpi-x86_64
        julia -e 'ENV["JULIA_MPI_BINARY"]="system"; import Pkg; Pkg.add("MPI"); using MPI'
    fi
    # ----> Jupyter kernel
    if [ "$DEV_JUPYTER" = "TRUE" ] ; then
        julia -e 'import Pkg; Pkg.add("IJulia")'    
    fi
    # ----> fix permissions for non-local folders (see: https://github.com/JuliaLang/julia/issues/12876)
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        chown -R :shared "$JULIA_DEPOT_PATH"
        chmod -R 774 "$JULIA_DEPOT_PATH"
    fi
fi

# -- R Packages ----------------------------------------------------------------
if [ "$LANG_R" = "TRUE" ] ; then
    # ----> Jupyter kernel
    if [ "$DEV_JUPYTER" = "TRUE" ] ; then
        R -e "IRkernel::installspec()"
    fi
fi

# -- Spack ---------------------------------------------------------------------
if [ "$ASW_SPACK" = "TRUE" ] ; then
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        SPACK_INSTALL_DIR="$SHARED_STORAGE_DIR/spack" # change default nvm install directory
    else
        SPACK_INSTALL_DIR=~/.local/spack
    fi
    git clone https://github.com/spack/spack.git "$SPACK_INSTALL_DIR"
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        chown -R :shared "$SPACK_INSTALL_DIR"
        chmod -R 774 "$SPACK_INSTALL_DIR"
    fi
    mkdir -p ~/.local/bin
    ln -s "$SPACK_INSTALL_DIR/bin/spack" ~/.local/bin/spack
fi

# -- Theia ---------------------------------------------------------------------
if [ "$DEV_THEIA" = "TRUE" ] ; then
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        export NVM_DIR="$SHARED_STORAGE_DIR/nvm" # change default nvm install directory
        mkdir -p "$NVM_DIR"
    fi
    # --> install nvm
    curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    source ~/.bash_profile
    # --> install latest node 12 (erbium)
    nvm install lts/erbium
    nvm use lts/erbium
    # --> install yarn
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        NPM_DIR="$SHARED_STORAGE_DIR/npm"
        mkdir -p "$NPM_DIR"
        npm config set cache "$NPM_DIR"
    fi
    npm install -g yarn
    # ----> fix permissions for non-local folders)
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        chown -R :shared "$NVM_DIR" "$NPM_DIR"
        chmod -R 774 "$NVM_DIR" "$NPM_DIR"
    fi
fi

# -- VNC -----------------------------------------------------------------------
if [ "$ASW_VNC" = "TRUE" ] ; then
    # ---> copy vnc config files
    mkdir -p ~/.vnc
    mv ~/.build/config/vnc/{config,xstartup} ~/.vnc/
    chmod u+x ~/.vnc/xstartup
    # ----> set vnc password
    echo -e "$ASW_VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
    chmod 0600 ~/.vnc/passwd
    # --> set desktop defaults
    mkdir -p ~/.config
    cp ~/.build/config/vnc/mimeapps.list ~/.config/mimeapps.list
    # --> disable xfce polkit, power management, screensaver / screen lock, dnfdragora updater
    mkdir -p ~/.config/autostart
    cp ~/.build/config/vnc/xfce/{xfce-polkit.desktop,xfce4-power-manager.desktop,xfce4-screensaver.desktop,org.mageia.dnfdragora-updater.desktop} ~/.config/autostart
    # --> disable xfce terminal paste warning
    mkdir -p ~/.config/xfce4/terminal/
    cp ~/.build/config/vnc/xfce/terminalrc ~/.config/xfce4/terminal/
    # --> disable screensaver and screen lock
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp ~/.build/config/vnc/xfce/xfce4-screensaver.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    # set default browser to epiphany ( equivalent to running xdg-settings set default-web-browser org.gnome.Epiphany.desktop -- does not work when run with vnc )
    mkdir -p ~/.config/xfce4/
    cp ~/.build/config/vnc/xfce/helpers.rc ~/.config/xfce4/
fi