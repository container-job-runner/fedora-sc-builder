# stack-fedora-basic
A cjr stack based on Fedora and dnf

## Installation

To use use this stack with cjr simply run the command
`cjr stack:pull https://github.com/container-job-runner/stack-fedora-basic.git`
or manually clone the repository into your cjr stacks directory.

## Description

This stack creates a non-root user with matching id and groupid as host user,  
and uses dnf to install basic support for any subset of the following:

1. **Languages**
  - c, c++
  - Fortran
  - Python 3
  - Julia
  - R
  - latex
2. **Libraries**
  - matplotlib
  - BLAS, LAPACK
  - OPENMPI
3. **dev environments**
  - jupyter notebook, jupyter lab
  - vim,
4. **Package Managers**
  - spack

## Customization

**By default this stack does not install any dependencies**. By editing the args in config.yml and setting fields to `TRUE` you can enable any of the items listed above. After changing the params you will need to rebuild the stack (e.g. `cjr stack:build stack-fedora-basic`)

Additional dependencies can be installed by modifying the files
- build-scripts/root_install_extra.sh
- build-scripts/user_install_extra.sh

To modify the package install process, modify the files
- build-scripts/root_install.sh
- build-scripts/user_install.sh

Finally, username, password, and sudo privileges can be modified by adjusting the user args in config.yml
