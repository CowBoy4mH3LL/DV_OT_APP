# DV OT APP
Or Damn Vulnerarble OT App

## Overview
* Currently reads from CAN and parses data
* There is a stack buffer overflow and a invalid free vulnerability upon parsing

## Dependencies
### Tmux
Get it installed `sudo apt install tmux`
Best if the following is put in `~/.,tmux.conf`: 
    ```
    bind-key -n C-u detach-client
    set -g mouse on
    set -g default-terminal "screen-256color"
    ```

### CAN-utils
Get installed `sudo apt install can-utils`
We do use `cansend` for a basic test

### More?
Report, PR,...    
Follow the errors for now, we can "discuss" my experience if needed



