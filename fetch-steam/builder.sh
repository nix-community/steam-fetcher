#!/bin/bash
# shellcheck source=/dev/null
if [ -e .attrs.sh ]; then source .attrs.sh; fi
source "${stdenv:?}/setup"

# Hack to prevent DepotDownloader from crashing trying to write to
# ~/.local/share/
# Need to clean up after DepotDownloader has finished.
HOME="${out:?}/fakehome"

args=(
	-app "${appId:?}"
	-depot "${depotId:?}"
	-manifest "${manifestId:?}"
)

if [ -n "$branch" ]; then
	args+=(-branch "$branch")
fi

if [ -n "$debug" ]; then
	args+=(-debug)
fi

DepotDownloader \
	"${args[@]}" \
	-dir "$out"

# Clean up DepotDownloader leftovers not belonging to the Steam app we just
# downloaded.
rm -rf \
	"$HOME" \
	"${out:?}/.DepotDownloader"
