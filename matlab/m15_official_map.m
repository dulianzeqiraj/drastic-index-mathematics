% m15_official_map
% The official national map as the posterior sees it.
%
% Three things, all from the recovered layers and the archived deployment:
%   1. the official map itself, drawn from the recovered index (Figure 1 of the
%      model manuscript), with its class shares under the Delphi weights and
%      under the effective weights the assessment report derived from its own
%      sensitivity analysis (Table VIII.1 of the report);
%   2. the posterior modal map against each of those two fixed maps, cell by
%      cell on the archived surfaces: shares that agree, move up, move down, by
%      how many classes, and how much of the disagreement the posterior itself
%      calls undecided;
%   3. the quantities of Proposition 6 on the package's own deployment field:
%      the bound on the disagreement share, and the posterior expected agreement
%      of a fixed map against that of the modal map.
% Requires profilet.mat (m01) and m04_profile.mat (m04); reads the archived
% national outputs read-only for item 2.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

ARC  = 'C:\Users\d_zeq\OneDrive\Desktop\ARJAN I NDERUAR\Nxjerrja_Rasterave_2026-08-12';
[~, RES] = paths_repo();
FIGDIR = fullfile(RES, 'figures_model');
if ~isfolder(FIGDIR), mkdir(FIGDIR); end
MM = 1/25.4; DPI = '-r600';

W_DE  = [5 4 3 2 1 5 3];                              % Delphi, D R A S T I C
W_EFF = [5.34 3.33 2.62 2.46 1.85 4.56 2.84];         % report Table VIII.1, effective
THR   = [55 90 125 160];
FAMS  = {'aluvional', 'karbonatik', 'magmatik', 'flish_argjile'};

load(fullfile(RES, 'profilet.mat'), 'mask', 'DI', 'Runiq', 'counts', 'ic');
load(fullfile(RES, 'm04_profile.mat'), 'Pk', 'Pmax', 'Kmod', 'famu');
K = size(Runiq, 1);
wA = counts / sum(counts);
rez = struct();
rez.qeliza = nnz(mask);
rez.profile_unike = K;

%% ------------------------------------------------ 1. the two fixed maps, per profile
DIde  = Runiq * W_DE';
DIeff = Runiq * W_EFF';
kde   = klasa_di(DIde,  THR);
keff  = klasa_di(DIeff, THR);
rez.delphi.di_min = min(DIde);  rez.delphi.di_max = max(DIde);
rez.efektiv.di_min = min(DIeff); rez.efektiv.di_max = max(DIeff);
rez.efektiv.di_max_teorik = W_EFF * [6 9 10 10 10 10 10]';
for k = 1:5
    rez.delphi.pjeset_pct(k)  = round(100 * sum(wA(kde  == k)), 2);
    rez.efektiv.pjeset_pct(k) = round(100 * sum(wA(keff == k)), 2);
end
rez.raporti_XI3_pct = [2.29 53.84 20.14 20.14 3.59];
rez.delphi_vs_efektiv.ndryshon_pct = round(100 * sum(wA(kde ~= keff)), 2);
rez.delphi_vs_efektiv.ngrihet_pct  = round(100 * sum(wA(keff > kde)), 2);
rez.delphi_vs_efektiv.ulet_pct     = round(100 * sum(wA(keff < kde)), 2);
fprintf('index under Delphi weights   : %.2f to %.2f\n', rez.delphi.di_min, rez.delphi.di_max);
fprintf('index under effective weights: %.2f to %.2f (theoretical max %.2f)\n', ...
        rez.efektiv.di_min, rez.efektiv.di_max, rez.efektiv.di_max_teorik);
fprintf('class shares, Delphi   : %s\n', mat2str(rez.delphi.pjeset_pct));
fprintf('class shares, effective: %s\n', mat2str(rez.efektiv.pjeset_pct));
fprintf('class shares, report   : %s\n', mat2str(rez.raporti_XI3_pct));
fprintf('Delphi vs effective classes differ over %.2f%% (up %.2f, down %.2f)\n', ...
        rez.delphi_vs_efektiv.ndryshon_pct, rez.delphi_vs_efektiv.ngrihet_pct, ...
        rez.delphi_vs_efektiv.ulet_pct);

