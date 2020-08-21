%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = mergevector(x, y)
assert(isequal(size(x), size(y)));
for i=1:numel(x)
    if isnumeric(x) && isnumeric(y) && isnan(x(i)) && ~isnan(y(i))
        x(i) = y(i);
    end
    if iscell(x) && iscell(y) && isempty(x{i}) && ~isempty(y{i})
        x{i} = y{i};
    end
    if iscell(x) && isnumeric(y) && isempty(x{i}) && ~isnan(y{i})
        x{i} = y(i);
    end
end
