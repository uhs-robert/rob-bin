#!/usr/bin/env bash

set -euo pipefail

old_kernels=($(dnf repoquery --installonly --latest-limit=-1 -q))

if [ "${#old_kernels[@]}" -eq 0 ]; then
  echo "No old kernels found."
  exit 0
fi

echo "The following old kernels will be removed:"
printf ' - %s\n' "${old_kernels[@]}"

read -rp "Proceed with removal? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

if ! sudo dnf remove -y "${old_kernels[@]}"; then
  echo "Failed to remove old kernels."
  exit 1
fi

echo "Successfully removed old kernels."
