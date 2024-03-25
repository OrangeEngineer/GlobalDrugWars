#!/bin/bash
# License: GPLv3
# A Terminal Based Strategy Game
# Heavily based on a game by John E. Dell 1984, who was ahead of his time.
# By A. J. S. (2019)


GAMEDATE () { # true to original date, format is MM / DD / YYYY
    echo $(date --date=" 4 Dec 1983 +"$1" days" +"%m / %d / %y")
}

ROLLPRICES () { # this happens at the start of the game and whenever you jet
    CPRICE=$(( $(shuf -n1 --input-range=1200-1800) * 10 ))
    HPRICE=$(( $(shuf -n1 -i1000-1500) * 10 ))
    FPRICE=$(( $(shuf -n1 -i600-900) * 10 ))
    WPRICE=$(( $(shuf -n1 -i400-600) * 10 ))
    SPRICE=$(( $(shuf -n1 -i80-400) * 10 ))
    LPRICE=$(( $(shuf -n1 -i40-100) * 10 ))
}


TERMINFO () { # terminal based GUI to keep it old school; the WIDTH, WID, WI, W are just shorthand measurements to print blank spaces
    clear -x
    WIDTH=$(tput cols)
    HEIGHT=$(tput lines)
    let WID=WIDTH/2
    let HEI=HEIGHT/2
    let WI=WIDTH/4
    let HE=HEIGHT/4
    let W=WIDTH/8
    let H=HEIGHT/8
}

RESETVALUES () { # initialize the game values
    DAY=0

    GEO=NEWYORK
    CASH=5000
    GUNS=0
    BANK=0
    DEBT=10000
    MAXLOAN=20000
    HOLD=100

    SCOCAINE=0
    SHEROIN=0
    SFENTANYL=0
    SMETH=0
    SLSD=0
    SWEED=0

    TCOCAINE=0
    THEROIN=0
    TFENTANYL=0
    TMETH=0
    TLSD=0
    TWEED=0

    STATE=begin
    HEALTH=100
    COPS=0
}

### ROLL INITIAL VALUES ###
    TERMINFO
    RESETVALUES
    ROLLPRICES
###########################

US () { # print underscores
    printf '%0.s_' $(seq 1 $1)
}

SP () { # print space
    printf '%0.s ' $(seq 1 $1)
}

BLOCKS () { # print BLOCKS
    printf '%0.s█' $(seq 1 $1)
}

