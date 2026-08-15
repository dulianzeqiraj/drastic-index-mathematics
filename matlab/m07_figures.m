% m07_figures
% The three manuscript figures:
%   fig1_five_layers.png        conceptual scheme of the five-layer identity
%   fig2_arrangement_slice.png  2D section of the threshold hyperplane arrangement
%   fig3_probability_field.png  posterior modal class and its probability, national grid
% Requires: profilet.mat (m01), m04_fig.mat (m04).

[~, RES, FIG] = paths_repo();
W = [5 4 3 2 1 5 3];
THR = [55 90 125 160];

% ---------- Figure 1: the five-layer scheme ----------
f1 = figure('Units', 'inches', 'Position', [0 0 8.2 5.8], 'Color', 'w', 'Visible', 'off');
ax = axes(f1, 'Position', [0 0 1 1]); axis(ax, [0 100 -3 74.5]); axis off; hold on;
rows = {
 'I  MEASUREMENT', 'Hazard preorder on the finite profile set. An additive index exists iff a finite linear program is feasible; infeasibility returns a Farkas certificate naming the culpable judgments (Theorem 1).', 'Formulated for the national stack; panel elicitation is program item 1.'
 'II  STRUCTURE', 'Seven ratings as lenses on one geological state. What data can identify is the quotient of weight space by the gauge of the attainable profiles (Theorem 2).', 'Rank 7 nationally; rank 5 in the alluvial family: A, R, C confounded.'
 'III  GEOMETRY', 'The weight simplex is cut by threshold hyperplanes into chambers; each chamber is one national class map; margins measure distance to a class flip (Props. 3, 9).', '49,547 hyperplanes; 3 profiles exactly on thresholds; redesign lifts the minimum margin 0 to 0.225.'
 'IV  INFERENCE', 'Hierarchical posterior with the 1987 consensus as prior; contraction exactly on the excited subspace, prior return on the gauge (Props. 4-7).', 'sigma = 6.86 mg/L; 3,000 distinct class maps in 3,000 draws; field p_k(x).'
 'V  DECISION', 'The class-probability field is sufficient for every class-based decision; monitoring is priced by preposterior analysis (Prop. 8).', '10 stations buy 18.9 pp of class certainty (alluvial), 4.9 (flysch), 0.9 (carbonate).'
};
yTop = 70; hBox = 12.4; gap = 1.9;
colL = [0.88 0.91 0.96];
colM = [0.965 0.965 0.965];
colR = [0.93 0.96 0.90];
for i = 1:5
    y = yTop - i * (hBox + gap) + hBox;
    rectangle('Position', [1, y - hBox, 16, hBox], 'FaceColor', colL, 'EdgeColor', [0.3 0.3 0.3]);
    text(9, y - hBox/2, rows{i, 1}, 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 9.5);
    rectangle('Position', [18, y - hBox, 46, hBox], 'FaceColor', colM, 'EdgeColor', [0.3 0.3 0.3]);
    text(19.2, y - hBox/2, textwrap_local(rows{i, 2}, 62), 'FontSize', 8.6, ...
        'VerticalAlignment', 'middle');
    rectangle('Position', [66, y - hBox, 33, hBox], 'FaceColor', colR, 'EdgeColor', [0.3 0.3 0.3]);
    text(67.2, y - hBox/2, textwrap_local(rows{i, 3}, 42), 'FontSize', 8.6, ...
        'VerticalAlignment', 'middle');
    if i < 5
        plot([9 9], [y - hBox - 0.2, y - hBox - gap + 0.2], 'k-', 'LineWidth', 1.1);
        plot(9, y - hBox - gap + 0.35, 'kv', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
    end
end
text(18, yTop + 1.6, 'the mathematical object', 'FontSize', 9, 'FontAngle', 'italic');
text(66, yTop + 1.6, 'computed on the Albanian instance', 'FontSize', 9, 'FontAngle', 'italic');
exportgraphics(f1, fullfile(FIG, 'fig1_five_layers.png'), 'Resolution', 300);
close(f1);
fprintf('fig1 written\n');

% ---------- Figure 2: 2D section of the threshold arrangement ----------
load(fullfile(RES, 'profilet.mat'), 'Runiq', 'counts');
DIu = Runiq * W';
marg = min(abs(DIu - THR), [], 2);
onthr = find(marg == 0);

f2 = figure('Units', 'inches', 'Position', [0 0 6.4 5.6], 'Color', 'w', 'Visible', 'off');
hold on; axis equal off;
V = [0 0; 14 0; 7 14*sqrt(3)/2];      % vertices in plot coords: wD=14, wR=14, wI=14
plot([V(1,1) V(2,1) V(3,1) V(1,1)], [V(1,2) V(2,2) V(3,2) V(1,2)], 'k-', 'LineWidth', 1.2);

rng(11, 'twister');
cp = cumsum(counts) / sum(counts);
picks = zeros(40, 1);
for t = 1:40
    picks(t) = find(rand <= cp, 1);
end
picks = unique(picks);
nseg = 0;
for t = 1:numel(picks)
    r = Runiq(picks(t), :);
    for k = 1:4
        seg = slice_segment(r, THR(k));
        if ~isempty(seg)
            plot(seg(:, 1), seg(:, 2), '-', 'Color', [0.55 0.55 0.55 0.55], 'LineWidth', 0.5);
            nseg = nseg + 1;
        end
    end
end
non = 0;
for t = 1:numel(onthr)
    r = Runiq(onthr(t), :);
    [~, kmin] = min(abs(r * W' - THR));
    seg = slice_segment(r, THR(kmin));
    if ~isempty(seg)
        plot(seg(:, 1), seg(:, 2), 'r-', 'LineWidth', 1.6);
        non = non + 1;
    end
end
pD = [5 4 5];                          % Delphi (w_D, w_R, w_I)
pxy = [pD(2) + pD(3)/2, pD(3)*sqrt(3)/2];
plot(pxy(1), pxy(2), 'o', 'MarkerSize', 7, 'MarkerFaceColor', [0.85 0.1 0.1], ...
    'MarkerEdgeColor', 'k', 'LineWidth', 0.8);
text(pxy(1) + 0.35, pxy(2) + 0.35, 'w^{De}', 'FontSize', 11);
text(V(1,1) - 0.4, V(1,2) - 0.55, 'w_D = 14', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(V(2,1) + 0.4, V(2,2) - 0.55, 'w_R = 14', 'FontSize', 10, 'HorizontalAlignment', 'center');
text(V(3,1), V(3,2) + 0.55, 'w_I = 14', 'FontSize', 10, 'HorizontalAlignment', 'center');
exportgraphics(f2, fullfile(FIG, 'fig2_arrangement_slice.png'), 'Resolution', 300);
close(f2);
fprintf('fig2 written: %d gray segments from %d sampled profiles, %d on-threshold lines in red\n', ...
    nseg, numel(picks), non);
rez07 = struct('fig2_profile_mostruar', numel(picks), 'fig2_segmente', nseg, ...
               'fig2_vija_mbi_prag', non);

% ---------- Figure 3: the posterior probability field ----------
load(fullfile(RES, 'm04_fig.mat'), 'Pmax_grid', 'Kmod_grid');
ds = 3;
Kg = Kmod_grid(1:ds:end, 1:ds:end);
Pg = Pmax_grid(1:ds:end, 1:ds:end);
pal = [1 1 1; 0.10 0.59 0.25; 0.65 0.85 0.42; 1.00 1.00 0.55; 0.99 0.68 0.38; 0.84 0.10 0.11];
f3 = figure('Units', 'inches', 'Position', [0 0 7.4 6.6], 'Color', 'w', 'Visible', 'off');
t = tiledlayout(f3, 1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
ax1 = nexttile(t);
img = ind2rgb_local(Kg + 1, pal);
image(ax1, img); axis(ax1, 'image'); axis(ax1, 'off');
title(ax1, '(a) posterior modal class', 'FontSize', 10, 'FontWeight', 'normal');
hold(ax1, 'on');
lbl = {'very low', 'low', 'moderate', 'high', 'very high'};
hh = gobjects(1, 5);
for k = 1:5
    hh(k) = patch(ax1, NaN, NaN, pal(k + 1, :), 'EdgeColor', [0.4 0.4 0.4]);
end
legend(ax1, hh, lbl, 'Location', 'southwest', 'FontSize', 7.5, 'Box', 'off');
ax2 = nexttile(t);
imagesc(ax2, Pg, 'AlphaData', ~isnan(Pg));
set(ax2, 'Color', 'w', 'CLim', [0.2 1]);
axis(ax2, 'image'); axis(ax2, 'off'); colormap(ax2, parula);
cb = colorbar(ax2, 'southoutside');
cb.Label.String = 'P(modal class)';
cb.Label.FontSize = 9;
title(ax2, '(b) probability of the modal class', 'FontSize', 10, 'FontWeight', 'normal');
exportgraphics(f3, fullfile(FIG, 'fig3_probability_field.png'), 'Resolution', 300);
close(f3);
fprintf('fig3 written\n');
save(fullfile(RES, 'm07_rez.mat'), 'rez07');
fprintf('m07 done.\n');

% ---------- local functions ----------
function seg = slice_segment(r, c)
% Intersection of the hyperplane <w, r> = c with the 2D slice
% w_A=3, w_S=2, w_T=1, w_C=3 fixed, w_D + w_R + w_I = 14, in plot coords.
rD = r(1); rR = r(2); rI = r(6);
rhs = c - (3*r(3) + 2*r(4) + 1*r(5) + 3*r(7)) - 14*rD;
a1 = rR - rD; a2 = rI - rD;
P = [];
if abs(a2) > 1e-12
    for wR = [0 14]
        wI = (rhs - a1*wR) / a2;
        if wI >= -1e-9 && wR + wI <= 14 + 1e-9
            P(end+1, :) = [wR wI]; %#ok<AGROW>
        end
    end
end
if abs(a1) > 1e-12
    wI = 0; wR = rhs / a1;
    if wR >= -1e-9 && wR <= 14 + 1e-9
        P(end+1, :) = [wR wI]; %#ok<AGROW>
    end
end
if abs(a1 - a2) > 1e-12
    % edge w_R + w_I = 14
    wR = (rhs - 14*a2) / (a1 - a2); wI = 14 - wR;
    if wR >= -1e-9 && wI >= -1e-9
        P(end+1, :) = [wR wI]; %#ok<AGROW>
    end
end
if size(P, 1) < 2
    seg = [];
    return
end
P = unique(round(P, 9), 'rows');
if size(P, 1) < 2
    seg = [];
    return
end
P = P(1:2, :);
seg = [P(:, 1) + P(:, 2)/2, P(:, 2)*sqrt(3)/2];
end

function img = ind2rgb_local(idx, pal)
idx(isnan(idx)) = 1;
idx = max(1, min(size(pal, 1), round(idx)));
img = zeros([size(idx) 3]);
for ch = 1:3
    col = pal(:, ch);
    img(:, :, ch) = col(idx);
end
end

function out = textwrap_local(s, width)
% simple greedy wrap to a cell array of lines
words = strsplit(s, ' ');
out = {};
line = '';
for i = 1:numel(words)
    if isempty(line)
        line = words{i};
    elseif numel(line) + 1 + numel(words{i}) <= width
        line = [line ' ' words{i}]; %#ok<AGROW>
    else
        out{end+1} = line; %#ok<AGROW>
        line = words{i};
    end
end
out{end+1} = line;
end
