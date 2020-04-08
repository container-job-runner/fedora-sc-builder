# stack-fedora-basic
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/gitbucket/gitbucket/blob/master/LICENSE)

A cjr stack based on Fedora and dnf.

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
To configure the software list see [the customization section](#Customization) below.

## Description

This stack creates a non-root user with matching user id and group id as the host user, and uses dnf to install basic support for any subset of the following:

1. **Languages**
   - c, c++
   - Fortran
   - Python 3
   - Julia
   - R
   - latex
2. **Libraries**
   - Matplotlib
   - BLAS, LAPACK
   - OPENMPI
3. **dev environments**
   - Jupyter notebook, Jupyter lab
   - Theia IDE
   - vim, git, vim, emacs, tmux
4. **Package Managers**
   - spack

Note: configuration for Jupyter is stored in a bound folder inside the stack directory.

## Customization

**By default this stack does not install any dependencies**. By editing the args in config.yml and setting fields to `TRUE` you can enable any of the items listed above. For example, by changing the following fields in config.yml
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
# ---- dev enviroment ------------------------------------------------------
DEV_JUPYTER: "TRUE"
DEV_THEIA: "FALSE"
DEV_CLI: "FALSE"
```
the stack will contain basic language dependencies for c, c++, python, the matplotlib library and Jupyter. Note that after changing the params you will need to rebuild the stack (e.g. `cjr stack:build stack-fedora-basic`)

Additional dependencies can be installed by modifying the files
- build-scripts/root_install_extra.sh
- build-scripts/user_install_extra.sh

To modify the package install process, modify the files
- build-scripts/root_install.sh
- build-scripts/user_install.sh

Finally, the non-root user's username, password, and sudo privileges can be modified by adjusting the user args in config.yml
