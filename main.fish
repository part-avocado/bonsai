#!/usr/bin/env fish

# game size declarations
set -g W 28
set -g H 15

# offset such that sides do not run off screens
set -g OX 3
set -g OY 2

set -g C '\e[0;92m'

set -g best 0
set -g type (stty -g)

function clean --on-event fish_exit
    stty $type 2>/dev/null
end

# place in form (x,y, string)
function place 
    printf '\e[%d;%dH%b' (math $OY + 1 + $argv[2]) (math $OX + 1 + 2 \* $argv[1]) $argv[3]
end

function keydown
    dd bs=8 count=1 2>/dev/null | string collect -N
end

function waitkey
    while true
        set -l k (readkey)
        test -n "$k"; and echo -n $k; and return 
    end
end

