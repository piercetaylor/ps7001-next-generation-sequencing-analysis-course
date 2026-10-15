#!/bin/bash
# Module 1 answer release (exercises): copies the M1E*_A.ipynb answer
# notebooks from Development/answers/Module_1_Answers into each student's
# Module_1 folder, next to the matching assignment (Exercises/).
# Skips students who don't have Module_1 yet, and never overwrites an answer
# file that is already there. Students added late can be caught up by re-running.

CLASS="${CLASS_DIR:?Set CLASS_DIR to the root of the course directory}"
MODULE=Module_1
SRC="$CLASS/Development/answers/${MODULE}_Answers"

shopt -s nullglob
answers=("$SRC"/M1[E][0-9]*_A.ipynb)
if [ ${#answers[@]} -eq 0 ]; then
    echo "No exercises answers found in $SRC"
    exit 1
fi

for student in "$CLASS"/Students/*/; do
    if [ ! -d "${student}${MODULE}" ]; then
        echo "SKIP   ${student}${MODULE} (module not deployed)"
        continue
    fi
    for answer in "${answers[@]}"; do
        name=$(basename "$answer")
        case "$name" in
            M1L*) sub=Lab ;;
            M1P*) sub=Practice ;;
            M1E*) sub=Exercises ;;
        esac
        dest_dir="${student}${MODULE}/$sub"
        dest="$dest_dir/$name"
        if [ -e "$dest" ]; then
            echo "SKIP   $dest (already exists)"
            continue
        fi
        mkdir -p "$dest_dir" \
            && cp "$answer" "$dest" \
            && chmod g+rw,o+rw "$dest" \
            && echo "DEPLOY $dest"
    done
done
