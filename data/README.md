# Data

Nine files. Eight are gzipped Arc ASCII grids that expand on the first run of
`run_all` (or by calling `setup_data` directly); one is a JSON table. Compressed
they occupy 3.2 MB, expanded 201 MB, which is why they are shipped gzipped.

| File | What it is |
|---|---|
| `SCORE2_D_score_100m.asc.gz` | depth to water, official rating times its Delphi weight |
| `SCORE2_R_score_100m.asc.gz` | net recharge, likewise |
| `SCORE2_A_score_100m.asc.gz` | aquifer media, likewise |
| `SCORE2_S_score_100m.asc.gz` | soil media, likewise |
| `SCORE2_T_score_100m.asc.gz` | topography, likewise |
| `SCORE2_I_score_100m.asc.gz` | impact of the vadose zone, likewise |
| `SCORE2_C_score_100m.asc.gz` | hydraulic conductivity, likewise |
| `SAKTE_DI_100m.asc.gz` | the archived exact national index, stored at a 0.01-point step |
| `kalibrimi_62_pika.json` | the 62-point national calibration table |

## Grid

1539 columns by 3377 rows, 100 m cells, Gauss-Krueger zone 4 (Krasovsky and
Pulkovo, central meridian 21 E, false easting 4,500,000). Lower left corner
at easting 4,352,400 and northing 4,389,300. NODATA is -9999. Assessed extent
2,741,908 cells, 27,419 km2.

The layers store *scores*, that is rating times Delphi weight; the scripts
recover the ratings by dividing by the weights (5, 4, 3, 2, 1, 5, 3) in the
order D, R, A, S, T, I, C.

## Provenance

The seven rating layers were recovered from the seven print-ready scoring
sheets of the official 2024 national groundwater vulnerability assessment of
Albania, whose GIS project no longer exists. Recovery was by exact colour
classification for the five vector sheets and by direct assembly of the
embedded lossless strips for the two raster sheets, after a stored-row
inversion was detected bitwise; georeferencing was by silhouette matching
against the national mask, with intersection over union 0.964 to 0.970. The
recovered index spans 39.0 to 204.1 against the published 36.68 to 205.31.
One legend anomaly is recorded rather than smoothed: the recharge sheet uses a
rating set the published recharge tables do not generate. The topography
sheet prints score 8 for the 2 to 6 percent slope class, which is the value of
the report's applied rating table (its Table VII.6); only the report's summary
of the generic DRASTIC scheme (its Table VI.6) prints the Aller value 9, so
this is not an anomaly of the sheet. Appendix B of the manuscript gives the
full account.

The calibration table combines 24 wells of the Fushe-Kuqe coastal aquifer with
38 stations of the national groundwater monitoring network, all rated through
the recovered national layers so that a single rating convention applies.
Nitrate values derive from the 2010 to 2014 deliveries of the national network
to the Eionet Central Data Repository, verified station by station; the 2015 to
2018 deliveries are excluded pending official confirmation of an apparent
nitrate and nitrite coding inversion.

## Licensing

These grids are derived products of the official 2024 national assessment, and
the calibration table incorporates national monitoring data reported to Eionet.
The authors confirm that they hold the permission required to redistribute the
derived layers published here.

The data in this directory are released under Creative Commons Attribution 4.0
International (CC BY 4.0), separately from the MIT licence that covers the code
in `matlab/`. Attribution should name the official 2024 national groundwater
vulnerability assessment of Albania as the source of the rating layers, and the
national groundwater monitoring network, reported to the Eionet Central Data
Repository, as the source of the nitrate observations.

The upstream elevation source used for the topography layer in the earlier
reconstruction is Copernicus GLO-30; the earlier lithological fill used the BGR
IGME5000 map. Neither enters the recovered layers shipped here, which come from
the official sheets alone.
