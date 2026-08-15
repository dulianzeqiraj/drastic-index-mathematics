% collect_results
% Gathers the m01..m07 result structs into matlab_verifikimi.json.
[~, RES] = paths_repo();
out = struct();
files = {'m01_rez.mat', 'm02_rez.mat', 'm03_rez.mat', 'm04_rez.mat', ...
         'm05_rez.mat', 'm06_rez.mat', 'm07_rez.mat'};
names = {'rez01', 'rez02', 'rez03', 'rez04', 'rez05', 'rez06', 'rez07'};
for i = 1:numel(files)
    fp = fullfile(RES, files{i});
    if isfile(fp)
        s = load(fp);
        out.(names{i}) = s.(names{i});
    end
end
out.matlab_version = version;
txt = jsonencode(out, 'PrettyPrint', true);
fid = fopen(fullfile(RES, 'matlab_verifikimi.json'), 'w');
fwrite(fid, txt);
fclose(fid);
fprintf('results/matlab_verifikimi.json written\n');
