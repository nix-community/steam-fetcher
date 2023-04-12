#!/bin/bash

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
