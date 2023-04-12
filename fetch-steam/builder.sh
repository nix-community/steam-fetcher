#!/bin/bash -x

source $stdenv/setup

# Hack to prevent DepotDownloader from crashing trying to write to
# ~/.local/share/
# Need to clean up after DepotDownloader has finished.
HOME="${out:?}/fakehome"

args=(
  -app "$appId"
  -depot "$depotId"
  -manifest "$manifestId"
)

if [ -n "$branch" ]; then
  args+=(-branch "$branch")
fi

DepotDownloader \
  "${args[@]}" \
  -dir "$out"
