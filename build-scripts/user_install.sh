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
#     PKGM_SPACK      TRUE => Spack
#
# NOTE: Additional dependancies can be placed in the script
# user_install_extra.sh or written directly within this bash script.
# ------------------------------------------------------------------------------

# Certain Julia Packages do not install as root. Install them here instead
# -- Julia Packages ------------------------------------------------------------
if [ "$LANG_JULIA" = "TRUE" ] ; then
  # ----> plotters
  if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
      julia -e 'import Pkg; Pkg.add("PyPlot")'
  fi
  julia -e 'import Pkg; Pkg.add("Gadfly")'
  julia -e 'import Pkg; Pkg.add("Plots")'
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
if [ "$PKGM_SPACK" = "TRUE" ] ; then
  mkdir -p ~/.local
  mkdir -p ~/.local/bin
  git clone https://github.com/spack/spack.git ~/.local/spack
  ln -s ~/.local/spack/bin/spack ~/.local/bin/spack
fi

# -----> Theia
if [ "$DEV_THEIA" = "TRUE" ] ; then
  THEIA_INSTALL_DIR=~/.local/lib/theia
  THEIA_PATH_DIR=~/.local/bin
  PLUGIN_BUILD_DIR=~/.local/tmp/vs-plugins
  # --> install nvm
  curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  source ~/.bash_profile
  # --> install latest node 10 (dubnium)
  nvm install lts/dubnium
  nvm use lts/dubnium
  # --> install theia
  alias python=python2
  mkdir -p $THEIA_INSTALL_DIR
  cd $THEIA_INSTALL_DIR
  wget https://github.com/container-job-runner/stack-config-files/releases/download/0.1-alpha/package.json # get package.json file
  yarn
  yarn build
  unalias python
  # --> make a shell script for launching theia
  mkdir -p $THEIA_PATH_DIR
  echo -e '#!/bin/bash\nyarn --cwd '$(pwd)' start $@' >> "$THEIA_PATH_DIR/theia"
  chmod a+x "$THEIA_PATH_DIR/theia"
  # --> add additional plugins
  npm install -g vsce # install visual code plugin
  mkdir -p $PLUGIN_BUILD_DIR
  # --> fortran plugin
  cd $PLUGIN_BUILD_DIR
  git clone https://github.com/krvajal/vscode-fortran-support.git --branch 2.1.0 --depth 1
  cd "$PLUGIN_BUILD_DIR/vscode-fortran-support"
  npm install && vsce package
  cp linter-gfortran-2.1.0.vsix "$THEIA_INSTALL_DIR/plugins/linter-gfortran-2.1.0.vsix"
fi
