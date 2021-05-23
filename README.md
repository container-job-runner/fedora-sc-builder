# fedora-sc-builder
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/gitbucket/gitbucket/blob/master/LICENSE)

A cjr stack for scientific computing based on Fedora and dnf. This stack is used to build images for the fedora-sc stack. It can also be used as a highly customizable standalone stack.

## Description

This stack creates a non-root user with matching user id and group id as the host user, and uses dnf to install basic support for any subset of the following:

1. **Languages**
   - c, c++
   - Fortran
   - Python 3
   - Julia
   - R
   - Latex
2. **Libraries**
   - Matplotlib
   - Ray (*Temporarily Disabled*)
   - BLAS, LAPACK
   - OPENMPI, mpi4py
   - X11
3. **Dev Environments**
   - Jupyter notebook, Jupyter lab
   - Theia
   - vim, git, vim, emacs, tmux
4. **Additional Software**
   - spack
   - tigervnc
   - slurm
   - sshd

The configurations for Jupyter and Theia are respectively stored the directories config/jupyter and config/theia which are bound to ~/.jupyter and ~/.theia in the container.

## Installation

To use use this stack with cjr simply run the command
```console
cjr stack:pull https://github.com/container-job-runner/stack-fedora-basic.git
```
or manually clone the repository into your cjr stacks directory.

You can then build the stack by running
```console
cjr stack:build stack-fedora-basic
```
**By default this stack does not install any dependencies**. To configure the software list see the following [customization](#Customization) section.

## Customization

By editing the args in config.yml and setting fields to `TRUE` you can enable any of the items listed above. For example, by changing the following fields in config.yml
```yaml
# ---- languages -----------------------------------------------------------
LANG_C: "TRUE"
LANG_FORTRAN: "TRUE"
LANG_PYTHON3: "TRUE"
LANG_JULIA: "FALSE"
LANG_R: "FALSE"
LANG_LATEX: "FALSE"
# ---- libraries -----------------------------------------------------------
LIB_MATPLOTLIB : "TRUE"
LIB_LINALG : "FALSE"
LIB_OPENMPI: "FALSE"
LIB_X11: "FALSE"
# ---- dev enviroment ------------------------------------------------------
DEV_JUPYTER: "TRUE"
DEV_THEIA: "FALSE"
DEV_CLI: "FALSE"
# ---- additional software -------------------------------------------------
ASW_SPACK: "FALSE"
ASW_VNC: "FALSE"
```
the stack will contain basic language dependencies for c, c++, python, the matplotlib library and Jupyter. Note that after changing the params you will need to rebuild the stack (e.g. `cjr stack:build stack-fedora-basic`)

Additional dependencies can be installed by modifying the files
- build/scripts/root/install-extra.sh
- build/scripts/user/install-extra.sh

To modify the main package install process, modify the files
- build/scripts/root/install.sh
- build/scripts/user/install.sh

**Profiles**: This stack contains the following profiles:

- all : installs everything.
- reference: used to build official cjr fedora-sc image
- *LANGUAGE-IDE* where LANGUAGE can be either 'fortran', 'python', or 'julia' and IDE can be 'jupyter' or 'theia'.
- *LANGUAGE* where LANGUAGE can be either 'c', 'fortran', 'python', 'julia', or 'octave'

**Theia Plugins**:
Additional plugins can be installed by adding .vsix extension files to the directory config/theia/plugins. Note that Theia does not yet support all vs code extensions correctly, especially the latest versions. Several recommended extensions and their versions are:

- *Python*: [vscode-python](https://github.com/microsoft/vscode-python), version [2020.10.332292344](https://github.com/microsoft/vscode-python/releases/tag/2020.10.332292344).
- *Julia*: [julia-vscode](https://github.com/julia-vscode/julia-vscode), version [0.15.40](https://github.com/julia-vscode/julia-vscode/releases/tag/v0.15.40).
- *C/C++*: [vscode-cpptools](https://github.com/Microsoft/vscode-cpptools), version [0.28.3](https://github.com/microsoft/vscode-cpptools/releases/tag/0.28.3).
- *Fortran*: [Modern Fortran](https://github.com/krvajal/vscode-fortran-support), version [2.2.1](https://marketplace.visualstudio.com/items?itemName=krvajalm.linter-gfortran). (Requires vscode-cpptools)

**User Settings**: 
The container user's username, password, and sudo privileges can also be modified by adjusting the user args in config.yml