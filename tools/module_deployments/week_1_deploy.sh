#!/bin/bash
# Week 1 deployment: copies Module_0 and Module_1 into every student folder.
# Skips any student who already has the module, so released work is never overwritten.
# Students added late can be caught up by re-running this script.

CLASS="${CLASS_DIR:?Set CLASS_DIR to the root of the course directory}"
MODULES="Module_0 Module_1"

for student in "$CLASS"/Students/*/; do
    for module in $MODULES; do
        dest="${student}${module}"
        if [ -e "$dest" ]; then
            echo "SKIP   $dest (already exists)"
            continue
        fi
        cp -r "$CLASS/Modules/$module" "$student" \
            && chmod -R g+rwX,o+rwX "$dest" \
            && echo "DEPLOY $dest"
    done
done
