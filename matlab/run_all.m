% run_all
% Reproduces the manuscript's computed results end to end from the archived
% recovered rating layers and the national calibration dataset, then writes
% matlab_verifikimi.json and the manuscript figures.
%
% Stages m01 to m07 are the original chain. Stages m06_voi_dense to m14 were added
% at revision: the value of information at forty rehearsals per family instead of
% two or three, the chains saved for diagnostics, the fitted and cross-validated
% areas under the ROC curve, the split-chain potential scale reduction with the
% effective sample size, the local Fushe-Kuqe map against the national index, and
% the four figures of the model manuscript.
% Base MATLAB only, no toolboxes. Each stage is timed and the timings are
% printed, so the runtimes quoted in the manuscript are reproducible.
% Inputs are read from ../data (expanded from the shipped .gz on first run),
% outputs are written to ../results.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
t0 = tic;
setup_data;
ts = tic; m01_assemble_index;     t1 = toc(ts); clearvars -except t0 t1
ts = tic; m02_geometry;           t2 = toc(ts); clearvars -except t0 t1 t2
ts = tic; m03_hierarchical_bayes; t3 = toc(ts); clearvars -except t0 t1 t2 t3
ts = tic; m04_deployment;         t4 = toc(ts); clearvars -except t0 t1 t2 t3 t4
ts = tic; m05_thresholds;         t5 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5
ts = tic; m06_voi;                t6 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6
ts = tic; m07_figures;            t7 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7
ts = tic; m06_voi_dense;          t8 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8
ts = tic; m10_save_chains;        t9 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9
ts = tic; m11_cv_auc;             t10 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10
ts = tic; m12_diagnostics;        t11 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11
ts = tic; m13_fk_check;           t12 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12
ts = tic; m08_figures_model;      t13 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13
ts = tic; m09_figures_model_b;    t14 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14
ts = tic; m14_figure_voi;         t15 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15
collect_results;
fprintf('\nSTAGE TIMINGS (s): m01 %.1f | m02 %.1f | m03 %.1f | m04 %.1f | m05 %.1f | m06 %.1f | m07 %.1f\n', ...
    t1, t2, t3, t4, t5, t6, t7);
fprintf('total %.0f s\n', toc(t0));
