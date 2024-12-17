#!/bin/bash
V=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#region Settings
USE_WHILE=0 # Whether in server mode
RUN_CMD="$V/vuln_app" # Run command
STDIN_ONLY=1 # Only STDIN as the input
CAN_IFACE="vcan0" # CAN interface name
INPUTS=(
    DEADBEEFCAFEBABE # does not pass size check
    03ADBEEFCAFEBABE # passes size check but does not pass dma code check
    12ADBEEFCAFEBABE # size check crash
    0323BEEFCAFEBABE # passes size check, dma code crash
)
TMUX_SES="DV_OT_APP" # Tmux session
INTER_RUN_SLEEP=1 #seconds
#endregion

v_build(){
    (
        set -eu
        #set -x
        DF=
        if [ $USE_WHILE -eq 1 ];then
            DF+=" -DWHILE"
        fi
        if [ $STDIN_ONLY -eq 1 ];then
            DF+=" -DSTDIN_ONLY"
        fi
        echo "DF = $DF"
        cd "$V"
        echo "$DF" > env.tmp
        diff -q env.txt env.tmp || cp env.tmp env.txt
        # rm -f env.tmp

        mkdir -p ./objects
        make DFLAGS="$DF"
    )
}

v_clean(){
    (
        cd "$V" && make clean
    )
}

_v_send_input__input_data__channel(){
    # channel: 0: stdin, 1: can
    local id=18FEF100
    if [ $2 -eq 1 ];then
        echo "cansend $CAN_IFACE $id#$1"
    else
        python3 -c "print(''.join(reversed(['$1'[i:i+2] for i in range(0, len('$1'), 2)])))"
        # echo $1
    fi
}

v_run(){
    (
        #~ Check environment
        if [[ "$(ifconfig $CAN_IFACE 2>&1)" == *"Device not found"* ]];then
                echo "Create"
                sudo ip link add dev $CAN_IFACE type vcan
                sudo ifconfig $CAN_IFACE up
                ifconfig $CAN_IFACE
        fi

        set -ueE
    
        trap "tmux kill-session -t $TMUX_SES; echo 'Please v_run again'" ERR

        cd "$V"

        #~ Init Tmux
        tmux -f "$V/tmux.conf" new -d -s "$TMUX_SES"
        tmux split-window -l10%


        #~ Determine input information
        local INPUT_TMUX_WIN=0
        if [ $STDIN_ONLY -ne 1 ];then
            INPUT_TMUX_WIN=1
        fi
        local INPUT_CHANNEL=0
        if [ $STDIN_ONLY -ne 1 ];then
            INPUT_CHANNEL=1
        fi

        #~ Send input to process
        for inp in "${INPUTS[@]}"
        do
            echo "Trying input $inp"
            echo "Running with $RUN_CMD"
            pgrep -f vuln_app || tmux send -t 0 "$RUN_CMD" "Enter"
            sleep $INTER_RUN_SLEEP
            tmux send -t $INPUT_TMUX_WIN "$(_v_send_input__input_data__channel $inp $INPUT_CHANNEL)" "Enter"
            sleep $INTER_RUN_SLEEP # Wait for the process to die if it crashes
        done

        #~ Finish Tmux
        tmux attach-session -t "$TMUX_SES"
        tmux kill-session -t "$TMUX_SES"

    )
}
