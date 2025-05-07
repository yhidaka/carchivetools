# To allow usage of the latest conda / mamba installed by D. Hidas
__conda_setup="$('/nsls2/software/ap/rh92/apps/miniconda/py310_23.1.0-1/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/nsls2/software/ap/rh92/apps/miniconda/py310_23.1.0-1/etc/profile.d/conda.sh" ]; then
        . "/nsls2/software/ap/rh92/apps/miniconda/py310_23.1.0-1/etc/profile.d/conda.sh"
    else
        export PATH="/nsls2/software/ap/rh92/apps/miniconda/py310_23.1.0-1/bin:$PATH"
    fi
fi
unset __conda_setup