DSP () { # print space for the products
    case $1 in
        C ) space=$((WID-W-9-${#SCOCAINE}))
            ;;
        H ) space=$((WID-W-10-${#SHEROIN}))
            ;;
        A ) space=$((WID-W-12-${#SFENTANYL}))
            ;;
        W ) space=$((WID-W-12-${#SMETH}))
            ;;
        S ) space=$((WID-W-11-${#SLSD}))
            ;;
        L ) space=$((WID-W-11-${#SWEED}))
            ;;
        B ) space=$((WID-W-13-${#BANK}))
            ;;
        D ) space=$((WID-W-13-${#DEBT}))
            ;;
        HEALTH ) space=$((WID-W-13-${#HEALTH}))
            ;;
        COPS ) space=$((WID-W-11-${#COPS}))
            ;;
    esac

    printf '%0.s ' $(seq 1 $space)
}

STARTGAME () {
    TERMINFO
    STARTMSG=""$(cat << EOF


$(SP $((WID-5)))DRUG WARS

$(SP $((WID-8)))A GAME BASED ON

$(SP $((WID-12)))THE NEW YORK DRUG MARKET


$(SP $((WID-15)))ORIGINAL BY JOHN E. DELL (1984)

$(SP $((WID-15)))BOURNE AGAIN BY A. J. S. (2019)

$(SP $((WID-13)))UPDATE BY NATCH_69 (2024)

EOF
    )""
    cat <<< $STARTMSG
    echo
    SP $((WID-13))
    read -p "Enter your username:" USERNAME

    save_status "$USERNAME"
    load_status "$USERNAME"
    echo

    SP $((WID-13))
    read -n1 -p "DO YOU WANT INSTRUCTIONS? "
    if [[ $REPLY = [y/Y] ]]; then
        INSTRUCTIONS
    else
        MAINMENU
    fi
}

INSTRUCTIONS () {
    TERMINFO
    INSTRUCTIONS=""$(cat << EOF


$(SP $((WID-20)))DRUG WARS
$(SP $((WID-20)))This is a game of buying, selling, and
$(SP $((WID-20)))fighting. The object of the game is to
$(SP $((WID-20)))pay off your debt to the loan shark.
$(SP $((WID-20)))Then, make as much money as you can in a
$(SP $((WID-20)))1 month period. If you deal too heavily
$(SP $((WID-20)))in  drugs,  you  might  run  into  the
$(SP $((WID-20)))police $(echo '!!')  Your main drug stash will be
$(SP $((WID-20)))in NEW YORK.
$(SP $((WID-20)))The prices of drugs per unit are:
$(SP $((WID-20)))
$(SP $((WID-20)))      COCAINE     15000-30000
$(SP $((WID-20)))      HEROIN      5000-14000
$(SP $((WID-20)))      FENTANYL        1000-4500
$(SP $((WID-20)))      METH        300-900
$(SP $((WID-20)))      LSD       70-250
$(SP $((WID-20)))      WEED       10-60
$(SP $((WID-20)))
$(SP $((WID-20)))    (HIT ANY KEY TO START GAME)

EOF
    )""
    cat <<< $INSTRUCTIONS
    echo
    read -n1 -p ""
        MAINMENU
}

save_status() {
    USER_FILE="${1}_status.txt"  # The user's status file
    cat << EOF > "$USER_FILE"
DAY=$DAY
GEO=$GEO
CASH=$CASH
GUNS=$GUNS
BANK=$BANK
DEBT=$DEBT
MAXLOAN=$MAXLOAN
HOLD=$HOLD
SCOCAINE=$SCOCAINE
SHEROIN=$SHEROIN
SFENTANYL=$SFENTANYL
SMETH=$SMETH
SLSD=$SLSD
SWEED=$SWEED
TCOCAINE=$TCOCAINE
THEROIN=$THEROIN
TFENTANYL=$TFENTANYL
TMETH=$TMETH
TLSD=$TLSD
TWEED=$TWEED
STATE=$STATE
HEALTH=$HEALTH
COPS=$COPS
EOF
    echo "Status saved for user: $1"
    echo "Saved status for user: $1 on $(date)" >> game_log.txt
}

load_status() {
    USER_FILE="${1}_status.txt"  # The user's status file
    if [ -f "$USER_FILE" ]; then
        source "$USER_FILE"
        echo "Status loaded for user: $1"
        echo "Loaded status for user: $1 on $(date)" >> game_log.txt
    else
        echo "No saved status found for user: $1"
        echo "Attempted to load status for user: $1 on $(date)" >> game_log.txt
    fi
}



HUD () {  # HUD (Heads Up Display) shows the stash and coat values and is also a function and a variable
    TERMINFO
    # insert varying space depending on terminal window size
    SPW="$(SP $W)"

    HUD=""$(cat << EOF

${SPW}DATE $(GAMEDATE $DAY)$(SP $((WID-8)))HOLD    $HOLD
${SPW}$(SP $((WID+4)))     HEALTH   $HEALTH 
${SPW}STASH$(SP $((WID-W-5-$((${#GEO}/2)))))$GEO$(SP $((W-$((${#GEO}/2)))))TRENCHCOAT
$(US $WIDTH)
${SPW}COCAINE $SCOCAINE$(DSP C) |${SPW}COCAINE $TCOCAINE
${SPW}HEROIN  $SHEROIN$(DSP H)  |${SPW}HEROIN  $THEROIN
${SPW}FENTANYL    $SFENTANYL$(DSP A)    |${SPW}FENTANYL    $TFENTANYL
${SPW}METH    $SMETH$(DSP W)    |${SPW}METH    $TMETH
${SPW}LSD   $SLSD$(DSP S)   |${SPW}LSD   $TLSD
${SPW}WEED   $SWEED$(DSP L)   |${SPW}WEED   $TWEED
$(SP $((WID-1))) |
${SPW}BANK    $BANK$(DSP B)     |${SPW}GUNS    $GUNS
${SPW}DEBT    $DEBT$(DSP D)     |${SPW}CASH    $CASH
$(US $WIDTH)
EOF
    )""
    cat <<< $HUD
    echo
}


SHOWPRICES () {  # displays the current prices, changes when ROLLPRICES () happens
    SPWI="$(SP $WI)"
    SHOWPRICES=""$(cat << EOF # $(SP $W)
HEY DUDE, THE PRICES OF DRUGS HERE ARE:

${SPWI}COCAINE    $CPRICE$(SP $((WID-WI-11-${#CPRICE})))METH       $WPRICE
${SPWI}HEROIN     $HPRICE$(SP $((WID-WI-11-${#HPRICE})))LSD      $SPRICE
${SPWI}FENTANYL       $FPRICE$(SP $((WID-WI-11-${#FPRICE})))WEED      $LPRICE
EOF
    )""
    HUD
    cat <<< $SHOWPRICES
    echo
}

LOAN () { # LOAN sequence
    HUD
    read -n1 -p "DO YOU WANT TO VISIT THE LOAN SHARK? "
    if [[ $REPLY = [y/Y] ]]; then
        REPAY
    else
        STASH
    fi
}

REPAY () { # REPAY a loan sequence
    HUD
    read -p "HOW MUCH TO REPAY? "
    if [[ $REPLY = 0 ]]; then
        BORROW
    elif [[ $REPLY -gt $CASH ]]; then
        REPAY
    elif [[ $REPLY -gt $DEBT ]]; then
        REPAY
    elif [[ $REPLY -le $CASH ]] && [[ $REPLY -le $DEBT ]]; then
        let CASH=CASH-REPLY
        let DEBT=DEBT-REPLY
        BORROW
    else
        BORROW
    fi
}

BORROW () { # BORROW money from the loan shark
    HUD
    read -p "HOW MUCH TO BORROW? "
    if [[ $REPLY = 0 ]]; then
        STASH
    elif [[ $(($REPLY+DEBT)) -le $MAXLOAN ]]; then
        let DEBT=DEBT+REPLY
        let CASH=CASH+REPLY
        STASH
    elif [[ $(($REPLY+DEBT)) -gt $MAXLOAN ]]; then
        echo 'YOU THINK HE IS CRAZY MAN !!!'
        sleep 1
        let CASH=CASH+REPLY
        BORROW
    else
        LOAN
    fi
}

STASH () { # STASH or take out drugs from your stash
    HUD
    read -n1 -p "DO YOU WISH TO TRANSFER DRUGS TO YOUR STASH? "
    if [[ $REPLY = [y/Y] ]]; then
        echo
        echo
        STASHING
    elif [[ $REPLY = [n/N] ]]; then
        BANKING
    else
        BANKING
    fi

}

STASHING () { # Stash product type selector
        read -n1 -p "WHICH DRUG DO YOU WANT TO STASH OR TAKE? "

    case $REPLY in
        [c/C] ) STASHDEPOSIT COCAINE
            ;;
        [h/H] ) STASHDEPOSIT HEROIN
            ;;
        [f/F] ) STASHDEPOSIT FENTANYL
            ;;
        [m/M] ) STASHDEPOSIT METH
            ;;
        [l/L] ) STASHDEPOSIT LSD
            ;;
        [w/W] ) STASHDEPOSIT WEED
            ;;
        * ) STASH
            ;;
    esac
}

STASHDEPOSIT () { # stashing arithmetic and logic
    HUD
    read -p "HOW MUCH $1 DO YOU WANT TO STASH? "
            if [[ $REPLY = 0 ]]; then
                echo
                echo
            elif [[ $REPLY -le T$1 ]] && [[ $REPLY -gt 0 ]]; then
                let T$1=T$1-REPLY
                let S$1=S$1+REPLY
                let HOLD=HOLD+REPLY
            else
                STASH
            fi
    HUD
    unset REPLY
    read -p "HOW MUCH $1 DO YOU WANT TO TAKE? "
            if [[ $REPLY = 0 ]]; then
                echo
                echo
            elif [[ $REPLY -le S$1 ]] && [[ $REPLY -gt 0 ]] && [[ $((HOLD-REPLY)) -ge 0 ]]; then
                let S$1=S$1-REPLY
                let T$1=T$1+REPLY
                let HOLD=HOLD-REPLY
            else
                STASH
            fi
    BANKING

}

HOSPITAL () {
    HUD 
    read -n1 -p "DO YOU WISH TO VISIT THE HOSPITAL? " YNO
    if [[ $YNO = [n/N] ]]; then {
        echo
        MAINMENU
    }
    elif [[ $YNO = [y/Y] ]]; then {
        echo
        DOCTORING
    }
    else
        MAINMENU
    fi
    MAINMENU
}

DOCTORING () {
    FIGHTHUD
    DOCPRICEMULTIPLY=$(shuf -n1 -i "6000-10000")
    read -n1 -p "WILL YOU PAY $DOCPRICEMULTIPLY DOLLARS TO HAVE A DOCTOR SEW YOU UP ?" YNO
    if [[ $YNO = [n/N] ]]; then {
        echo
        MAINMENU
    }
    elif [[ $YNO = [y/Y] ]]; then {
        echo
        if [[ $DOCPRICEMULTIPLY -le $CASH ]] && [[ $DOCPRICEMULTIPLY -gt 0 ]]; then {
        let HEALTH=100
        let CASH=CASH-DOCPRICEMULTIPLY
        } 
        else {
            FIGHTHUD
            read -n1 -p 'DOCTOR SAID: GET DA FUCK OUTTA MY OFFICE YOU POOR BASTARD !!!'
        }
        fi 
        MAINMENU

    }
    else
        MAINMENU
    fi
    MAINMENU
}

BANKING () { # use the bank
    HUD
    read -n1 -p "DO YOU WISH TO VISIT THE BANK? " YNO
    if [[ $YNO = [n/N] ]]; then {
        echo
        HOSPITAL
    }
    elif [[ $YNO = [y/Y] ]]; then {
        echo
        read -p "HOW MUCH TO DEPOSIT? "
        if [[ $REPLY = 0 ]]; then {
            echo
        }
        elif [[ $REPLY -le $CASH ]] && [[ $REPLY -gt 0 ]]; then {
            let BANK=BANK+REPLY
            let CASH=CASH-REPLY
        }
        elif [[ $REPLY -gt $CASH ]]; then {
            BANKING
        }
        fi
        HUD
        read -p "HOW MUCH TO WITHDRAW? "
#        if [[ $REPLY = 0 ]]; then {
#            MAINMENU
#        }
        if [[ $REPLY -le $BANK ]] && [[ $REPLY -gt 0 ]]; then {
            let BANK=BANK-REPLY
            let CASH=CASH+REPLY
        }
        elif [[ $REPLY -gt $BANK ]]; then {
            BANKING
        }
        else :;
            HOSPITAL
        fi
        HOSPITAL
    }
    else
        HOSPITAL
    fi

}

MAINMENU () {
    HUD
    SHOWPRICES
    case $STATE in
        begin )     STATE=normal
                    [[ $DAY = 0 ]] && LOAN
            ;;
        NEWYORKDO )   STATE=normal
                    LOAN
            ;;
        normal )    BUYSELLJET
            ;;
    esac

    # if [[ $DAY = 30 ]]; then
    #     GAMEOVER
    # fi
}


BUYSELLJET () {
    STATE=normal
    read -n1 -p "WILL YOU BUY, SELL OR JET? " BSJ
    case $BSJ in
         [b/B] ) echo && BUYING 
             ;;
         [l/L] ) echo && SELLING
             ;;
         [j/J] ) echo && JET
             ;;
         * ) MAINMENU
            ;;
     esac
}

BUYING () {
    read -n1 -p "WHAT WILL YOU BUY? "
    case $REPLY in
    [c/C] ) BUYDRUG COCAINE
        ;;
    [h/H] ) BUYDRUG HEROIN
        ;;
    [f/F] ) BUYDRUG FENTANYL
        ;;
    [m/M] ) BUYDRUG METH
        ;;
    [l/L] ) BUYDRUG LSD
        ;;
    [w/W] ) BUYDRUG WEED
        ;;
    * ) MAINMENU
        ;;
esac
}

AFFORDABILITY () {
    let C_AFFORD=CASH/CPRICE
    let H_AFFORD=CASH/HPRICE
    let A_AFFORD=CASH/FPRICE
    let W_AFFORD=CASH/WPRICE
    let S_AFFORD=CASH/SPRICE
    let L_AFFORD=CASH/LPRICE
}

BUYDRUG () {
    HUD
    SHOWPRICES
    AFFORDABILITY
    TINYNAME=$(cut -c1 <<< $1)
    TAFFORD=${TINYNAME}_AFFORD
    TPRICE=${TINYNAME}PRICE
    echo "YOU CAN AFFORD ( ${!TAFFORD} )"
    read -p "HOW MUCH $1 DO YOU WANT TO BUY? "
            if [[ $REPLY = 0 ]]; then
                echo
                MAINMENU
            elif [[ $REPLY -le ${!TAFFORD} ]] && [[ $REPLY -gt 0 ]] && [[ $((HOLD-REPLY)) -ge 0 ]]; then
                let T$1=T$1+REPLY
                let CASH=CASH-$((REPLY*${!TPRICE}))
                let HOLD=HOLD-REPLY
                #let T$1=$(bc <<< $(echo T$S1)+$(echo $REPLY))
                #let CASH=$(bc <<< $(echo $CASH)-$(echo $REPLY)*$(echo $TPRICE))
                #let T$1=T$1-REPLY
                #let CASH=CASH+$((REPLY*${!TPRICE}))
                MAINMENU
            else
                MAINMENU
            fi
}

SELLING () {
    read -n1 -p "WHAT WILL YOU SELL? "
    case $REPLY in
    [c/C] ) SELLDRUG COCAINE
        ;;
    [h/H] ) SELLDRUG HEROIN
        ;;
    [f/F] ) SELLDRUG FENTANYL
        ;;
    [m/M] ) SELLDRUG METH
        ;;
    [l/L] ) SELLDRUG LSD
        ;;
    [w/W] ) SELLDRUG WEED
        ;;
    * ) MAINMENU
        ;;
esac
}

PROFITABILITY () {
    let C_PROFT=$((COCAINE*CPRICE))
    let H_PROFIT=$((HEROIN*HPRICE))
    let A_PROFIT=$((FENTANYL*FPRICE))
    let W_PROFIT=$((METH*WPRICE))
    let S_PROFIT=$((LSD*SPRICE))
    let L_PROFIT=$((WEED*LPRICE))
}

SELLDRUG () {
    HUD
    SHOWPRICES
    PROFITABILITY
    TINYNAME=$(cut -c1 <<< $1)
    TPRICE=${TINYNAME}PRICE
    TMAX=T${1}
    echo "YOU CAN SELL ( ${!TMAX} )"
    read -p "HOW MUCH $1 DO YOU WANT TO SELL? "
            if [[ $REPLY = 0 ]]; then
                echo
                MAINMENU
            elif [[ $REPLY -le ${!TMAX} ]] && [[ $REPLY -gt 0 ]]; then
                #let T$1=((bc <<< $((T$S1-REPLY))))
                #let CASH=((bc <<< $((CASH+REPLY*TPRICE)))))
                let T$1=T$1-REPLY
                let CASH=CASH+$((REPLY*${!TPRICE}))
                let HOLD=HOLD+REPLY
                MAINMENU
            else
                MAINMENU
            fi
}

JET () {
    HUD
    echo
    echo "$(SP $W)1"")""  NEW YORK, USA$(SP $W)2"")""  LOS ANGELES, USA$(SP $W)  3"")""  RIO DE JANEIRO, BRAZIL"
    echo "$(SP $W)4"")""  MEXICO CITY, MEXICO$(SP $((W-6)))5"")""  BANGKOK, THAILAND$(SP $((W+1)))6"")""  MOSCOW, RUSSIA"
    echo "$(SP $W)7"")""  SEOUL, SOUTH KOREA$(SP $((W-5)))8"")""  SYDNEY, AUSTRALIA$(SP $((W+1)))9"")""  MUMBAI, INDIA"
    read -n1 -p "WHERE TO DUDE: "
    case $REPLY in
        1 ) GEO="NEW YORK, USA"
            STATE=NEWYORKDO && NEWDAY
            ;;
        2 ) GEO="LOS ANGELES, USA" && NEWDAY
            ;;
        3 ) GEO="RIO DE JANEIRO, BRAZIL" && NEWDAY
            ;;
        4 ) GEO="MEXICO CITY, MEXICO" && NEWDAY
            ;;
        5 ) GEO="BANGKOK, THAILAND" && NEWDAY
            ;;
        6 ) GEO="MOSCOW, RUSSIA" && NEWDAY
            ;;
        7 ) GEO="SEOUL, SOUTH KOREA" && NEWDAY
            ;;
        8 ) GEO="SYDNEY, AUSTRALIA" && NEWDAY
            ;;
        9 ) GEO="MUMBAI, INDIA" && NEWDAY
            ;;
        * ) MAINMENU
            ;;
    esac

}

