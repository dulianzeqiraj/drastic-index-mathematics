# The national DRASTIC assessment of Albania

MATLAB reproduction package for two manuscripts of A. Beqiraj and D. Zeqiraj
on the national DRASTIC assessment of Albania:

- *The national DRASTIC assessment of Albania: representation, identifiability,
  geometry, inference, and decision* (the theory manuscript), and
- *DRASTIC as a statistical model: a complete probabilistic formulation of
  national groundwater vulnerability assessment, with hierarchical Bayesian
  weight inference, posterior class probabilities, and preposterior monitoring
  design* (the model manuscript).

They share one pipeline and one set of archived inputs, so they share one
package. One command re-derives every statistical, geometric and decision
result of both, and draws their figures, from the inputs shipped here.

```matlab
cd matlab
run_all
```

Base MATLAB, no toolboxes. About four minutes for the original chain on a
desktop CPU, and about twenty minutes with the revision stages, most of that in
the forty rehearsals of the preposterior analysis. Inputs expand themselves from
the gzipped grids in `data/` on the first run; outputs land in `results/`.

## What it computes

| Script | Result |
|---|---|
| `m01_assemble_index.m` | the national index from the seven rating layers, verified against the archived raster; class shares; the 13,566 unique profiles |
| `m02_geometry.m` | attainable-set ranks and spectra, the gauge kernel, the A to C and R coupling, the 49,547 crossing hyperplanes, the Zaslavsky bound, the consensus margins |
| `m03_hierarchical_bayes.m` | the hierarchical posterior over DRASTIC weights with the 1987 Delphi consensus as prior: four chains of 24,000 Metropolis iterations, R-hat, sum-23 summaries by aquifer family, 8-fold cross-validation |
| `m04_deployment.m` | the national class-probability field, the count of distinct class maps across draws, the draw-pair map instability, and the margin-probability bridge with its Chebyshev bound |
| `m05_thresholds.m` | the max-margin threshold redesign at tolerances of 1, 2 and 5 percentage points |
| `m06_voi.m` | the preposterior value of ten new monitoring stations, by aquifer family |
| `m07_figures.m` | Figures 1 to 3 of the theory manuscript |
| `m06_voi_dense.m` | the same preposterior analysis at forty rehearsals per family, all four families, with the Monte Carlo standard error of each value |
| `m10_save_chains.m` | the four chains saved separately, so the diagnostics can be recomputed |
| `m11_cv_auc.m` | discrimination against measured nitrate: the area under the ROC curve, fitted and under 8-fold cross-validation, against the same index under the 1987 weights |
| `m12_diagnostics.m` | the potential scale reduction in its whole-chain and split-chain forms, and the bulk effective sample size of every component |
| `m13_fk_check.m` | the local Fushe-Kuqe map against the national recovered index at the wells |
| `m15_official_map.m` | the official map as the posterior sees it: the recovered index and its classes under the Delphi weights and under the effective weights of the assessment report, the archived modal map against each, and the quantities of Proposition 6 of the model manuscript; draws its Figure 1 |
| `m08_figures_model.m`, `m09_figures_model_b.m`, `m14_figure_voi.m` | Figures 2 to 5 of the model manuscript |
| `run_all.m` | the whole chain, then `collect_results` writes `results/matlab_verifikimi.json` |

Helpers: `read_asc`, `pctl`, `spearman_r`, `klasa_di`, `logpost_hier`,
`run_chain_hier`, `setup_data`, `paths_repo`. Rank statistics average over ties
throughout, because the rating alphabets are finite and the index takes repeated
values.

`m08_figures_model.m`, `m09_figures_model_b.m`, `m13_fk_check.m` and `m15_official_map.m` read the
archived national outputs of the original Python pipeline, which are not
redistributed here; the path to that archive is set at the top of each of those
three files and has to be pointed at a local copy. Everything else runs from
`data/`.

## Determinism

Checked, not asserted. `matlab/determinism_check.ps1` deletes every result and
runs the chain twice from scratch, comparing the SHA256 of the verification
file:

```
powershell -NoProfile -ExecutionPolicy Bypass -File matlab/determinism_check.ps1
```



Run one MATLAB instance at a time: under a single-seat licence a second
instance fails to start, and the check then reports a spurious mismatch.

## Two implementations

The same computations exist twice, in two languages that share their input data
and their model specification but no code: the original Python pipelines, which
produced every value quoted in the manuscript, and this package. Their agreement
(Appendix C, Table 3 of the paper) is therefore a check on implementation rather
than on the model: it says the numbers do not depend on one person's code, which
is the part of reproducibility that re-running a single program cannot test.

Two differences are expected and documented in that table. Monte Carlo
quantities agree within Monte Carlo error rather than exactly, the largest gap
in the posterior weight medians being 0.28 on the sum-23 scale. And the modal
class map is the least reproducible object of all, exactly as the paper's
instability result predicts: it is one draw from a posterior whose draws never
agree, which is why the deliverable is the probability field and not the map.

## Not included

The recovery of the seven official print sheets onto the common grid is
archived separately as its original Python pipelines with their bitwise audits.
MATLAB has no PDF rasteriser, so that step is not portable to this package,
which consumes the recovered rasters and independently verifies the index they
imply.

## Data

See [data/README.md](data/README.md) for the grid definition and the provenance
of the layers: the seven official scoring sheets of the 2024 national assessment
recovered onto a common 100 m grid, and the 62-point national calibration table.

## Citing

See `CITATION.cff`. The code in `matlab/` is MIT licensed; the data in `data/`
are released under CC BY 4.0 and require the attribution set out in
`data/README.md`.
