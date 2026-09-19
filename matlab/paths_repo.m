
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
function [dataDir, resDir, figDir] = paths_repo()
% Repository layout resolved from this file's own location, so the scripts
% run correctly whatever the current working directory is.
here = fileparts(mfilename('fullpath'));
dataDir = fullfile(here, '..', 'data');
resDir  = fullfile(here, '..', 'results');
figDir  = fullfile(resDir, 'figures');
if ~isfolder(resDir), mkdir(resDir); end
if ~isfolder(figDir), mkdir(figDir); end
end