NEWDAY () {
    let DAY=DAY+1
    ROLLPRICES
    #DEBT=$(bc <<< "$DEBT*1.10")
    DEBT=$((DEBT*110/100))
    #BANK=$(bc <<< "$BANK*1.05")
    BANK=$((BANK*105/100))
    ROLLFIGHT
    ROLLEVENT
    MAINMENU
}

ROLLFIGHT () {
    FIGHTCHANCE=$(($(shuf -n1 --input-range=1-100)/$((HOLD+1))))
    if [[ $FIGHTCHANCE -ge 1 ]]; then
        COPS=$((((FIGHTCHANCE/9))+2))
        HUD
        echo
        read -n1 -p "OFFICER HARDASS AND $COPS OF HIS DEPUTIES ARE CHASING YOU "'!!!!!'
        FIGHT
    fi
}

FIGHTHUD () {
    TERMINFO
    FIGHTHUD=""$(cat << EOF





$(BLOCKS $WIDTH)

$(SP $W)HEALTH   $DAMAGE$(DSP HEALTH)COPS   $COPS$(DSP COPS)GUNS   $GUNS

$(BLOCKS $WIDTH)
EOF
    )""
    cat <<< $FIGHTHUD
    echo
    echo
}

FIGHT () {
    TERMINFO
    FIGHTHUD
    # end game if dead
    if [[ $HEALTH -le 0 ]]; then {
        read -n1 -p 'THEY WASTED YOU MAN !! WHAT A DRAG !!!'
        exit
    }
    fi
    # no guns fight
    if [[ $GUNS = 0 ]]; then {
        read -n1 -p "WILL YOU RUN?"
        if [[ $REPLY = [r/R/y/Y] ]]; then { # running
            echo
            GETAWAY=$(shuf -n1 -i 1-2)
            if [[ $GETAWAY = 1 ]]; then {
                FIGHTHUD
                echo 'YOU LOST THEM IN THE ALLEYS !!'
                sleep 0.5
                MAINMENU
            }
            else {
                FIGHTHUD
                FIRINGONYOU
            }
            fi
        }
        else {
            FIGHT
        }
        fi
    }
    fi
    # gun fight
    if [[ $GUNS -gt 0 ]]; then {
        read -n1 -p "WILL YOU RUN OR FIGHT? "
        if [[ $REPLY = [r/R] ]]; then { # running
            echo
            GETAWAY=$(shuf -n1 -i 1-2)
            if [[ $GETAWAY = 1 ]]; then {
                FIGHTHUD
                read -n1 -p 'YOU LOST THEM IN THE ALLEYS !!'
                MAINMENU
            }
            else {
                FIGHTHUD
                FIRINGONYOU
            }
            fi
        }
        elif [[ $REPLY = [fF] ]]; then
          FIGHTHUD
          echo "YOU'RE FIRING ON THEM!!"
          sleep 0.5
          KILLTHEM=$(shuf -n1 -i "0-$((GUNS*2))")
          if [[ $KILLTHEM -eq 0 ]]; then
              FIGHTHUD
              echo "YOU MISSED THEM!!"
              sleep 0.5
              FIRINGONYOU
          elif [[ $KILLTHEM -gt 0 ]]; then
              FIGHTHUD
              KILLNUMBER=$(shuf -n1 -i "1-$GUNS")
              COPS=$((COPS-KILLNUMBER))
              if [[ $COPS -le 0 ]]; then
                  FIGHTHUD
                  echo "YOU KILLED ALL OF THEM!!!!"
                  sleep 0.5
                  FIGHTREWARD
              fi
              echo "YOU KILLED $KILLNUMBER OF THEM!!"
              sleep 1.5
              FIRINGONYOU
              FIGHT
          fi
        else {
            FIGHT
        }
        fi
    }
    fi
}

