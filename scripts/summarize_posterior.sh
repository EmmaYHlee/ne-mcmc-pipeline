#!/bin/bash
# Summarize a nodemutsel MCMC chain into posterior point estimates, and
# (optionally) annotate/plot the tree with the resulting per-branch Ne
# estimates using BayesCode's own utility scripts.
#
# Dependency (not bundled): BayesCode  https://github.com/ThibaultLatrille/bayescode
# (readnodemutsel binary, plus utils/plot_tree.py and utils/convert_tree.py
# if --bayescode-utils-dir is given)
#
# Usage:
#   summarize_posterior.sh --chain PREFIX --output PREFIX \
#                           [--burnin N] [--until N] \
#                           [--readnodemutsel-bin PATH] [--bayescode-utils-dir DIR]

set -euo pipefail

READNODEMUTSEL_BIN="readnodemutsel"
BURNIN=1000
UNTIL=1999
BAYESCODE_UTILS_DIR=""

usage() {
    echo "Usage: $0 --chain PREFIX --output PREFIX [--burnin N] [--until N] [--readnodemutsel-bin PATH] [--bayescode-utils-dir DIR]" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --chain) CHAIN="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        --burnin) BURNIN="$2"; shift 2 ;;
        --until) UNTIL="$2"; shift 2 ;;
        --readnodemutsel-bin) READNODEMUTSEL_BIN="$2"; shift 2 ;;
        --bayescode-utils-dir) BAYESCODE_UTILS_DIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1" >&2; usage ;;
    esac
done

: "${CHAIN:?--chain is required}"
: "${OUTPUT:?--output is required}"

mkdir -p "$(dirname "$OUTPUT")"

"$READNODEMUTSEL_BIN" --burnin "$BURNIN" --until "$UNTIL" \
    --newick "$CHAIN" \
    --output "$OUTPUT"

if [ -n "$BAYESCODE_UTILS_DIR" ]; then
    python3 "${BAYESCODE_UTILS_DIR}/plot_tree.py" --input "$OUTPUT"
    python3 "${BAYESCODE_UTILS_DIR}/convert_tree.py" --input "$OUTPUT"
fi
