#!/bin/bash

#region Configuration
USE_WHILE=0
RUN_CMD="./vuln_app"
CAN_IFACE="vcan0"
INPUT_TMUX_WIN=1 #0 program STDIN / 1 others
#endregion

#region Locals
tmux_ses="DV_OT_APP"
INPUTS=(
    DEADBEEFCAFEBABE # does not pass size check
    03ADBEEFCAFEBABE # passes size check but does not pass dma code check
    12ADBEEFCAFEBABE # size check crash
    0323BEEFCAFEBABE # passes size check, dma code crash
)
#endregion

#region Build

t_make(){
    local selfdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    local DF=
    if [ $USE_WHILE -eq 1 ];then
        DF+=" -DWHILE"
    fi

    (
        cd "$selfdir" && make DFLAGS="$DF"
    )
}

t_make_clean(){
    local selfdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    (
        cd "$selfdir" && make clean
    )
}
#endregion

#region Run
_t_send_input__input_data(){
    local id=18FEF100
    if [ $USE_CAN -eq 1 ];then
        echo "cansend $CAN_IFACE $id#$1"
    fi
    if [ $USE_STDIN -eq 1 ];then
        echo "$1" | cut -c3-
    fi
}

t_run(){
    (set -ue
    
    trap "tmux kill-session -t $tmux_ses" EXIT

    cd "$P"
    
    #~ Check environment
    if [[ "$(ifconfig $CAN_IFACE 2>&1)" == *"Device not found"* ]];then
        echo "Create"
        sudo ip link add dev $CAN_IFACE type vcan
        sudo ifconfig $CAN_IFACE up
        ifconfig $CAN_IFACE
    fi

    #~ Init Tmux
    tmux new -d -s "$tmux_ses"
    tmux split-window -l10%
    # tmux send -t 0 "source $HFUZZ_API_PATH" "Enter"
    tmux send -t 0 "$RUN_CMD" "Enter"

    #~ Send input
    for inp in "${INPUTS[@]}"
    do
        sleep 0.5
        tmux send -t $INPUT_TMUX_WIN "$(_t_send_input__input_data $inp)" "Enter"

        if [ "$inp" != "${INPUTS[-1]}" ]; then
            if [ $USE_WHILE -eq 0 ];then
                tmux send -t 0 "$RUN_CMD" "Enter"
            else
                if [[ ! $(pgrep -f $B) ]]; then
                    tmux send -t 0 "$RUN_CMD" "Enter"
                fi
            fi
        fi
    done

    #~ Finish Tmux
    tmux attach-session -t "$tmux_ses"
    tmux kill-session -t "$tmux_ses"

    set +ue
    )
}

#endregion

#endregion