FIRINGONYOU () {
    FIGHTHUD
    echo 'THEY ARE FIRING ON YOU MAN !!'
    sleep 0.5
    DAMAGEHIT=$(($(shuf -n1 -i 0-2)*COPS-$(shuf -n1 -i 2-20)))
    if [[ $DAMAGEHIT -le 0 ]]; then {
        FIGHTHUD
        echo 'THEY MISSED !!'
        sleep 0.5
        FIGHT
    }
    elif [[ $DAMAGEHIT -gt 0 ]]; then {
        HEALTH=$((HEALTH-DAMAGEHIT))
        FIGHTHUD
        echo "YOU'VE BEEN HIT "'!!'
        sleep 0.5
        FIGHT
    }
    fi
}

FIGHTREWARD () {
    FIGHTHUD
    FIGHTREWARD=$(shuf -n1 -i "200-2000")
    CASH=$((CASH+FIGHTREWARD))
    read -n1 -p "YOU FOUND $FIGHTREWARD DOLLARS ON OFFICER HARDASS' CARCAS "'!!!'
    MAINMENU
}

DOCTOR () {
    FIGHTHUD
    DOCPRICEMULTIPLY=$(shuf -n1 -i "200-1000")
    DOC=$((HEALTH*50))
    WILL YOU PAY%
    DOLLARS TO HAVE A DOCTOR SEW YOU UP ?
}

