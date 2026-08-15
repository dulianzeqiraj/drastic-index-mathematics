function setup_data()
% Decompress the archived rating rasters shipped with the repository.
% The grids are stored gzipped (3.2 MB instead of 201 MB); this expands any
% ../data/*.asc.gz whose .asc is missing. Safe to call repeatedly: files
% already expanded are left alone. Uses base MATLAB gunzip, no toolboxes.
here = fileparts(mfilename('fullpath'));
dd = fullfile(here, '..', 'data');
gz = dir(fullfile(dd, '*.asc.gz'));
todo = {};
for i = 1:numel(gz)
    plain = fullfile(dd, gz(i).name(1:end-3));
    if ~isfile(plain)
        todo{end+1} = fullfile(dd, gz(i).name); %#ok<AGROW>
    end
end
if isempty(todo)
    fprintf('setup_data: all %d grids already expanded.\n', numel(gz));
    return
end
fprintf('setup_data: expanding %d of %d grids...\n', numel(todo), numel(gz));
for i = 1:numel(todo)
    gunzip(todo{i}, dd);
end
fprintf('setup_data: done.\n');
end
