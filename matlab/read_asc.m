
%
% A. Beqiraj and D. Zeqiraj, Faculty of Geology and Mining,
% Polytechnic University of Tirana. MIT licence, see LICENSE.
function A = read_asc(path)
% Read an Arc ASCII grid (6 header lines, NODATA -9999) into a matrix.
A = readmatrix(path, 'FileType', 'text', 'NumHeaderLines', 6);
end
