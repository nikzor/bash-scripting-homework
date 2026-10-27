#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'

step=1
hits=0
numbers=()

while :; do
    number=$((RANDOM % 10))
    echo "Step: $step"

    while :; do
        if ! IFS= read -r -p "Please enter number from 0 to 9 (q - quit): " input; then
            echo
            exit 0
        fi

        case "$input" in
            [0-9]) break ;;
            q) echo "Bye!"; exit 0 ;;
            *) echo "Invalid input. Please repeat." ;;
        esac
    done

    if [[ "$input" == "$number" ]]; then
        echo "Hit! My number: $number"
        hits=$((hits + 1))
        numbers+=("${GREEN}${number}${RESET}")
    else
        echo "Miss! My number: $number"
        numbers+=("${RED}${number}${RESET}")
    fi

    # Храним только последние 10 чисел.
    if (( ${#numbers[@]} > 10 )); then
        numbers=("${numbers[@]:1}")
    fi

    hit_percent=$((hits * 100 / step))
    miss_percent=$((100 - hit_percent))
    echo "Hit: ${hit_percent}% Miss: ${miss_percent}%"
    printf 'Numbers:'
    printf ' %b' "${numbers[@]}"
    printf '\n\n'

    step=$((step + 1))
done
