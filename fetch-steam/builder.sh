#!/bin/bash
if [ -e .attrs.sh ]; then source .attrs.sh; fi
source $stdenv/setup

# Hack to prevent DepotDownloader from crashing trying to write to
# ~/.local/share/
# Need to clean up after DepotDownloader has finished.
HOME="${out:?}/fakehome"

args=(
  -debug
  -app "${appId:?}"
  -depot "${depotId:?}"
  -manifest "${manifestId:?}"
)
echo "Base args: ${args[@]}"

if [ -n "$branch" ]; then
  echo "Branch is set, so adding to arg list: $branch"
  args+=(-branch "$branch")
fi

DepotDownloader \
  "${args[@]}" \
  -dir "$out"
