#!/usr/bin/env bash

WORKDIR=${WORKDIR:-"tfmake"}

BACKTICKS='```'
GITHUB_STEP_SUMMARY=${GITHUB_STEP_SUMMARY:-"${WORKDIR}/outputs/summary.md"}

if [[ -f ${WORKDIR}/outputs/visited ]]; then
    modules=$(cat "${WORKDIR}/outputs/visited")

    for module in ${modules}; do
cat >> "${GITHUB_STEP_SUMMARY}" << EOF
<details>
    <summary>Module <strong>"${module}"</strong> Apply</summary>

${BACKTICKS}
$(cat "${WORKDIR}/logs/${module}/apply.log")
${BACKTICKS}

</details>	
EOF
    done
fi

exit 0
