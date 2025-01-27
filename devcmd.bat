@echo off
setlocal EnableDelayedExpansion 
set container_name=devcmd

if "%DEVCMD_ROOT%" == "" (
    echo Error: DEVCMD_ROOT environment variable is not defined
    exit /B 1
)

set code_vol=/%DEVCMD_ROOT::\=/%
set code_vol=!code_vol:\=/!
set home_vol=/%USERPROFILE::\=/%
set home_vol=!home_vol:\=/!
set devcmd_vol=%~dp0
set devcmd_vol=/!devcmd_vol::\=/!
set devcmd_vol=!devcmd_vol:\=/!

if "%1" == "build" (
    echo Building image...
    docker build -t !container_name! -f !container_name!.dockerfile .
) else if "%1" == "stop" (
    echo Stopping any existing container...
    call :stop_container
) else if "%1" == "start" (
    docker ps | findstr "!container_name!" > nul 2>&1
    if errorlevel 1 (
        echo Starting container...
        call :stop_container
        @REM https://tomgregory.com/running-docker-in-docker-on-windows
        docker run --name "!container_name!" ^
            --restart always ^
            -e "HOST_USER=%USERNAME%" ^
            -e "HOST_DEVCMD_ROOT=!code_vol!" ^
            -e "DEVCMD_ENV=%2" ^
            -v //var/run/docker.sock:/var/run/docker.sock ^
            -v !code_vol!:/code ^
            -v !home_vol!:/home/%USERNAME% ^
            -v !devcmd_vol!:/opt/devcmd ^
            -p 8080:8080 ^
            -d -it "!container_name!" %2
    ) else (
        echo Container already running
    )
) else (
    docker ps | findstr "!container_name!" > nul 2>&1
    if errorlevel 1 (
        set devenv=%1
        if "!devenv!" == "" (
            set devenv=local
        )
        call :stop_container
        devcmd start !devenv!
        devcmd
    ) else (
        echo Entering existing container...
        docker exec ^
            -it ^
            -e "HOST_USER=%USERNAME%" ^
            -e "HOST_DEVCMD_ROOT=!code_vol!" ^
            -e "DEVCMD_ENV=%1" ^
            "!container_name!" ^
            bash --login
    )
)
exit /B %ERRORLEVEL%

:stop_container
docker container rm -f "!container_name!" > nul 2>&1
exit /B 0
