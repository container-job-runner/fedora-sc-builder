#!/bin/bash

# -- ROOT INSTALL SCRIPT -------------------------------------------------------
# Installs dependencies for Fedora using the dnf package manager and additional
# manual installations. This script installs all the dependancies as root user.
# It responds to the following environmental variables:
#
# ---- languages ---------------------------------------------------------------
#     LANG_C          TRUE => C language packages installed
#     LANG_FORTRAN    TRUE => Fortran language installed
#     LANG_PYTHON3    TRUE => Python3 language installed
#     LANG_JULIA      TRUE => Julia language installed
#     LANG_R          TRUE => R languag installed
#     LANG_LATEX      TRUE => Latex installed
#     LANG_LATEX_PKG  STRING ("full" | "basic" | "small" | "medium" | "minimal")
#                     changes the latex package.
#
# ---- libraries ---------------------------------------------------------------
#     LIB_MATPLOTLIB  TRUE => matplotlib
#     LIB_LINALG      TRUE => Linear algebra libraries BLAS, LAPACK and FFTW
#     LIB_OPENMPI     TRUE => openmpi (loaded using module load mpi)
#     LIB_X11         TRUE => basic x11 libraries and Xvfb
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#     DEV_THEIA       TRUE -> Theia IDE with support for selected languages.
#     DEV_CLI         TRUE => CLI development tools: git, tmux, vim, emac
#
# ---- Package Managers --------------------------------------------------------
#     PKGM_SPACK      TRUE => Spack
#
# NOTE: To add extra dependancies for any language, library, or development
# environment that can be installed with dnf simply add an entry to the arrays
# in 1.1-1.3. More sophisticated dependancies can be placed in the script
# root_install_extra.sh or written within this bash script.
# ------------------------------------------------------------------------------

pkg_manager="dnf"

# == STEP 1: Install DNF packages ==============================================

# -- 1.1 DNF Packages: languages -----------------------------------------------
pkg_lang_c=('gcc' 'gcc-c++' 'gdb' 'make')
pkg_lang_fortran=('gcc' 'gdb' 'make' 'gcc-gfortran')
pkg_lang_python3=('python3' 'python3-numpy' 'python3-scipy' 'python3-sympy' 'python3-ipython' 'python3-pandas')
pkg_lang_julia=('julia' 'libQtGui.so.4')
pkg_lang_R=('R')
if [ -z "$LANG_LATEX_PKG" ] ; then
    LANG_LATEX_PKG='basic'
fi
pkg_lang_latex=("texlive-scheme-$LANG_LATEX_PKG")

# ---> additional language dependancies for Jupyter
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pkg_lang_R=("${pkg_lang_R[@]}" 'czmq-devel' 'libcurl-devel' 'openssl-devel')  # https://irkernel.github.io/installation/#linux-panel
fi

# -- 1.2 DNF Packages: libraries  ----------------------------------------------
pkg_lib_linAlg=('liblas-devel' 'lapack-devel' 'fftw-devel')
pkg_lib_openMPI=('environment-modules' 'openmpi-devel')
pkg_lib_matPlotLib=('python3-matplotlib' 'qt5-devel' 'libxkbfile' 'xorg-x11-fonts-misc' 'xorg-x11-xbitmaps')
pkg_lib_x11=('xorg-x11-apps' 'xorg-x11-xauth' 'xorg-x11-fonts*' 'Xvfb')

# -- 1.3 DNF Packages: development environments   ------------------------------
pkg_dev_jupyter=('nodejs' 'python3-pip' 'python3-notebook' 'mathjax' 'sscg' 'git')
pkg_dev_theia=()
pkg_dev_cli=('git' 'vim' 'emacs' 'tmux')

# -- 1.3 DNF Packages: package managers   --------------------------------------
pkg_pkgm_spack=('python3' 'gcc' 'make' 'git' 'curl' 'gnupg2')

# -- Add packages to dnfPkg array ----------------------------------------------
declare -a pkgs=();

# ----> languages

if [ "$LANG_C" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_c[@]}") ; fi

if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_fortran[@]}") ; fi

if [ "$LANG_PYTHON3" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_python3[@]}") ; fi

if [ "$LANG_JULIA" = "TRUE" ] ; then
  eval "$pkg_manager install -y dnf-plugins-core"
  eval "$pkg_manager copr enable -y nalimilan/julia"
  pkgs=("${pkgs[@]}" "${pkg_lang_julia[@]}") ; fi

if [ "$LANG_R" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_R[@]}") ; fi

if [ "$LANG_LATEX" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_latex[@]}") ; fi

# ----> libraries

if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_matPlotLib[@]}") ; fi

if [ "$LIB_LINALG" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_linAlg[@]}") ; fi

if [ "$LIB_OPENMPI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_openMPI[@]}") ; fi

if [ "$LIB_X11" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_x11[@]}") ; fi

# ----> development environments

if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_jupyter[@]}") ; fi

if [ "$DEV_THEIA" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_theia[@]}") ; fi

if [ "$DEV_CLI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_cli[@]}") ; fi

# ----> package managers

if [ "$PKGM_SPACK" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_pkgm_spack[@]}") ; fi

# -- remove redundant elements then install (requires bash 4+) -----------------
declare -A pkgsUniq
for k in ${pkgs[@]} ; do pkgsUniq[$k]=1 ; done

# -- install dependencies ------------------------------------------------------
if [ -n "$pkgs" ] ; then
  echo "$pkg_manager install -y ${!pkgsUniq[@]}"
  eval $pkg_manager install -y ${!pkgsUniq[@]}
fi

# == STEP 2: Install Additional Packages =======================================

# -----> Jupyter
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pip3 install --upgrade pip # upgrade pip (important for pyQtk5 library - otherwise quits)
  pip3 install jupyterlab # Jupyter Lab
  # --> install atom dark theme -------------------------------------------------
  cd /opt
  git clone https://github.com/container-job-runner/jupyter-atom-theme.git
  jupyter labextension install jupyter-atom-theme
  # --> matplotlib Widgets for JupiterLab (https://github.com/matplotlib/jupyter-matplotlib)
  if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
    pip3 install ipympl
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
    jupyter labextension install jupyter-matplotlib
    pip3 install PyQt5
  fi
  if [ "$LANG_LATEX" = "TRUE" ] ; then
    # --> Latex for JupyterLab (https://github.com/jupyterlab/jupyterlab-latex)
    pip3 install jupyterlab_latex
    jupyter labextension install @jupyterlab/latex
  fi
  if [ "$LANG_C" = "TRUE" ] ; then
    # --> C Kernel for Jypyter https://github.com/brendan-rius/jupyter-c-kernel
    pip3 install jupyter-c-kernel
    install_c_kernel --user
  fi
  if [ "$LANG_R" = "TRUE" ] ; then
    # --> R Kernel for Jupyter (https://irkernel.github.io/installation/)
    R -e 'r = getOption("repos"); r["CRAN"] = "https://cloud.r-project.org/"; install.packages(c("repr", "IRdisplay", "IRkernel"), repos = r, type = "source");'
  fi
  # if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  #   # possible options to add later:
  #   # 1. fortran coarrays   https://github.com/sourceryinstitute/OpenCoarrays/blob/master/INSTALL.md
  #   # 2. lfortran:          https://lfortran.org/ https://docs.lfortran.org/installation/
  #   # 3. fortran_magic      https://github.com/mgaitan/fortran_magic
  # fi
fi
