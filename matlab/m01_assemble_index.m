% m01_assemble_index
% Assembles the national DRASTIC index from the seven recovered score layers
% and verifies it bit for bit against the archived exact index SAKTE_DI_100m.asc.
% Outputs: profilet.mat (mask, rates, DI grid, unique profiles with cell counts)
% and the m01 fields of matlab_verifikimi.json.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

[DATA, RES] = paths_repo();
PARAMS = 'DRASTIC';
W = [5 4 3 2 1 5 3];               % Delphi weights, order D R A S T I C
THR = [55 90 125 160];

fprintf('m01: loading the seven recovered score layers...\n');
S = [];
mask = [];
rates = cell(1, 7);
for p = 1:7
    a = read_asc(fullfile(DATA, sprintf('SCORE2_%c_score_100m.asc', PARAMS(p))));
    if isempty(S)
        S = zeros(size(a));
        mask = true(size(a));
    end
    mask = mask & (a > 0);
    a(a < 0) = 0;
    S = S + a;
    rates{p} = a / W(p);           % rating = score / weight
end
DI = S;
DI(~mask) = NaN;

% verification against the archived exact index
ref = read_asc(fullfile(DATA, 'SAKTE_DI_100m.asc'));
ref(ref == -9999) = NaN;
dmax = max(abs(DI(mask) - ref(mask)));
ncell = nnz(mask);
[vals, ~, iv] = unique(DI(mask));
valc = accumarray(iv, 1);          % cells per distinct index value
shares = zeros(1, 5);
kk = klasa_di(DI(mask), THR);
for k = 1:5
    shares(k) = 100 * nnz(kk == k) / ncell;
end
on_thr_cells = nnz(DI(mask) == THR(1) | DI(mask) == THR(2) | ...
                   DI(mask) == THR(3) | DI(mask) == THR(4));

% unique profiles (ratings) with cell counts
R7 = zeros(ncell, 7);
for p = 1:7
    rp = rates{p};
    R7(:, p) = rp(mask);
end
[Runiq, ~, ic] = unique(R7, 'rows');
counts = accumarray(ic, 1);

rez01 = struct();
rez01.qeliza = ncell;
rez01.km2 = ncell * 0.01;
rez01.max_abs_diff_vs_SAKTE = dmax;
rez01.di_min = min(DI(mask));
rez01.di_max = max(DI(mask));
rez01.vlera_te_dallueshme = numel(vals);
rez01.pjeset_klasave_pct = round(shares, 2);
rez01.qeliza_mbi_prag = on_thr_cells;
rez01.profile_unike = size(Runiq, 1);
disp(rez01);

save(fullfile(RES, 'profilet.mat'), 'mask', 'DI', 'Runiq', 'counts', 'ic', 'vals', 'valc', '-v7.3');
save(fullfile(RES, 'm01_rez.mat'), 'rez01');
fprintf('m01 done.\n');
