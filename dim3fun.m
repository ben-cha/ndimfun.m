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

if cellflag
    output = cellfun(FUN, data, varargin{:}, 'uniformoutput', false);
elseif matflag
    varargs = cell(1:nargin-2);
    try
        output = pagefun(FUN, data, varargin);
    catch
        for i = 1:sz(3)
            for j = 1:nargin-2
                varargs{j} = varargin{j}(:,:,i);
            end
            if i == 1 % pre-allocate
                temp = FUN(data(:,:,i), varargs{:});
                szOut = size(temp);
                output = zeros(szOut);
                output(:,:,i)=temp;
            else
                output(:,:,i) = FUN(data(:,:,i), varargs{:});
            end
        end
    end
end

end
