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
    # ----> fix permissions for non-local folders (see: https://github.com/JuliaLang/julia/issues/12876)
    if [ -n "$SHARED_STORAGE_DIR" ] ; then
        chown -R :shared "$JULIA_DEPOT_PATH"  
        chmod -R 774 "$JULIA_DEPOT_PATH"  
    fi
fi

# -- Juputer Kernels -----------------------------------------------------------
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  # ----> Julia
  if [ "$LANG_JULIA" = "TRUE" ] ; then
    julia -e 'import Pkg; Pkg.add("IJulia")'
  fi
  # ----> R
  if [ "$LANG_R" = "TRUE" ] ; then
    R -e "IRkernel::installspec()"
  fi
fi

# -- Spack ---------------------------------------------------------------------
if [ "$ASW_SPACK" = "TRUE" ] ; then
  mkdir -p ~/.local
  mkdir -p ~/.local/bin
  git clone https://github.com/spack/spack.git ~/.local/spack
  ln -s ~/.local/spack/bin/spack ~/.local/bin/spack
fi

# -----> Theia
if [ "$DEV_THEIA" = "TRUE" ] ; then
  # --> install nvm
  curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash
  source ~/.bash_profile
  # --> install latest node 12 (erbium)
  nvm install lts/erbium 
  nvm use lts/erbium 
  # --> install yarn
  npm install -g yarn
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
fi