%% ------------------------------------------------ 2. archived modal map against each fixed map
Kmod_a = read_asc_full(fullfile(ARC, 'BAYES_klasa_modale_100m.asc'));
Pmod_a = read_asc_full(fullfile(ARC, 'BAYES_P_klasa_modale_100m.asc'));
assert(isequal(size(Kmod_a), size(mask)), 'archive grid and package grid differ');
valid = mask & isfinite(Kmod_a) & isfinite(Pmod_a);
Kde_g = nan(size(mask));  Kde_g(mask)  = kde(ic);
Kef_g = nan(size(mask));  Kef_g(mask)  = keff(ic);
tot = nnz(valid);
rez.arkivi.qeliza_krahasuara = tot;
refs = {'delphi', Kde_g; 'efektiv', Kef_g};
for r = 1:2
    nm = refs{r, 1}; Kref = refs{r, 2};
    d = Kmod_a(valid) - Kref(valid);
    p = Pmod_a(valid);
    s = struct();
    s.njesoj_pct   = round(100 * mean(d == 0), 1);
    s.ngrihet_pct  = round(100 * mean(d > 0), 1);
    s.ulet_pct     = round(100 * mean(d < 0), 1);
    s.ndryshon_pct = round(100 * mean(d ~= 0), 1);
    s.nje_klase_pct_e_ndryshimeve = round(100 * mean(abs(d(d ~= 0)) == 1), 1);
    s.dy_klase_pct_e_ndryshimeve  = round(100 * mean(abs(d(d ~= 0)) == 2), 1);
    s.max_abs_klase = max(abs(d));
    s.ndryshon_dhe_pavendosur_070_pct = round(100 * mean(d ~= 0 & p < 0.7), 1);
    s.ndryshon_dhe_vendosur_070_pct   = round(100 * mean(d ~= 0 & p >= 0.7), 1);
    s.ndryshon_dhe_sigurt_090_pct     = round(100 * mean(d ~= 0 & p >= 0.9), 1);
    s.njesoj_dhe_sigurt_090_pct       = round(100 * mean(d == 0 & p >= 0.9), 1);
    rez.arkivi.(nm) = s;
    fprintf(['archive modal map vs %-8s: same %.1f%%, up %.1f%%, down %.1f%%; of the changes ' ...
             '%.1f%% are one class; changed and undecided at 0.7: %.1f%%, changed and decided: %.1f%%, ' ...
             'changed and certain at 0.9: %.1f%%\n'], nm, s.njesoj_pct, s.ngrihet_pct, s.ulet_pct, ...
            s.nje_klase_pct_e_ndryshimeve, s.ndryshon_dhe_pavendosur_070_pct, ...
            s.ndryshon_dhe_vendosur_070_pct, s.ndryshon_dhe_sigurt_090_pct);
end

