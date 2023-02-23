#!/usr/bin/env bash

FILES="${FILES:-""}"

for file in ${FILES}; do
    echo "touch file: ${file}"
    touch "${file}"
done

exit 0
