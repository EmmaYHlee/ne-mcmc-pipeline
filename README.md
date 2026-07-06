# NE-MCMC-pipeline

NE stands for population size. NE-MCMC-pipeline is a pipeline for estimating branch-wise effective population size (Ne) from a
codon alignment and a phylogeny, using BayesCode's mutation-selection MCMC
model.

## What it does

Given a concatenated codon alignment (PHYLIP) and a phylogenetic tree
(Newick) for the same set of taxa, the pipeline:

1. **MCMC model fit** (`scripts/run_nodemutsel.sh`) — runs BayesCode's
   `nodemutsel`, a branch-wise mutation-selection codon model, to jointly
   estimate dN/dS, mutation rates, and relative Ne along every branch.
2. **Convergence diagnostics** (`scripts/plot_trace.py`) — plots MCMC trace
   parameters (log-likelihood, log-prior, branch population size, etc.) so
   chain convergence and mixing can be checked visually, optionally
   overlaying multiple independent chains (e.g. replicate gene sets).
3. **Posterior summarization** (`scripts/summarize_posterior.sh`) — runs
   `readnodemutsel` to discard burn-in and summarize the posterior into
   per-branch point estimates, and optionally calls BayesCode's own
   `plot_tree.py` / `convert_tree.py` utilities to annotate/visualize the
   tree with the resulting Ne estimates.

Each script is a standalone CLI tool with no hardcoded paths.

## Dependencies

Not bundled — install separately and point the scripts at the binaries:

| Tool | Used for | Link |
|---|---|---|
| BayesCode (`nodemutsel`, `readnodemutsel`) | mutation-selection MCMC and posterior summary | https://github.com/ThibaultLatrille/bayescode |
| Python: pandas, matplotlib, seaborn | trace plotting | `pip install pandas matplotlib seaborn` |
| BayesCode `utils/plot_tree.py`, `utils/convert_tree.py` (optional) | tree annotation with Ne estimates | included in the BayesCode repo above |

## Usage

```bash
S=scripts

$S/run_nodemutsel.sh \
  --alignment example/input/example_alignment.phy \
  --tree      example/input/example_tree.nwk \
  --output    example/expected_output/chain \
  --ncat 30 --until 2000

python3 $S/plot_trace.py \
  --trace-files example/expected_output/chain.trace \
  --output-dir  example/expected_output/trace_plots \
  --burnin 1000

$S/summarize_posterior.sh \
  --chain  example/expected_output/chain \
  --output example/expected_output/chain_summary \
  --burnin 1000 --until 1999 \
  --bayescode-utils-dir /path/to/bayescode/utils
```

Running several independent chains (e.g. one per gene subset) and passing
all of their `.trace` files to `plot_trace.py --trace-files ...` is a useful
way to sanity-check that independent runs are converging to consistent
posterior estimates.

## Example

`example/input/` contains a real 66-species, 2857bp codon alignment
(`example_alignment.phy`, produced by the companion
[`ortholog-codon-align-treebuild`](../ortholog-codon-align-treebuild) pipeline)
and a matching species tree (`example_tree.nwk`) for the same taxa, together
small enough to test the commands above quickly.

`example/expected_output/` is left empty here — an MCMC chain long enough to
be scientifically meaningful takes hours to days to run (see the `--until`
parameter), so pre-computed output isn't checked in. Point the commands
above at the example input to generate your own trace and summary files.
