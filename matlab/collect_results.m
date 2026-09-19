% collect_results
% Gathers every result struct, original and revision, into matlab_verifikimi.json.
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
[~, RES] = paths_repo();
out = struct();
files = {'m01_rez.mat', 'm02_rez.mat', 'm03_rez.mat', 'm04_rez.mat', ...
         'm05_rez.mat', 'm06_rez.mat', 'm07_rez.mat', ...
         'm06_dense.mat', 'm11_rez.mat', 'm12_rez.mat', 'm13_rez.mat'};
names = {'rez01', 'rez02', 'rez03', 'rez04', 'rez05', 'rez06', 'rez07', ...
         'voi_dense', 'rez11', 'rez12', 'rez13'};
for i = 1:numel(files)
    fp = fullfile(RES, files{i});
    if isfile(fp)
        s = load(fp);
        if isfield(s, names{i})
            out.(names{i}) = s.(names{i});
        elseif isfield(s, 'rez')
            out.(names{i}) = s.rez;
        end
    end
end
out.matlab_version = version;
txt = jsonencode(out, 'PrettyPrint', true);
fid = fopen(fullfile(RES, 'matlab_verifikimi.json'), 'w');
fwrite(fid, txt);
fclose(fid);
fprintf('results/matlab_verifikimi.json written\n');
