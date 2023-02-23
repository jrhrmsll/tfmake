#!/usr/bin/env bash

WORKDIR=${WORKDIR:-"tfmake"}

BACKTICKS='```'
GITHUB_STEP_SUMMARY=${GITHUB_STEP_SUMMARY:-"${WORKDIR}/outputs/summary.md"}

CLASS_DEF_DEFAULT=${CLASS_DEF_DEFAULT:-"fill:#E7F6A4,stroke:#E7F6A4,stroke-width:2px,color:#435200;"}
CLASS_DEF_VISITED=${CLASS_DEF_VISITED:-"fill:#BACD66,stroke:#435200;"}

cat > "${WORKDIR}/outputs/mermaid.md" << EOF
  flowchart TB

  classDef default ${CLASS_DEF_DEFAULT}
  classDef visited ${CLASS_DEF_VISITED}

EOF

while IFS= read -r -d '' file; do
    module=$(dirname "${file}")
    echo "  ${module}($module)" >> "${WORKDIR}/outputs/mermaid.md"
done <  <(find -- * -name main.tf -type f -print0)

while IFS= read -r -d '' file; do
    module=$(dirname "${file}")
    dependencies=$(yq -o=tsv ".dependencies" "${file}")

    for dependency in ${dependencies}; do
        echo "  ${dependency}(${dependency}) --> ${module}($module)" >> "${WORKDIR}/outputs/mermaid.md"
    done
done <  <(find -- * -name .tfmake -type f -print0)

if [[ -f ${WORKDIR}/outputs/visited ]]; then
    NODES=$(cat "${WORKDIR}/outputs/visited")

    for node in ${NODES}; do
        echo "  ${node}:::visited" >> "${WORKDIR}/outputs/mermaid.md"
    done
fi

cat >> "${GITHUB_STEP_SUMMARY}" << EOF
${BACKTICKS}mermaid
$(cat "${WORKDIR}/outputs/mermaid.md")
${BACKTICKS}
EOF
