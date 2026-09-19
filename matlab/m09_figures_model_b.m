% m09_figures_model_b
% Figures 1 and 2: the alluvial design spectrum with the three rating triples behind
% it, and the posterior weight vectors by aquifer family against the 1987 values.
% Both are drawn from the archived national outputs; the archive is opened read only.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

ARC  = 'C:\Users\d_zeq\OneDrive\Desktop\ARJAN I NDERUAR\Nxjerrja_Rasterave_2026-08-12';
[~, RES] = paths_repo();
FIGDIR = fullfile(RES, 'figures_model');
if ~isfolder(FIGDIR), mkdir(FIGDIR); end
MM = 1/25.4; DPI = '-r600';
PAR = {'D','R','A','S','T','I','C'};
WD  = [5 4 3 2 1 5 3];

S = jsondecode(fileread(fullfile(ARC, 'bayes_permbledhja.json')));
P = S.permbledhja_sum23;
FAMS = {'aluvional','karbonatik','magmatik','flish_argjile'};
LBL  = {'alluvial (n = 59)','carbonate','magmatic','flysch and clay'};

%% ---------------------------------------------------------------- Figure 3
f = figure('Units','inches','Color','w');
W = 190*MM; H = 100*MM;
set(f,'Position',[1 1 W H],'PaperUnits','inches','PaperPosition',[0 0 W H],'PaperSize',[W H]);

COL = [0.16 0.34 0.60; 0.55 0.55 0.55; 0.55 0.55 0.55; 0.55 0.55 0.55];
for fi = 1:4
    ax = axes('Position',[0.055 + (fi-1)*0.234, 0.165, 0.188, 0.70]); %#ok<LAXES>
    hold(ax,'on');
    for p = 1:7
        q = P.(FAMS{fi}).(PAR{p});
        y = 8 - p;
        plot(ax, q.ci95, [y y], '-', 'Color', COL(fi,:), 'LineWidth', 1.1);
        plot(ax, q.ci95(1), y, '|', 'Color', COL(fi,:), 'MarkerSize', 4);
        plot(ax, q.ci95(2), y, '|', 'Color', COL(fi,:), 'MarkerSize', 4);
        plot(ax, q.mediana, y, 'o', 'MarkerFaceColor', COL(fi,:), ...
             'MarkerEdgeColor', 'none', 'MarkerSize', 4.2);
        plot(ax, WD(p), y, 'd', 'MarkerFaceColor', [0.80 0.30 0.15], ...
             'MarkerEdgeColor','none','MarkerSize',4.2);
    end
    set(ax,'YTick',1:7,'YTickLabel',fliplr(PAR),'FontSize',9.6,'Box','on', ...
           'XLim',[0 14],'YLim',[0.4 7.6],'XTick',0:3:12,'TickDir','out', ...
           'YGrid','on','GridAlpha',0.12);
    if fi > 1, set(ax,'YTickLabel',[]); end
    title(ax, LBL{fi}, 'FontSize', 10.2, 'FontWeight', 'normal');
    if fi == 1
        ylabel(ax,'DRASTIC parameter','FontSize',10.2);
        text(ax, 12.6, 7.25, 'Delphi', 'Color', [0.80 0.30 0.15], ...
             'FontSize', 9, 'HorizontalAlignment', 'right');
    end

end
annotation(f,'textbox',[0 0.015 1 0.055],'String', ...
    'sum-23 normalized weight (median and 95 percent credible interval)', ...
    'HorizontalAlignment','center','VerticalAlignment','middle','EdgeColor','none', ...
    'FontSize',10.2);
print(f, fullfile(FIGDIR,'figure2_weights'), '-dpng', DPI);
close(f); fprintf('figure 2 written\n');

%% ---------------------------------------------------------------- Figure 5
pts = jsondecode(fileread(fullfile(ARC, 'kalibrimi_62_pika.json')));
if ~iscell(pts), pts = num2cell(pts); end
n = numel(pts);
R = zeros(n,7); famname = cell(n,1);
for i = 1:n
    for p = 1:7, R(i,p) = pts{i}.rates.(PAR{p}); end
    famname{i} = pts{i}.familja;
end
al = strcmp(famname,'aluvional');
Xf = R(al,:) - mean(R(al,:),1);
Sf = Xf'*Xf / sum(al);
[V,Dg] = eig(Sf); [ev,ix] = sort(diag(Dg),'descend'); V = V(:,ix);
ev(ev < 1e-12) = 0;
fprintf('alluvial spectrum: %s (rank %d)\n', mat2str(round(ev',4)), rank(Xf));

f = figure('Units','inches','Color','w');
W = 190*MM; H = 78*MM;
set(f,'Position',[1 1 W H],'PaperUnits','inches','PaperPosition',[0 0 W H],'PaperSize',[W H]);

ax = axes('Position',[0.065 0.155 0.40 0.72]); hold(ax,'on');
b1 = bar(ax, 1:5, ev(1:5), 0.62); set(b1,'FaceColor',[0.16 0.34 0.60],'EdgeColor','none');
b2 = bar(ax, 6:7, [0.06 0.06], 0.62); set(b2,'FaceColor',[0.85 0.85 0.85],'EdgeColor','none');
text(ax, 6.5, 0.42, 'kernel', 'HorizontalAlignment','center','FontSize',9.6, ...
     'Color',[0.35 0.35 0.35]);
for j = 1:5
    text(ax, j, ev(j)+0.22, sprintf('%.2f', ev(j)), 'HorizontalAlignment','center','FontSize',9);
end
set(ax,'XTick',1:7,'FontSize',9.6,'Box','on','TickDir','out','YLim',[0 8.2],'XLim',[0.4 7.6]);
xlabel(ax,'eigenvalue index j','FontSize',10.2);
ylabel(ax,'\lambda_j of the within-family rating covariance','FontSize',10.2);
title(ax,'(a) alluvial design spectrum: rank five of seven','FontSize',9.6,'FontWeight','normal');

ax2 = axes('Position',[0.575 0.155 0.375 0.72]); hold(ax2,'on');
Rl = R(al,:);
[trip,~,ic] = unique(Rl(:,[3 2 7]),'rows');       % A, R, C
cnt = accumarray(ic,1);
COL2 = [0.16 0.34 0.60; 0.80 0.45 0.15; 0.30 0.55 0.30];
for t = 1:size(trip,1)
    plot(ax2, [1 2 3], trip(t,:), '-o', 'Color', COL2(t,:), 'MarkerFaceColor', COL2(t,:), ...
         'MarkerEdgeColor','none','LineWidth',1.3,'MarkerSize',5);
    text(ax2, 3.08, trip(t,3), sprintf('n = %d', cnt(t)), 'FontSize',9,'Color',COL2(t,:));
end
set(ax2,'XTick',1:3,'XTickLabel',{'A','R','C'},'FontSize',9.6,'Box','on','TickDir','out', ...
        'XLim',[0.75 3.55],'YLim',[5 11],'YGrid','on','GridAlpha',0.12);
xlabel(ax2,'rating layer','FontSize',10.2);
ylabel(ax2,'rating value','FontSize',10.2);
title(ax2,'(b) the whole alluvial design holds three (A, R, C) triples', ...
      'FontSize',9.6,'FontWeight','normal');

print(f, fullfile(FIGDIR,'figure1_spectrum'), '-dpng', DPI);
close(f); fprintf('figure 1 written\n');
fprintf('m09 done.\n');