ROLLEVENT () {
    echo
    EVENTCHANCE=$(shuf -n1 -i 1-14)
    case $EVENTCHANCE in
        [1-2] ) echo
            ;;
        3 ) MUGGED
            ;;
        4 ) COKEBUST
            ;;
        5 ) METHBOTTOMOUT
            ;;
        6 ) POLICEDOGS
            ;;
        7 ) BROWNIES
            ;;
        8 ) CHEAPHEROIN
            ;;
        9 ) FINDWEED
            ;;
        10 ) PARAQUAT
            ;;
        11 ) CHEAPWEED
            ;;
        12 ) CHEAPFENTANYL
            ;;
        13 ) GUNSALE
            ;;
        14 ) COATSALE
            ;;
    esac
}

MUGGED () {
    let CASH=$((CASH*4/5))
    HUD
    read -n1 -p 'YOU WERE MUGGED IN THE SUBWAY !!'
    MAINMENU
}

COKEBUST () {
    HUD
    CPRICE=$((CPRICE*6))
    read -n1 -p 'COPS MADE A BIG COKE BUST !!  PRICES ARE OUTRAGEOUS !!'
    MAINMENU

}

METHBOTTOMOUT () {
    HUD
    WPRICE=$((WPRICE/5))
    read -n1 -p 'COLOMBIAN FREIGHTER DUSTED THE COAST GUARD !!  METH PRICES HAVE BOTTOMED OUT !!'
    MAINMENU
}

