# The mathematics of an index method

MATLAB reproduction package for the manuscript *The mathematics of an index
method: groundwater vulnerability assessment as measurement, structure,
geometry, inference, and decision* (A. Beqiraj and D. Zeqiraj).

One command re-derives every statistical, geometric and decision result of the
paper, and draws three of its figures, from the archived inputs shipped here.

```matlab
cd matlab
run_all
```

Base MATLAB, no toolboxes. About four minutes on a desktop CPU. Inputs expand
themselves from the gzipped grids in `data/` on the first run; outputs land in
`results/`.

## What it computes

| Script | Result |
|---|---|
| `m01_assemble_index.m` | the national index from the seven rating layers, verified against the archived raster; class shares; the 13,566 unique profiles |
| `m02_geometry.m` | attainable-set ranks and spectra, the gauge kernel, the A to C and R coupling, the 49,547 crossing hyperplanes, the Zaslavsky bound, the consensus margins |
| `m03_hierarchical_bayes.m` | the hierarchical posterior over DRASTIC weights with the 1987 Delphi consensus as prior: four chains of 24,000 Metropolis iterations, R-hat, sum-23 summaries by aquifer family, 8-fold cross-validation |
| `m04_deployment.m` | the national class-probability field, the count of distinct class maps across draws, the draw-pair map instability, and the margin-probability bridge with its Chebyshev bound |
| `m05_thresholds.m` | the max-margin threshold redesign at tolerances of 1, 2 and 5 percentage points |
| `m06_voi.m` | the preposterior value of ten new monitoring stations, by aquifer family |
| `m07_figures.m` | Figures 1 to 3 of the manuscript |
| `run_all.m` | the whole chain, then `collect_results` writes `results/matlab_verifikimi.json` |

Helpers: `read_asc`, `pctl`, `spearman_r`, `klasa_di`, `logpost_hier`,
`run_chain_hier`, `setup_data`, `paths_repo`.

## Determinism

Checked, not asserted. `matlab/determinism_check.ps1` deletes every result and
runs the chain twice from scratch, comparing the SHA256 of the verification
file:

```
powershell -NoProfile -ExecutionPolicy Bypass -File matlab/determinism_check.ps1
```

The outcome is written to `results/determinism_check.txt` with both run logs
beside it. On the machine of record, two runs from scratch (248 s and 242 s)
produced the digest
`B77696A37AFB4CD3B2DDF7D825D0477A659390D4D77218CD6CFDA4C131896051`, which is
also the digest the package produced before the repository was assembled, so
the gzipped grids and the path rearrangement changed no number. Runtimes are printed to the logs and deliberately kept out of the
verification file, since a timing is not a function of the inputs and would
break the very check it appeared in.

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
