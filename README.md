# Overview
The purpose of this image is to provide developers with a consistent set of common OS-agnostic dev tools, in case these are done from the local developer's machine (unlike specialized builds done via CI, for example)

# Setup

* Install docker for desktop (Windows/Mac) on the local host

* Setup DEVCMD_ROOT environment variable to the folder where all DEVCMD repos are cloned, e.g. /home/myuser/dev or C:\Users\MyUser\dev

* Add the following to the PATH environment variable:
  * Linux/Mac: add `export PATH=$PATH:$DEVCMD_ROOT/devcmd` to the end of `~/.bash_profile`
  * Windows: add a `%DEVCMD_ROOT%\devcmd` entry to the end of the `Path` variable under the User Environment Variables (Windows)

* Optional: Download your GCP API key into `<DEVCMD_ROOT>/sec` folder (ask your manager for key access if needed)

* Build the `devcmd` image if needed:
  ```
  # Mac/Linux:
  cd $DEVCMD_ROOT/devcmd
  devcmd stop
  devcmd build

  # windows:
  cd %DEVCMD_ROOT%/devcmd
  devcmd stop
  devcmd build
  ```

# Usage

From a new terminal:

* To connect to the existing container while creating a new one if missing with a specific dev env config (default=dev):
  ```
  devcmd [dev|stage|prod]
  ```
  Notes:
  * Your DEVCMD_ROOT folder is available under `/code` in the container
  * The container shares your host's .gitconfig so any git commands from the container can seamlessly access git as if called on the host
  * On Linux/Mac, the new shell uses the same uid/gid as on the host and maps a volume from `$HOME` on the host to `/home/$USER` in the container
  * Docker CLI is available from within the container, it connects to the host's Docker runtime
  * If the container is not running, one will be created
  * If the container is already running, a new shell opens in the same container.
  The new shell does not reconfigure the container. It shares configuration with other shells
  (except for terminal-specific state of course)
  * The container remains detached so you can later quickly open more shells on it

* From within the container, switch cloud envs (zero arguments to watch current):
  ```
  devcmd-env [dev|stage|prod]
  ```

* To remove & stop any existing devcmd container on the host:
  ```
  devcmd stop
  ```
