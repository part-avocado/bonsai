#!/usr/bin/env fish

# game size declarations
set -g W 28
set -g H 15

# offset such that sides do not run off screens
set -g OX 3
set -g OY 2

set -g C '\e[0;92m'
set -g C_D '\e[0m'

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

function drawscore
    say (math +$OY + $H +2) $OX "Score \e[1m$score$C_D Best \e[1m$best$C_D"
end

function drawframe
    printf '\e[2J'
    set -l bar (string repeat -n (math 2 \* $W) =)
    say $OY $OX "$C╔$bar╗$C_D"
    for n in (seq 1 $H)
        say (math $OY + $y) $OX "$C║$C_D"
        say (math $OY + $y) (math $OX + 2 \* $W +1) "$C║"
    end
    say (math $OY + $H +1) $OX "$C╚$bar╝$C_D"
    say (math $OY -1) $OX "\e[1;38;5;118m SNAKE $C_D"
end

function play
    set -g sx 14 13 12
    set -g sy 7 7 7
    set -g dir right
    set -g score 0
    drawframe
    for i in (seq (count $sx))
        put $sx[$i] $sy[$i] "$C██$C_D"
    end
    
end

# main run
printf '\e[?1049h\e[?25l'
stty -echo -icanon min 0 time 1
printf '\e[2J'

say 5 8 "\e[1;38;5;118m SNAKE \e[0m"
say 11 9 "press any key to start"
waitkey >/dev/null

while true
    play
    test $status -eq 1; and break
    while true:
        switch (waitkey)
            case r R
                break
            case *
                exit 0
        end
    end
end