POLICEDOGS () {
    if [[ $HOLD -lt 70 ]]; then
        n=$(shuf -n1 -i 2-5)
        DRUGSARR=(COCAINE HEROIN FENTANYL METH LSD WEED)
        for DRUG in ${DRUGSARR[@]}; do
            DROPPED=$((T$DRUG/$n))
            let HOLD=$((HOLD+DROPPED))
            let T$DRUG=$((T$DRUG-DROPPED))
        done
        HUD
        echo "POLICE DOGS CHASE YOU $n BLOCKS "'!!'
        echo
        read -n1 -p  "YOU DROPPED SOME DRUGS "'!!'"  THAT'S A DRAG MAN "'!!'
    fi
    MAINMENU
}

BROWNIES () {
    if [[ $TMETH -gt 1 ]]; then
        n=$(shuf -n1 -i 1-5)
        DROPPED=$((TMETH/$n))
        let HOLD=$((HOLD+DROPPED))
        let TMETH=$((TMETH-DROPPED))
        HUD
        echo 'YOUR MAMA MADE SOME BROWNIES AND USED YOUR METH !!'
        sleep 0.5
        echo
        read -n1 -p 'THEY WERE GREAT !!'
    fi
    MAINMENU
}

CHEAPHEROIN () {
    HUD
    HPRICE=$((HPRICE/6))
    read -n1 -p 'PIGS ARE SELLING CHEAP HEROIN FROM LAST WEEKS RAID !!'
    MAINMENU

}

