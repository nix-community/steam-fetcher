#!/bin/bash
# shellcheck source=/dev/null
if [ -e .attrs.sh ]; then source .attrs.sh; fi
source "${stdenv:?}/setup"

# Hack to prevent DepotDownloader from crashing trying to write to
# ~/.local/share/
export HOME
HOME=$(mktemp -d)

args=(
	-app "${appId:?}"
	-depot "${depotId:?}"
	-manifest "${manifestId:?}"
)

if [ -n "$branch" ]; then
	args+=(-beta "$branch")
fi

if [ -n "$debug" ]; then
	args+=(-debug)
fi

DepotDownloader \
	"${args[@]}" \
	-dir "${out:?}"
