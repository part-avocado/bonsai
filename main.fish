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
    printf '\e[?25h\e[?1049l'
end

# place in form (x,y, string)
function place 
    printf '\e[%d;%dH%b' (math $OY + 1 + $argv[2]) (math $OX + 1 + 2 \* $argv[1]) $argv[3]
end

function say
    printf '\e[%d;%dH%b' $argv[1] $argv[2] $argv[3]
end

function keydown
    dd bs=8 count=1 2>/dev/null | string collect -N
end

function waitkey
    while true
        set -l k (keydown)
        test -n "$k"; and echo -n $k; and return 
    end
end

function drawscore
    say (math $OY + $H +2) $OX "Score \e[1m$score$C_D Best \e[1m$best$C_D"
end

function drawframe
    printf '\e[2J'
    set -l bar (string repeat -n (math 2 \* $W) =)
    say $OY $OX "$C╔$bar╗$C_D"
    for n in (seq 1 $H)
        say (math $OY + $n) $OX "$C║$C_D"
        say (math $OY + $n) (math $OX + 2 \* $W +1) "$C║$C_D"
    end
    say (math $OY + $H +1) $OX "$C╚$bar╝$C_D"
    say (math $OY -1) $OX "\e[1;38;5;118m SNAKE $C_D"
end

function placefood
    while true
        set -g fx (random 0 (math $W - 1))
        set -g fy (random 0 (math $H - 1))
        set -l hit 0
        for i in (seq (count $sx))
            if test $sx[$i] -eq $fx -a $sy[$i] -eq $fy
                set hit 1
                break
            end
        end
        test $hit -eq 0; and break
    end
    place $fx $fy "$C()$C_D"
end

function play
    set -g sx 14 13 12
    set -g sy 7 7 7
    set -g dir right
    set -g score 0
    drawframe
    for i in (seq (count $sx))
        place $sx[$i] $sy[$i] "$C██$C_D"
    end
    placefood
    drawscore

    while true
        set -l key (keydown)
        set -l want $dir
        switch $key
            case w W \e\[A
                set want up
            case a A \e\[D
                set want left
            case s S \e\[B
                set want down
            case d D \e\[C
                set want right
            case q Q
                return 1
        end

        switch "$want$dir"
            case updown downup leftright rightleft

            case '*'
                set dir $want
        end

        set -l nx $sx[1]
        set -l ny $sy[1]
        switch $dir
            case up
                set ny (math $ny -1)
            case down
                set ny (math $ny +1)
            case left
                set nx (math $nx -1)
            case right
                set nx (math $nx +1)
        end

        set -l dead 0
        if test $nx -lt 0 -o $nx -ge $W -o $ny -lt 0 -o $ny -ge $H
            set dead 1
        else
            for i in (seq (math (count $sx) -1 ))
                if test $sx[$i] -eq $nx -a $sy[$i] -eq $ny
                    set dead 1
                    break
                end
            end
        end

        if test $dead -eq 1
            test $score -gt $best; and set -g best $score
            set -l row (math "$OY +1 +floor($H /2)")
            set -l col (math $OX + $W - 8)
            say (math $row -1) $col "\e[1;37;41m                 $C_D"
            say $row $col           "\e[1;37;41m    GAME  OVER   $C_D"
            say (math $row +1) $col "\e[1;37;41m    [r] Retry    $C_D"
            say (math $row +2) $col "\e[1;37;41m     [q] Quit    $C_D"
            return 0
        end

        set -g sx $nx $sx
        set -g sy $ny $sy

        if test $nx -eq $fx -a $ny -eq $fy
            set -g score (math $score +1)
            placefood
            drawscore
        else
            place $sx[-1] $sy[-1] "  "
            set -e sx[-1]
            set -e sy[-1]
        end
        place $nx $ny "$C██$C_D"
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
    while true
        switch (waitkey)
            case r R
                break
            case q Q
                exit 0
        end
    end
end