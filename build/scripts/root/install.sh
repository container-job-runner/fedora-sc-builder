#!/bin/bash

# -- ROOT INSTALL SCRIPT -------------------------------------------------------
# Installs dependencies for Fedora using the dnf package manager and additional
# manual commands. This script runs as root user and responds to the following
# environmental variables:
#
# ---- languages ---------------------------------------------------------------
#     LANG_C          TRUE => C language packages installed
#     LANG_FORTRAN    TRUE => Fortran language installed
#     LANG_PYTHON3    TRUE => Python3 language installed
#     LANG_JULIA      TRUE => Julia language installed
#     LANG_R          TRUE => R languag installed
#     LANG_OCTAVE     TRUE => Octave programming language
#     LANG_LATEX      TRUE => Latex installed
#     LANG_LATEX_PKG  STRING ("full" | "basic" | "small" | "medium" | "minimal")
#                     changes the latex package.
#
# ---- libraries ---------------------------------------------------------------
#     LIB_MATPLOTLIB  TRUE => matplotlib
#     LIB_LINALG      TRUE => Linear algebra libraries BLAS, LAPACK and FFTW
#     LIB_OPENMPI     TRUE => openmpi (loaded using module load mpi)
#     LIB_X11         TRUE => basic x11 libraries and Xvfb
#     LIB_RAY         TRUE => python Ray library
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#     DEV_THEIA       TRUE => Theia IDE with support for selected languages.
#     DEV_VSCODE      TRUE => Visual Studio Code
#     DEV_CLI         TRUE => CLI development tools: git, tmux, vim, emacs
#
# ---- Software ----------------------------------------------------------------
#     ASW_SPACK       TRUE => Spack
#     ASW_VNC         TRUE => Tiger VNC
#     ASW_SSHD        TRUE => SSHD
#     ASW_SLURM       TRUE => Slurm
#
# NOTE: To add extra dependancies for any language, library, or development
# environment that can be installed with dnf simply add an entry to the arrays
# in 1.1-1.3. More sophisticated dependancies can be placed in the script
# install-extra.sh or written within this bash script.
# ------------------------------------------------------------------------------

# load helper functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/helper-functions.sh"

pkg_manager="dnf"

# == STEP 1: Install DNF packages ==============================================

# -- 1.1 DNF Packages: languages -----------------------------------------------
pkg_lang_c=('gcc' 'gcc-c++' 'gdb' 'redhat-rpm-config') #" redhat-rpm-config prevents gcc: error: /usr/lib/rpm/redhat/redhat-hardened-cc1: No such file or directory" workaround
pkg_lang_fortran=('gcc' 'gdb' 'make' 'gcc-gfortran')
pkg_lang_python3=('python3' 'python3-devel' 'python3-pip' 'python3-numpy' 'python3-scipy' 'python3-sympy' 'python3-ipython' 'python3-pandas')
pkg_lang_julia=('julia' 'libXt' 'libXrender' 'libXext' 'mesa-libGL' 'qt5-qtbase-gui')
pkg_lang_R=('R')
pkg_lang_octave=('octave' 'octave-devel' 'gcc-c++' 'make' 'redhat-rpm-config' 'diffutils' 'git' 'gnutls-devel') # remove git once https://github.com/carlodefalco/octave-mpi/issues/4 is resolved
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
pkg_lib_ray=('python3' 'python3-pip' 'python3-devel' 'gcc')

# -- 1.3 DNF Packages: development environments   ------------------------------
pkg_dev_jupyter=('nodejs' 'python3-pip' 'python3-notebook' 'mathjax' 'sscg' 'git')
pkg_dev_theia=()
pkg_dev_cli=('git' 'vim' 'emacs' 'tmux')
pkg_dev_vscode=('code')

# -- 1.3 DNF Packages: package managers   --------------------------------------
pkg_asw_spack=('python3' 'gcc' 'make' 'git' 'curl' 'gnupg2')
pkg_asw_vnc=('tigervnc-server' '@xfce-desktop-environment' 'python3' 'python3-pip' 'gedit' 'epiphany')
pkg_asw_sshd=('openssh-server')
pkg_asw_slurm=('slurm' 'slurm-slurmctld' 'slurm-slurmd' 'munge' 'munge-devel')

# -- Add packages to pkgs array ------------------------------------------------
declare -a pkgs=();

# ----> languages

if [ "$LANG_C" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_c[@]}") ; fi

if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_fortran[@]}") ; fi

if [ "$LANG_PYTHON3" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_python3[@]}") ; fi

if [ "$LANG_JULIA" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_julia[@]}") ; fi

if [ "$LANG_R" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_R[@]}") ; fi

if [ "$LANG_LATEX" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_latex[@]}") ; fi

if [ "$LANG_OCTAVE" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_octave[@]}") ; fi

# ----> libraries

if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_matPlotLib[@]}") ; fi

if [ "$LIB_LINALG" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_linAlg[@]}") ; fi

if [ "$LIB_OPENMPI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_openMPI[@]}") ; fi

if [ "$LIB_X11" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_x11[@]}") ; fi

if [ "$LIB_RAY" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_ray[@]}") ; fi

# ----> development environments

if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_jupyter[@]}") ; fi

if [ "$DEV_THEIA" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_theia[@]}") ; fi

if [ "$DEV_CLI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_cli[@]}") ; fi

