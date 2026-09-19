% m13_fk_check
% The local Fushe-Kuqe vulnerability map against the national recovered index at the
% same wells. The two are separate products built at different scales and they do not
% agree at well level, which bounds how far the national statements transfer to the
% local one.
%
% The well database carries a published DRASTIC index for each well together with its
% Gauss-Krueger coordinates; the national index is sampled from the recovered raster
% at those coordinates. Both files are read only.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

ARC = 'C:\Users\d_zeq\OneDrive\Desktop\ARJAN I NDERUAR';
[DATA, RES] = paths_repo();
ASC = fullfile(DATA, 'SAKTE_DI_100m.asc');
XLS = fullfile(ARC, 'Fushe_Kuqe_All_Data_v4_2026-08-19.xlsx');

fid = fopen(ASC, 'r'); h = struct();
for k = 1:6
    l = strsplit(strtrim(fgetl(fid))); h.(lower(l{1})) = str2double(l{2});
end
G = fscanf(fid, '%f', [h.ncols, h.nrows])'; fclose(fid);
G(G == h.nodata_value) = NaN;
fprintf('national grid %d x %d at %g m, origin (%g, %g)\n', ...
        h.nrows, h.ncols, h.cellsize, h.xllcorner, h.yllcorner);

T = readtable(XLS, 'Sheet', '2_All_Wells', 'VariableNamingRule', 'preserve');
wx = T.('X_GaussKruger'); wy = T.('Y_GaussKruger'); wdi = T.('DRASTIC_Index');
if ~isnumeric(wx), wx = str2double(string(wx)); end
if ~isnumeric(wy), wy = str2double(string(wy)); end
if ~isnumeric(wdi), wdi = str2double(string(wdi)); end
keep = isfinite(wx) & isfinite(wy) & isfinite(wdi);
wx = wx(keep); wy = wy(keep); wdi = wdi(keep);
fprintf('wells with coordinates and a published index: %d\n', numel(wdi));

col = floor((wx - h.xllcorner) / h.cellsize) + 1;
row = h.nrows - floor((wy - h.yllcorner) / h.cellsize);
inside = col >= 1 & col <= h.ncols & row >= 1 & row <= h.nrows;
nat = nan(size(wdi));
li = sub2ind(size(G), row(inside), col(inside));
nat(inside) = G(li);
ok = isfinite(nat);
a = wdi(ok); b = nat(ok);
fprintf('wells falling on a valid national cell: %d\n', nnz(ok));

rez13 = struct();
rez13.n_wells = numel(wdi);
rez13.n_on_valid_cell = nnz(ok);
rez13.pearson = round(corr_local(a, b), 4);
rez13.spearman = round(spearman_r(a, b), 4);
rez13.mean_abs_diff = round(mean(abs(a - b)), 2);
rez13.mean_signed_diff_national_minus_local = round(mean(b - a), 2);
rez13.local_range = [min(a) max(a)];
rez13.national_range = round([min(b) max(b)], 2);
rez13.local_mean = round(mean(a), 2);
rez13.national_mean = round(mean(b), 2);

fprintf('Pearson %.4f, Spearman %.4f\n', rez13.pearson, rez13.spearman);
fprintf('mean absolute difference %.2f index points; national minus local %.2f\n', ...
        rez13.mean_abs_diff, rez13.mean_signed_diff_national_minus_local);
fprintf('local index %g to %g (mean %.2f); national %g to %g (mean %.2f)\n', ...
        rez13.local_range(1), rez13.local_range(2), rez13.local_mean, ...
        rez13.national_range(1), rez13.national_range(2), rez13.national_mean);

save(fullfile(RES, 'm13_rez.mat'), 'rez13');
fid = fopen(fullfile(RES, 'fk_check.json'), 'w');
fprintf(fid, '%s', jsonencode(rez13, 'PrettyPrint', true)); fclose(fid);
fprintf('m13 done.\n');

function r = corr_local(x, y)
x = x(:) - mean(x); y = y(:) - mean(y);
r = (x' * y) / sqrt((x' * x) * (y' * y));
end
