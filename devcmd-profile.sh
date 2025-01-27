if [ -z "$DEVCMD_ENV" ]; then DEVCMD_ENV=local; fi

export PROMPT_COMMAND="echo -n \[\$(date +%H:%M:%S) \| $DEVCMD_ENV\]\ "

devcmd_config="$DEVCMD_ROOT/.devcmd/$DEVCMD_ENV.env"
if [ -f "$devcmd_config" ]; then
    echo "Using config vars: $devcmd_config"
    set -o allexport
    . "$devcmd_config"
    set +o allexport
else
    echo "Note: DEVCMD vars for the '$DEVCMD_ENV' env can be added at: $devcmd_config"
fi

