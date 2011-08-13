#!/bin/bash
# Cleaning up SMPlayer smplayer_files.ini
# By Yu-Jie Lin
#
# Usage:
#   clean-smplayer-files-ini.sh <PATH>
#
# Due to the file path information in smplayer-files.ini, it's time-consumption
# task for trying to reverse the path information to get the real file path. By
# using <PATH>, it would be doing the same process as SMPlayer creates the file
# path information.
#
# You can simply use ~ or $HOME, or even /.

INIFILE="$HOME/.config/smplayer/smplayer_files.ini"

gn_not_exist() {
    local fn_gn="$1"
    for ((i=0; i<${#files_gn[@]}; i++)); do
        [[ "$fn_gn" == "${files_gn[i]}" ]] && return 0
    done
    return 1
}

if [[ ! -f "$INIFILE" ]]; then
    echo "Can not find $INIFILE" >&2
    exit 1
fi

if [[ $# -lt 1 ]]; then
    echo "You need to specify a path, e.g. 
    $0 /tmp" >&2
    exit 1
fi

BASE="$1"
shift 1
if [[ "$BASE" != "/" ]]; then
    BASE="${BASE%/}"
fi
if [[ ! -e "$BASE" ]]; then
    echo "Can not find $BASE" >&2
    exit 1
fi
BASE_gn="${BASE//[\/\\:. ]/_}"

echo -n "Generating file list under $BASE..."
files_gn=()
i=0
while read line; do
    fn_gn="${line//[\/\\:. ]/_}"
    files_gn[i++]="$fn_gn"
done < <(find "$BASE" "$@" -printf "%h/%f\n")
echo "done."
echo

TMPFILE="$(mktemp)"
file_count=0
del_count=0
is_del=0
while read line; do
    echo -ne "\e[0G$del_count of $file_count"
    if [[ "${line:0:1}" == "[" ]]; then
        # Remove brackets
        fn_gn="${line:1:${#line}-2}"
        # Get rid of file size
        fn_gn="${fn_gn%_*}"
        ((file_count++))
        if [[ ! "$fn_gn" =~ "$BASE_gn" ]]; then
            is_del=0
            echo "$line" >> "$TMPFILE"
            continue
        fi

        gn_not_exist "$fn_gn"
        is_del=$?
        if [[ $is_del -eq 1 ]]; then
            ((del_count++))
        else
            echo "$line" >> "$TMPFILE"
        fi
    elif [[ $is_del -eq 0 ]]; then
        echo "$line" >> "$TMPFILE"
    fi
done < "$INIFILE"

if (( del_count > 0 )); then
    echo -e "\e[0G$del_count of $file_count files can not be found under $BASE."
    echo
    read -p "Do you want to write the results to
    ${INIFILE}
? " ans
    if [[ "$ans" =~ [yY] ]]; then
        mv -f "$TMPFILE" "$INIFILE" 
    fi
else
    echo -e "\e[0GNothing is gone under $BASE."
fi
rm -f "$TMPFILE"
