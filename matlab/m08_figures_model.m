% m08_figures_model
% Figure 3: the deployed national map in four panels, the modal class, the posterior
% probability of that class, the undecided surface at alpha = 0.7, and the disagreement
% with the 1987 classification computed on identical ratings.
%
% The surfaces are read from the archived national deployment, the run whose numbers
% the manuscript quotes. The archive is opened read only; output goes to
% results/figures_model.
%
% Sizes follow Journal of Hydrology: 190 mm full width. Position equals PaperPosition,
% and each map axes is given the aspect ratio of the data, so that what is drawn is
% what is printed and no panel carries dead margin.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

ARC  = 'C:\Users\d_zeq\OneDrive\Desktop\ARJAN I NDERUAR\Nxjerrja_Rasterave_2026-08-12';
[~, RES] = paths_repo();
FIGDIR = fullfile(RES, 'figures_model');
if ~isfolder(FIGDIR), mkdir(FIGDIR); end
MM = 1/25.4; DPI = '-r600';

fprintf('reading archived surfaces...\n');
Kmod  = read_asc_full(fullfile(ARC, 'BAYES_klasa_modale_100m.asc'));
Pmod  = read_asc_full(fullfile(ARC, 'BAYES_P_klasa_modale_100m.asc'));
DIsak = read_asc_full(fullfile(ARC, 'SAKTE_DI_100m.asc'));

valid = isfinite(Kmod) & isfinite(Pmod) & isfinite(DIsak);
rows = find(any(valid,2)); cols = find(any(valid,1));
cr = @(A) A(rows(1):rows(end), cols(1):cols(end));
Kmod = cr(Kmod); Pmod = cr(Pmod); DIsak = cr(DIsak); valid = cr(valid);
[nr, nc] = size(Kmod); ASP = nr/nc;
tot = nnz(valid);
fprintf('valid cells %d (%.1f km2); cropped %d x %d; aspect %.3f\n', ...
        tot, tot/100, nr, nc, ASP);

THR = [55 90 125 160];
Kdel = nan(size(DIsak)); Kdel(valid) = klasa_di(DIsak(valid), THR);

u70 = nnz(valid & Pmod < 0.7); c90 = nnz(valid & Pmod >= 0.9);
D = nan(size(Kmod)); D(valid) = 2 + sign(Kmod(valid) - Kdel(valid));
up = nnz(D==3); dn = nnz(D==1); sm = nnz(D==2);
fprintf('undecided at 0.7 %.1f%%; certain at 0.9 %.1f%%; mean p %.3f\n', ...
        100*u70/tot, 100*c90/tot, mean(Pmod(valid)));
fprintf('class up %.1f%%, down %.1f%%, same %.1f%%, differs %.1f%%\n', ...
        100*up/tot, 100*dn/tot, 100*sm/tot, 100*(up+dn)/tot);

CLS  = [0.24 0.44 0.68; 0.55 0.75 0.86; 0.95 0.93 0.70; 0.96 0.68 0.38; 0.78 0.24 0.22];
PMAP = prob_map();
UND  = [0.78 0.24 0.22; 0.88 0.88 0.88];
DIFF = [0.20 0.40 0.65; 0.90 0.90 0.90; 0.78 0.24 0.22];

% geometry, in millimetres, then normalised
Wmm = 190; mL = 3; mR = 3; gap = 4;
fwmm = (Wmm - mL - mR - 3*gap) / 4;
phmm = fwmm * ASP;
tHmm = 6;      % title band
cbHmm = 2.6;   % colour bar
lbHmm = 11;    % tick labels and colour-bar label
Hmm = phmm + tHmm + cbHmm + lbHmm + 3;

W = Wmm*MM; H = Hmm*MM;
f = figure('Units','inches','Color','w');
set(f,'Position',[1 1 W H],'PaperUnits','inches','PaperPosition',[0 0 W H],'PaperSize',[W H]);

pb  = (lbHmm + cbHmm + 1.5)/Hmm;
phn = phmm/Hmm;
pw  = fwmm/Wmm;
cby = (lbHmm - 2)/Hmm;
cbh = cbHmm/Hmm;
lefts = (mL + (0:3)*(fwmm+gap)) / Wmm;

% (a) modal class
ax = axes('Position',[lefts(1) pb pw phn]);
img_index(ax, Kmod, valid, CLS);
title(ax,'(a) modal class','FontSize',9.6,'FontWeight','normal');
colormap(ax,CLS); clim(ax,[0.5 5.5]);
cb = colorbar(ax,'southoutside','Position',[lefts(1) cby pw cbh]);
set(cb,'Ticks',1:5,'FontSize',8.4); cb.Label.String='vulnerability class'; cb.Label.FontSize=8.4;

% (b) probability of the modal class
ax = axes('Position',[lefts(2) pb pw phn]);
img_scalar(ax, Pmod, valid, [0.2 1.0], PMAP);
title(ax,'(b) probability of (a)','FontSize',9.6,'FontWeight','normal');
colormap(ax,PMAP); clim(ax,[0.2 1.0]);
cb = colorbar(ax,'southoutside','Position',[lefts(2) cby pw cbh]);
set(cb,'Ticks',[0.2 0.6 0.7 1.0],'FontSize',8.4);
cb.Label.String='p_{modal}'; cb.Label.FontSize=8.4;

% (c) undecided at alpha = 0.7
U = nan(size(Pmod)); U(valid) = 1 + (Pmod(valid) >= 0.7);
ax = axes('Position',[lefts(3) pb pw phn]);
img_index(ax, U, valid, UND);
title(ax,sprintf('(c) undecided, \\alpha = 0.7'),'FontSize',9.6,'FontWeight','normal');
colormap(ax,UND); clim(ax,[0.5 2.5]);
cb = colorbar(ax,'southoutside','Position',[lefts(3) cby pw cbh]);
set(cb,'Ticks',[1 2],'TickLabels',{sprintf('%.1f%%',100*u70/tot), ...
    sprintf('%.1f%%',100*(tot-u70)/tot)},'FontSize',8.4);
cb.Label.String='undecided / decided'; cb.Label.FontSize=8.4;

% (d) against the consensus
ax = axes('Position',[lefts(4) pb pw phn]);
img_index(ax, D, valid, DIFF);
title(ax,'(d) against Delphi','FontSize',9.6,'FontWeight','normal');
colormap(ax,DIFF); clim(ax,[0.5 3.5]);
cb = colorbar(ax,'southoutside','Position',[lefts(4) cby pw cbh]);
set(cb,'Ticks',1:3,'TickLabels',{sprintf('%.1f%%',100*dn/tot), ...
    sprintf('%.1f%%',100*sm/tot), sprintf('%.1f%%',100*up/tot)},'FontSize',8.4);
cb.Label.String='lower / same / higher'; cb.Label.FontSize=8.4;

print(f, fullfile(FIGDIR,'figure3_map'), '-dpng', DPI);
close(f); fprintf('figure 3 written (%.0f x %.0f mm)\n', Wmm, Hmm);
fprintf('m08 done.\n');

%% ---------------------------------------------------------------- helpers
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

function C = prob_map()
% dark red at low probability through amber and pale to deep blue at high:
% the contested surface is what the reader should see first
a = [0.60 0.09 0.09; 0.90 0.42 0.17; 0.97 0.85 0.55; 0.62 0.78 0.82; 0.11 0.27 0.50];
x = linspace(0,1,size(a,1)); xi = linspace(0,1,256);
C = [interp1(x,a(:,1),xi)', interp1(x,a(:,2),xi)', interp1(x,a(:,3),xi)'];
end
