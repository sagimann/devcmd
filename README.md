# Overview
Provide developers with a consistent set of common local OS-agnostic environment, dev command lines and libraries.
Developers can use it as a reference implementation or base for project-specific images.

# Setup

* Install docker for desktop (Windows/Mac) on the local host

* Setup DEVCMD_ROOT environment variable to the folder where your project repos are cloned, e.g. /home/myuser/dev or C:\Users\MyUser\dev

* Add the following to the PATH environment variable:
  * Linux/Mac: add `export PATH=$PATH:$DEVCMD_ROOT/devcmd` to the end of `~/.bash_profile`
  * Windows: add a `%DEVCMD_ROOT%\devcmd` entry to the end of the `Path` variable under the User Environment Variables (Windows)

* Build the `devcmd` image if needed (do this every time to change the image):
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

* Optional: Add env-specific environment variables under `$DEVCMD_ROOT/.devcmd/<env>.env` (default env is `local`) to make them available in your DEVCMD shell.
  See `devcmd.env.example`

* Optional: configure your GCP service account:
  * Add/link your GCP API service account file(s) under `$DEVCMD_ROOT/.devcmd` e.g. `<DEVCMD_ROOT>/prod/gcp.json`
  * Add `DEVCMD_GCP_KEY=<path_to_json>`, `DEVCMD_GCP_PROJECT_ID=<gcp_project_id>` in the appropriate .env files above

* To connect to the existing container while creating a new one if missing with a specific dev env config (default=local):
  ```
  devcmd [local|dev|stage|prod|...]
  ```
  Notes:
  * Includes: Python 3.12, NVM with Node.js 22
  * Your DEVCMD_ROOT folder is available under `/code` in the container. The `DEVCMD_ROOT` env variable in the container points to it
  * The selected environment is available in the `DEVCMD_ENV` env variable
  * A temporary folder, mapped to `$DEVCMD_ROOT/temp` on the host (created if missing) is available as `DEVCMD_TEMP` env variable in the container
  * The `IS_DEVCMD` env variable is `true` if running inside the DEVCMD container
  * The prompt always shows the time-of-day - an easy way to check command execution duration
  * The container shares your host's .gitconfig so any git commands from the container can seamlessly access git as if called on the host
  * On Linux/Mac, the new shell uses the same uid/gid as on the host and maps a volume from `$HOME` on the host to `/home/$USER` in the container
  * Docker CLI is available from within the container, it connects to the host's Docker runtime
  * If the container is not running, one will be created
  * If the container is already running, a new shell opens in the same container.
  The new shell does not reconfigure the container. It shares configuration with other shells
  (except for terminal-specific state of course)
  * The container remains detached so you can later quickly open more shells on it

* To remove & stop any existing devcmd container on the host:
  ```
  devcmd stop
  ```