if [ "$DEV_VSCODE" = "TRUE" ] ; then # instructions from https://code.visualstudio.com/docs/setup/linux
  rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  pkgs=("${pkgs[@]}" "${pkg_dev_vscode[@]}") ; fi

# ----> additional software

if [ "$ASW_SPACK" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_spack[@]}") ; fi

if [ "$ASW_VNC" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_vnc[@]}") ; fi

if [ "$ASW_SSHD" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_sshd[@]}") ; fi

if [ "$ASW_SLURM" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_slurm[@]}") ; fi

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
  pip3 install jupyterlab # Jupyter Lab
  # --> install atom dark theme ------------------------------------------------
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
  if [ "$DEV_CLI" = "TRUE" ] ; then
    pip3 install --upgrade jupyterlab jupyterlab-git
    jupyter lab build
  fi
  # if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  #   # possible options to add later:
  #   # 1. fortran coarrays   https://github.com/sourceryinstitute/OpenCoarrays/blob/master/INSTALL.md
  #   # 2. lfortran:          https://lfortran.org/ https://docs.lfortran.org/installation/
  #   # 3. fortran_magic      https://github.com/mgaitan/fortran_magic
  # fi
fi

# -----> Octave
if [ "$LANG_OCTAVE" = "TRUE" ] ; then
    octave --no-gui --no-window-system --eval 'pkg install -global -forge struct'
    octave --no-gui --no-window-system --eval 'pkg install -global -forge parallel' 
    if [ "$LIB_OPENMPI" = "TRUE" ] ; then  
        # load module
        source /etc/profile.d/modules.sh
        module load mpi/openmpi-x86_64
        # Once https://github.com/carlodefalco/octave-mpi/issues/4 is resolved
        # --> Update url and uncomment:        
        # octave --eval 'pkg install -global https://github.com/carlodefalco/octave-mpi/releases/download/v3.1.0/mpi-3.1.0.tar.gz'        
        # --> remove section below ---------------------------------------------
        cd /opt
        OCTAVE_MPI_DIR="octave-mpi"
        git clone https://github.com/carlodefalco/octave-mpi.git $OCTAVE_MPI_DIR
        cd $OCTAVE_MPI_DIR
        git checkout d220cdd824cb6f757a6af513ee470a8e60a14153
        rm -rf .git
        cd ../
        tar czf "$OCTAVE_MPI_DIR.tar.gz" $OCTAVE_MPI_DIR
        rm -rf $OCTAVE_MPI_DIR
        octave --no-gui --no-window-system --eval "pkg install -global octave-mpi.tar.gz"
        # ----------------------------------------------------------------------
    fi
fi

# -----> Ray
if [ "$LIB_RAY" = "TRUE" ] ; then
    pip3 install ray
fi

# -----> Python
if [ "$LANG_PYTHON3" = "TRUE" ] && [ "$LIB_OPENMPI" = "TRUE" ] ; then
    source /etc/profile.d/modules.sh
    module load mpi/openmpi-x86_64
    pip3 install mpi4py # https://mpi4py.readthedocs.io/en/stable/install.html
fi

# -----> Theia
if [ "$DEV_THEIA" = "TRUE" ] && [ "$LANG_PYTHON3" = "TRUE" ] ; then
    pip3 install pylint
fi

# -----> VS Code (VNC Patch: https://github.com/microsoft/vscode/issues/3451 )
if [ "$DEV_VSCODE" = "TRUE" ] ; then  
    # create modified libraries
    mkdir -p /opt/vscode/lib64
    cp /usr/lib64/libxcb.so.1 /opt/vscode/lib64
    sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /opt/vscode/lib64/libxcb.so.1 
    cp /usr/lib64/libxcb.so.1.1.0 /opt/vscode/lib64
    sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /opt/vscode/lib64/libxcb.so.1.1.0 
    # create launcher
    echo 'bash -c "LD_PRELOAD=/opt/vscode/lib64/libxcb.so.1:/opt/vscode/lib64/libxcb.so.1.1.0 /usr/share/code/code $@"' > /opt/vscode/code
    chmod a+x /opt/vscode/code
    # update user bash
    echo 'alias code="/opt/vscode/code"' >> /home/user/.bashrc
    # update application launchers
    replaceConfigFileParam "/usr/share/applications/code.desktop" "Exec" "/opt/vscode/code --no-sandbox --unity-launch %F"
    replaceConfigFileParam "/usr/share/applications/code-url-handler.desktop" "Exec" "/opt/vscode/code --no-sandbox --unity-launch %F"
fi

# -----> Slurm
if [ "$ASW_SLURM" = "TRUE" ] ; then
    groupadd slurm
    useradd -g slurm slurm
    mkdir -p /var/log/slurm /var/spool/slurm /run/slurm
    chown -R slurm: /var/log/slurm
    chown -R slurm: /var/spool/slurm
    chown -R slurm: /run/slurm
fi

# ----> VNC
if [ "$ASW_VNC" = "TRUE" ] ; then
    # overwrite legacy script /usr/bin/vncserver
    cp /opt/build-scripts/extras/{vncserver,pyvncconfig} /usr/bin/
    chmod a+x /usr/bin/{vncserver,pyvncconfig}
    # install regex package required by configvnc.py
    pip3 install regex
    # remove power manager services (which cause problems in containers)
    dnf remove -y xfce4-power-manager
fi 

# clear all dnf caches
dnf clean all