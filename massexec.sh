#!/bin/bash

usage() {
    echo "Использование: $0 [--path dirpath] [--mask mask] [--number number] command" >&2
    exit 1
}

dir='.'
mask='*'
number=''
while (( $# > 0 )); do
    case "$1" in
        --path|--mask|--number)
            (( $# >= 2 )) || usage
            case "$1" in
                --path) dir=$2 ;;
                --mask) mask=$2 ;;
                --number)
                    [[ "$2" =~ ^[1-9][0-9]*$ ]] || usage
                    number=$2
                    ;;
            esac
            shift 2
            ;;
        --) shift; break ;;
        -*) usage ;;
        *) break ;;
    esac
done
[[ $# == 1 && -n "$mask" ]] || usage
if [[ ! -d "$dir" ]]; then
    echo "Ошибка: каталог не найден: $dir" >&2
    exit 1
fi
dir=$(cd -- "$dir" && pwd -P) || exit 1

# Поддерживаем и путь к файлу, и имя программы из PATH.
command_path=$1
if [[ -f "$command_path" && -x "$command_path" ]]; then
    [[ "$command_path" == /* ]] || command_path="./$command_path"
elif [[ "$command_path" != */* ]]; then
    command_path=$(type -P -- "$command_path")
fi
if [[ ! -f "$command_path" || ! -x "$command_path" ]]; then
    echo "Ошибка: команда не найдена или не имеет права исполнения: $1" >&2
    exit 1
fi

if [[ -z "$number" ]]; then
    number=$(getconf _NPROCESSORS_ONLN) || exit 1
fi

shopt -s nullglob dotglob
for file in "$dir"/*; do
    [[ -f "$file" && ! -L "$file" ]] || continue
    [[ "${file##*/}" == $mask ]] || continue

    # Считаем работающие процессы, включая случай очень быстрых команд.
    running=($(jobs -pr))
    while (( ${#running[@]} >= number )); do
        wait -n
        running=($(jobs -pr))
    done

    "$command_path" "$file" &
done

# Дожидаемся всех оставшихся обработчиков.
wait
