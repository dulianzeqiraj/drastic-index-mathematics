% run_all
% Reproduces the manuscript's computed results end to end from the archived
% recovered rating layers and the national calibration dataset, then writes
% matlab_verifikimi.json and the three manuscript figures.
% Base MATLAB only, no toolboxes. Each stage is timed and the timings are
% printed, so the runtimes quoted in the manuscript are reproducible.
% Inputs are read from ../data (expanded from the shipped .gz on first run),
% outputs are written to ../results.
t0 = tic;
setup_data;
ts = tic; m01_assemble_index;     t1 = toc(ts); clearvars -except t0 t1
ts = tic; m02_geometry;           t2 = toc(ts); clearvars -except t0 t1 t2
ts = tic; m03_hierarchical_bayes; t3 = toc(ts); clearvars -except t0 t1 t2 t3
ts = tic; m04_deployment;         t4 = toc(ts); clearvars -except t0 t1 t2 t3 t4
ts = tic; m05_thresholds;         t5 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5
ts = tic; m06_voi;                t6 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6
ts = tic; m07_figures;            t7 = toc(ts); clearvars -except t0 t1 t2 t3 t4 t5 t6 t7
collect_results;
fprintf('\nSTAGE TIMINGS (s): m01 %.1f | m02 %.1f | m03 %.1f | m04 %.1f | m05 %.1f | m06 %.1f | m07 %.1f\n', ...
    t1, t2, t3, t4, t5, t6, t7);
fprintf('total %.0f s\n', toc(t0));
