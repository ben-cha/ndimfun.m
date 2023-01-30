function output = dim3fun(FUN,data, varargin)
p = inputParser;

addRequired(p, 'FUN', @(x) isa(x,'function_handle'))
addRequired(p, 'data', @(x) iscell(x) || (~ismatrix(x) && ndims(data)==3))
parse(p,FUN, data);
FUN     = p.Results.FUN;
data    = p.Results.data;
sz = size(data);

cellflag = iscell(data);
matflag = (~ismatrix(data) && ndims(data)==3);

if cellflag % use cellfun if input is cell
    output = cellfun(FUN, data, varargin{:}, 'uniformoutput', false);
elseif matflag
    varargs = cell(1:nargin-2);
    % tried to pre-allocate output size, but not worth trying to implement for operations that use multiple inputs and have a different output size
    try % try using pagefun
        output = pagefun(FUN, data, varargin);
    catch % use for-loop if not
        for i = 1:sz(3)
            for j = 1:nargin-2
                varargs{j} = varargin{j}(:,:,i);
            end
            output(:,:,i) = FUN(data(:,:,i), varargs{:});
        end
    end
end

end