FINDWEED () {
    if [[ $HOLD -gt 30 ]]; then
        n=$(shuf -n1 -i 1-15)
        i=$(shuf -n1 -i 1-6)
        case $i in
            1 ) m=COCAINE
                ;;
            2 ) m=HEROIN
                ;;
            3 ) m=FENTANYL
                ;;
            4 ) m=METH
                ;;
            5 ) m=LSD
                ;;
            6 ) m=WEED
                ;;
        esac
        FOUND=$n
        let HOLD=$(($HOLD-$FOUND))
        let T$m=$((T$m+$FOUND))
        HUD
        read -n1 -p "YOU FIND $n UNITS OF $m ON A DEAD DUDE IN THE SUBWAY "'!!'
        MAINMENU
    else
        MAINMENU
    fi
}

PARAQUAT () {
    HUD
    echo 'THERE IS SOME METH THAT SMELLS LIKE PARAQUAT HERE !! IT LOOKS GOOD !!'
    read -n1 -p 'WILL YOU SMOKE IT ?'
    if [[ $REPLY = [y/Y] ]]; then
        HUD
        echo 'YOU HALUCINATE FOR THREE DAYS ON THE WILDEST TRIP YOU EVER IMAGINED !!!'
        sleep 0.5
        echo 'THEN YOU DIE BECAUSE YOUR BRAIN HAS DISINTEGRATED !!!'
        sleep 0.5
    else
        MAINMENU
    fi

}

