#!/bin/bash
# Run BayesCode's nodemutsel MCMC to fit a branch-wise mutation-selection
# codon model and estimate relative effective population size (Ne) along a
# phylogeny.
#
# Dependency (not bundled): BayesCode  https://github.com/ThibaultLatrille/bayescode
#
# Usage:
#   run_nodemutsel.sh --alignment ALN.phy --tree TREE.nwk --output PREFIX \
#                      [--ncat N] [--until N] [--nodemutsel-bin PATH]
#
# Output: PREFIX.trace, PREFIX.chain, and other BayesCode chain files.

set -euo pipefail

NODEMUTSEL_BIN="nodemutsel"
NCAT=30
UNTIL=2000

usage() {
    echo "Usage: $0 --alignment ALN.phy --tree TREE.nwk --output PREFIX [--ncat N] [--until N] [--nodemutsel-bin PATH]" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --alignment) ALIGNMENT="$2"; shift 2 ;;
        --tree) TREE="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        --ncat) NCAT="$2"; shift 2 ;;
        --until) UNTIL="$2"; shift 2 ;;
        --nodemutsel-bin) NODEMUTSEL_BIN="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1" >&2; usage ;;
    esac
done

: "${ALIGNMENT:?--alignment is required}"
: "${TREE:?--tree is required}"
: "${OUTPUT:?--output is required}"

mkdir -p "$(dirname "$OUTPUT")"
"$NODEMUTSEL_BIN" --ncat "$NCAT" -a "$ALIGNMENT" -t "$TREE" -u "$UNTIL" "$OUTPUT"
