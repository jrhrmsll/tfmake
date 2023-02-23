#!/usr/bin/env bash

WORKDIR=${WORKDIR:-"tfmake"}

rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}/outputs"
mkdir -p "${WORKDIR}/makefiles/plan" 
mkdir -p "${WORKDIR}/makefiles/apply"

declare -A modules=()

while IFS= read -r -d '' file; do
    module=$(dirname "${file}")
    modules["${module}"]=""
	
	echo "${module}" >> "${WORKDIR}/outputs/nodes"
done <  <(find -- * -name main.tf -type f -print0)

while IFS= read -r -d '' file; do
    module=$(dirname "${file}")
    modules["${module}"]=$(yq -o=tsv ".dependencies" "${file}")
done <  <(find -- * -name .tfmake -type f -print0)


echo "all:" "${!modules[@]}" > "${WORKDIR}/makefiles/plan/Makefile"

for module in "${!modules[@]}"; do
cat >> "${WORKDIR}/makefiles/plan/Makefile" << EOF
${module}: ${modules[${module}]} \$(wildcard ${module}/*.tf)
	@mkdir -p "${WORKDIR}/logs/${module}"
	terraform -chdir="${module}" init -no-color | tee "${WORKDIR}/logs/${module}/init.log"
	terraform -chdir="${module}" plan -out output.plan -no-color | tee "${WORKDIR}/logs/${module}/plan.log"
	@echo "${module}" >> "${WORKDIR}/outputs/visited"
EOF
done

echo "all:" "${!modules[@]}" > "${WORKDIR}/makefiles/apply/Makefile"

for module in "${!modules[@]}"; do
cat >> "${WORKDIR}/makefiles/apply/Makefile" << EOF
${module}: ${modules[${module}]} \$(wildcard ${module}/*.tf)
	@mkdir -p "${WORKDIR}/logs/${module}"
	terraform -chdir="${module}" init -no-color | tee "${WORKDIR}/logs/${module}/init.log"
	terraform -chdir="${module}" apply -auto-approve -no-color | tee "${WORKDIR}/logs/${module}/apply.log"
	@echo "${module}" >> "${WORKDIR}/outputs/visited"
EOF
done