CHEAPWEED () {
    HUD
    LPRICE=$((LPRICE/6))
    read -n1 -p 'RIVAL DRUG DEALERS RADED A PHARMACY AND ARE SELLING  C H E A P   W E E D !!!'
    MAINMENU
}

CHEAPFENTANYL () {
    HUD
    FPRICE=$((FPRICE/10))
    read -n1 -p 'THE MARKET HAS BEEN FLOODED WITH CHEAP HOME MADE FENTANYL !!!'
    MAINMENU
}

GUNSALE () {
    HUD
    GUNSTOCK=(RUGER ".38 SPECIAL" BARETTA)
    SHUFGUNS=$(shuf -n1 -i "0-2")
    GUNPRICE=$(shuf -n1 -i "250-500")
    read -n1 -p "WILL YOU BUY A ${GUNSTOCK[$SHUFGUNS]} FOR $GUNPRICE""? "
    if [[ $REPLY = [y/Y] ]]; then {
        if [[ $CASH -ge $GUNPRICE ]]; then {
            let CASH=$((CASH-GUNPRICE))
            let GUNS=$((GUNS+1))
        }
        fi
    }
    else
        echo
    fi
    MAINMENU

}

COATSALE () {
    HUD
    COATSPACE=$(shuf -n1 -i "6-40")
    COATPRICE=$(shuf -n1 -i "150-400")
    read -n1 -p "WILL YOU BUY A NEW TRENCH COAT WITH MORE POCKETS FOR $COATPRICE"'? '
    if [[ $REPLY = [y/Y] ]]; then {
        if [[ $CASH -ge $COATPRICE ]]; then {
            let CASH=$((CASH-COATPRICE))
            let HOLD=$((HOLD+COATSPACE))
        }
        fi
    }
    else
        echo
    fi
    MAINMENU

}



# INITIALIZE THE GAME VALUES

STARTGAME
