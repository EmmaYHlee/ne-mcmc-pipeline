#!/usr/bin/env python3
"""Plot MCMC convergence traces for one or more nodemutsel chains.

For each requested parameter, overlays the post-burn-in trace of every chain
on one plot, so multiple independent runs (e.g. replicate gene sets) can be
visually checked for convergence and agreement.

Usage:
    plot_trace.py --trace-dir DIR --output-dir DIR
    plot_trace.py --trace-files a.trace b.trace c.trace --output-dir DIR
"""
import argparse
import glob
import os

import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import seaborn as sns

DEFAULT_PARAMS = [
    "logprior",
    "lnL",
    "BranchPopSizeMean",
    "Var_PopulationSize",
    "PredictedDNDS",
    "BranchLengthMean",
]


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    src = parser.add_mutually_exclusive_group(required=True)
    src.add_argument("--trace-dir", help="Directory containing *.trace files")
    src.add_argument("--trace-files", nargs="+", help="Explicit list of .trace files")
    parser.add_argument("--output-dir", required=True, help="Directory to write trace plots to")
    parser.add_argument("--burnin", type=int, default=1000, help="Number of leading iterations to discard (default: 1000)")
    parser.add_argument("--params", nargs="+", default=DEFAULT_PARAMS,
                         help=f"Trace columns to plot (default: {' '.join(DEFAULT_PARAMS)})")
    parser.add_argument("--label-prefix", default="trace",
                         help="Prefix used in output plot filenames (default: trace)")
    args = parser.parse_args()

    trace_files = sorted(glob.glob(os.path.join(args.trace_dir, "*.trace"))) if args.trace_dir else args.trace_files
    if not trace_files:
        raise SystemExit("No trace files found")

    os.makedirs(args.output_dir, exist_ok=True)
    palette = sns.color_palette("husl", len(trace_files))

    for param in args.params:
        plt.figure(figsize=(14, 6))
        found_any = False

        for i, filepath in enumerate(trace_files):
            try:
                df = pd.read_csv(filepath, sep="\t")
                df = df.iloc[args.burnin:]
            except Exception as e:
                print(f"Failed to load {filepath}: {e}")
                continue

            if param in df.columns:
                plt.plot(df.index, df[param], label=os.path.basename(filepath), color=palette[i])
                found_any = True
            else:
                print(f"{param} not found in {filepath}")

        if not found_any:
            plt.close()
            continue

        plt.xlabel("Iteration")
        plt.ylabel(param)
        plt.title(f"Trace Plot for {param}")
        plt.legend(loc="best", fontsize="small")
        plt.tight_layout()
        output_path = os.path.join(args.output_dir, f"{args.label_prefix}_{param}_trace_plot.png")
        plt.savefig(output_path, dpi=300)
        plt.close()
        print(f"Saved: {output_path}")


if __name__ == "__main__":
    main()
