% m14_figure_voi
% Figure 4: the preposterior value of ten new monitoring stations, by aquifer family.
%
% Panel (a) gives the mean reduction of the undecided share with its 95 percent
% interval, against the share undecided before the stations are added. Panel (b) gives
% the rehearsals behind each mean, because the spread is the result: one rehearsal, or
% two, can land almost anywhere in the alluvial family.
%
% Requires m06_dense.mat from m06_voi_dense.m.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.

[~, RES] = paths_repo();
FIGDIR = fullfile(RES, 'figures_model');
if ~isfolder(FIGDIR), mkdir(FIGDIR); end
MM = 1/25.4; DPI = '-r600';

S = load(fullfile(RES, 'm06_dense.mat'));
rez = S.rez; allred = S.allred;                    % families x rehearsals, in points
FAMS = {'aluvional','karbonatik','magmatik','flish_argjile'};
LBL  = {'alluvial','carbonate','magmatic','flysch'};
nf = numel(FAMS);
m = zeros(1,nf); lo = zeros(1,nf); hi = zeros(1,nf); base = 100*rez.baza_pavendosur;
for f = 1:nf
    q = rez.(FAMS{f});
    m(f) = q.mesatare_pp; lo(f) = q.ci95_pp(1); hi(f) = q.ci95_pp(2);
end
fprintf('rehearsals per family: %d\n', rez.reps);
for f = 1:nf
    fprintf('%-16s base undecided %5.1f%%   value %6.2f pp  (95%% CI %5.2f to %5.2f)\n', ...
            LBL{f}, base(f), m(f), lo(f), hi(f));
end

W = 190*MM; H = 96*MM;
f1 = figure('Units','inches','Color','w');
set(f1,'Position',[1 1 W H],'PaperUnits','inches','PaperPosition',[0 0 W H],'PaperSize',[W H]);

COL  = [0.16 0.34 0.60];
COLB = [0.72 0.76 0.82];

ax = axes('Position',[0.075 0.175 0.40 0.665]); hold(ax,'on');
b = bar(ax, 1:nf, base, 0.62); set(b,'FaceColor',COLB,'EdgeColor','none');
for f = 1:nf
    plot(ax, [f f], [base(f)-hi(f) base(f)-lo(f)], '-', 'Color', COL, 'LineWidth', 1.4);
    plot(ax, f, base(f)-m(f), 'o', 'MarkerFaceColor', COL, 'MarkerEdgeColor','none', ...
         'MarkerSize', 5);
    text(ax, f+0.19, base(f)-m(f), sprintf('-%.1f', m(f)), ...
         'HorizontalAlignment','left', 'VerticalAlignment','middle', ...
         'FontSize', 9.6, 'Color', COL);
end
set(ax,'XTick',1:nf,'XTickLabel',LBL,'FontSize',9.6,'Box','on','TickDir','out', ...
       'YLim',[0 104],'XLim',[0.4 nf+0.6],'YGrid','on','GridAlpha',0.12);
ylabel(ax,'undecided share of the family (%)','FontSize',10.2);
title(ax,'(a) where ten stations leave the family','FontSize',10.8,'FontWeight','normal');
annotation(f1,'textbox',[0.055 0.885 0.90 0.105],'String', ...
    {'grey bar: undecided now.  marker and whisker: after ten stations, mean and 95% interval.', ...
     'figure beside the marker: the reduction'}, ...
    'HorizontalAlignment','left','VerticalAlignment','bottom','EdgeColor','none', ...
    'FontSize',8.4,'Color',[0.35 0.35 0.35]);

ax2 = axes('Position',[0.555 0.175 0.385 0.665]); hold(ax2,'on');
rng(3,'twister');
for f = 1:nf
    v = allred(f,:) * 100;
    jit = (rand(1,numel(v)) - 0.5) * 0.34;
    plot(ax2, f + jit, v, 'o', 'MarkerFaceColor', COL, 'MarkerEdgeColor','none', ...
         'MarkerSize', 3.1);
    plot(ax2, [f-0.28 f+0.28], [m(f) m(f)], '-', 'Color', [0.78 0.24 0.22], 'LineWidth', 1.6);
end
plot(ax2, [0.35 nf+0.95], [0 0], ':', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.8);
set(ax2,'XTick',1:nf,'XTickLabel',LBL,'FontSize',9.6,'Box','on','TickDir','out', ...
        'XLim',[0.35 nf+0.95],'YGrid','on','GridAlpha',0.12);
ylabel(ax2,'reduction of the undecided share (points)','FontSize',10.2);
title(ax2,sprintf('(b) the %d rehearsals behind each mean', rez.reps), ...
      'FontSize',10.8,'FontWeight','normal');

print(f1, fullfile(FIGDIR,'figure4_voi'), '-dpng', DPI);
close(f1);
fprintf('figure 4 written\n');