%% ------------------------------------------------ 3. Proposition 6 on the package's field
% p_k(x) for the class the fixed map assigns; modal map k*; area measure wA
Astar = sum(wA .* Pmax);
rez.prop6.A_modal = round(Astar, 4);
refs = {'delphi', kde; 'efektiv', keff};
for r = 1:2
    nm = refs{r, 1}; kD = refs{r, 2};
    pD = Pk(sub2ind(size(Pk), (1:K)', kD));
    s = struct();
    s.nu_ndryshon      = round(100 * sum(wA .* (Kmod ~= kD)), 2);
    s.nu_pD_nen_gjysem = round(100 * sum(wA .* (pD <= 0.5)), 2);
    s.A_fiks           = round(sum(wA .* pD), 4);
    s.hendeku_pp       = round(100 * (Astar - sum(wA .* pD)), 2);
    for a = [0.7 0.9]
        nm_a = sprintf('alfa_%02d', round(100 * a));
        s.(['nu_ndryshon_vendosur_' nm_a]) = round(100 * sum(wA .* (Kmod ~= kD & Pmax >= a)), 2);
        s.(['nu_pD_nen_1_minus_'   nm_a]) = round(100 * sum(wA .* (pD <= 1 - a)), 2);
    end
    % the three statements of the proposition, checked
    s.kufiri_i_mban    = all(Kmod(pD > 0.5) == kD(pD > 0.5));          % (i) pointwise
    s.kufiri_070_mban  = s.nu_ndryshon_vendosur_alfa_70 <= s.nu_pD_nen_1_minus_alfa_70;
    s.kufiri_090_mban  = s.nu_ndryshon_vendosur_alfa_90 <= s.nu_pD_nen_1_minus_alfa_90;
    s.identiteti_mban  = abs((Astar - sum(wA .* pD)) - sum(wA .* (Pmax - pD) .* (Kmod ~= kD))) < 1e-12;
    s.hendeku_nen_nu   = s.hendeku_pp <= s.nu_ndryshon;
    rez.prop6.(nm) = s;
    fprintf(['Prop. 6 vs %-8s: nu{k* ~= kD} = %.2f%% <= nu{p_kD <= 1/2} = %.2f%% [%d]; ' ...
             'A(k*) = %.4f, A(kD) = %.4f, gap = %.2f pp <= nu [%d]; identity [%d]; ' ...
             'alpha 0.7: %.2f <= %.2f [%d]; alpha 0.9: %.2f <= %.2f [%d]\n'], nm, ...
            s.nu_ndryshon, s.nu_pD_nen_gjysem, s.kufiri_i_mban, Astar, s.A_fiks, s.hendeku_pp, ...
            s.hendeku_nen_nu, s.identiteti_mban, s.nu_ndryshon_vendosur_alfa_70, ...
            s.nu_pD_nen_1_minus_alfa_70, s.kufiri_070_mban, s.nu_ndryshon_vendosur_alfa_90, ...
            s.nu_pD_nen_1_minus_alfa_90, s.kufiri_090_mban);
end
% by family, against the Delphi map
for f = 1:4
    sel = famu == f; wf = counts(sel) / sum(counts(sel));
    rez.prop6.sipas_familjes.(FAMS{f}).nu_ndryshon = round(100 * sum(wf .* (Kmod(sel) ~= kde(sel))), 1);
    pD = Pk(sub2ind(size(Pk), find(sel), kde(sel)));
    rez.prop6.sipas_familjes.(FAMS{f}).A_delphi = round(sum(wf .* pD), 3);
    rez.prop6.sipas_familjes.(FAMS{f}).A_modal  = round(sum(wf .* Pmax(sel)), 3);
end

fid = fopen(fullfile(RES, 'official_map.json'), 'w');
fprintf(fid, '%s\n', jsonencode(rez, 'PrettyPrint', true)); fclose(fid);

%% ------------------------------------------------ Figure 1: the official map
CLS = [0.24 0.44 0.68; 0.55 0.75 0.86; 0.95 0.93 0.70; 0.96 0.68 0.38; 0.78 0.24 0.22];
IDX = index_map();
rows = find(any(mask,2)); cols = find(any(mask,1));
cr = @(A) A(rows(1):rows(end), cols(1):cols(end));
DIc = cr(DI); Kdec = cr(Kde_g); Kefc = cr(Kef_g); mk = cr(mask);
[nr, nc] = size(DIc); ASP = nr/nc;

draw_panels(fullfile(FIGDIR, 'figure1_official'), {DIc, Kdec}, mk, ASP, ...
    {'(a) recovered DRASTIC index', '(b) the official five classes'}, ...
    {'index', 'class'}, IDX, CLS, [39 205], THR, MM, DPI);
draw_panels(fullfile(FIGDIR, 'figure1_official_3panel'), {DIc, Kdec, Kefc}, mk, ASP, ...
    {'(a) recovered DRASTIC index', '(b) classes, Delphi weights', '(c) classes, effective weights'}, ...
    {'index', 'class', 'class'}, IDX, CLS, [39 205], THR, MM, DPI);
fprintf('m15 done.\n');

%% ------------------------------------------------ helpers
function draw_panels(stem, layers, mk, ASP, titles, kinds, IDX, CLS, lim, THR, MM, DPI)
n = numel(layers);
Wmm = 190; mL = 3; mR = 3; gap = 4;
fwmm = min((Wmm - mL - mR - (n-1)*gap) / n, 58);
phmm = fwmm * ASP;
tHmm = 6; cbHmm = 2.6; lbHmm = 11;
Hmm = phmm + tHmm + cbHmm + lbHmm + 3;
W = Wmm*MM; H = Hmm*MM;
f = figure('Units','inches','Color','w');
set(f,'Position',[1 1 W H],'PaperUnits','inches','PaperPosition',[0 0 W H],'PaperSize',[W H]);
pb = (lbHmm + cbHmm + 1.5)/Hmm; phn = phmm/Hmm; pw = fwmm/Wmm;
cby = (lbHmm - 2)/Hmm; cbh = cbHmm/Hmm;
total = n*fwmm + (n-1)*gap;
lefts = ((Wmm - total)/2 + (0:n-1)*(fwmm+gap)) / Wmm;
for i = 1:n
    ax = axes('Position',[lefts(i) pb pw phn]);
    if strcmp(kinds{i}, 'index')
        img_scalar(ax, layers{i}, mk, lim, IDX);
        colormap(ax, IDX); clim(ax, lim);
        cb = colorbar(ax,'southoutside','Position',[lefts(i) cby pw cbh]);
        set(cb,'Ticks',[55 90 125 160],'FontSize',8.4);
        cb.Label.String = 'DRASTIC index, thresholds at the ticks'; cb.Label.FontSize = 8.4;
    else
        img_index(ax, layers{i}, mk, CLS);
        colormap(ax, CLS); clim(ax, [0.5 5.5]);
        cb = colorbar(ax,'southoutside','Position',[lefts(i) cby pw cbh]);
        set(cb,'Ticks',1:5,'FontSize',8.4);
        cb.Label.String = 'vulnerability class'; cb.Label.FontSize = 8.4;
    end
    title(ax, titles{i}, 'FontSize', 9.6, 'FontWeight', 'normal');
end
print(f, stem, '-dpng', DPI);
close(f);
fprintf('%s written (%d x %.0f mm)\n', stem, Wmm, Hmm);
end

function A = read_asc_full(p)
fid = fopen(p,'r'); h = struct();
for k = 1:6
    l = strsplit(strtrim(fgetl(fid))); h.(lower(l{1})) = str2double(l{2});
end
A = fscanf(fid,'%f',[h.ncols, h.nrows])'; fclose(fid);
A(A == h.nodata_value) = NaN;
end

function img_index(ax, K, valid, CMAP)
RGB = ones([size(K),3]);
for k = 1:size(CMAP,1)
    m = valid & K == k;
    for c = 1:3
        ch = RGB(:,:,c); ch(m) = CMAP(k,c); RGB(:,:,c) = ch;
    end
end
image(ax,RGB); axis(ax,'image'); set(ax,'XTick',[],'YTick',[],'Box','on','LineWidth',0.35);
end

function img_scalar(ax, A, valid, lim, cmap)
n = size(cmap,1);
t = min(max((A-lim(1))/(lim(2)-lim(1)),0),1);
idx = round(t*(n-1))+1;
RGB = ones([size(A),3]); ok = valid & isfinite(idx);
for c = 1:3
    ch = RGB(:,:,c); ch(ok) = cmap(idx(ok),c); RGB(:,:,c) = ch;
end
image(ax,RGB); axis(ax,'image'); set(ax,'XTick',[],'YTick',[],'Box','on','LineWidth',0.35);
end

function C = index_map()
% low index in deep blue through the class colours to dark red at high index,
% so that the continuous panel reads on the same scale as the class panel
a = [0.24 0.44 0.68; 0.55 0.75 0.86; 0.95 0.93 0.70; 0.96 0.68 0.38; 0.78 0.24 0.22];
x = linspace(0,1,size(a,1)); xi = linspace(0,1,256);
C = [interp1(x,a(:,1),xi)', interp1(x,a(:,2),xi)', interp1(x,a(:,3),xi)'];
end
