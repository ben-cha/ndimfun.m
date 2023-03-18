function output = ndimfun(FUN,data, varargin)
p = inputParser;

ndim = ndims(data);
cellcond = @(x) iscell(x);

% identify if vector
matcond = @(x) sum(size(x))-1<numel(x); % isnumeric(x)

% must be a valid dimension
dimcond = @(x) numel(x)==1 && rem(x,1)==0 && x > 0 && x <= ndim;

addRequired(p, 'FUN', @(x) isa(x,'function_handle'))
addRequired(p, 'data', @(x) numel(x)>1); % @(x) cellcond(x) || matcond(x)
addParameter(p, 'dim', [], @(x) dimcond(x));
if isempty(varargin) || ~isequal(varargin{end-1}, 'dim')
    parse(p,FUN, data);
else
    parse(p,FUN, data, varargin{end-1:end});
    varargin = varargin(1:end-2);
end
FUN     = p.Results.FUN;
data    = p.Results.data;
dim     = p.Results.dim;

sz = size(data);

cellflag = cellcond(data);
matflag = matcond(data);

if cellflag
    output = cellfun(FUN, data, varargin{:}, 'uniformoutput', false);
else
    if ~matflag
        notone = find(size(data)-1,1); % find first dim that isn't 1
        if isempty(dim) && notone ~= ndim
            dim = notone;
        end
    end
    shifted = false;
    if ~isempty(dim) && dim~=ndim
        nshift = dim - ndim;
        data = shiftdim(data,nshift);
        for k = 1:numel(varargin)
            varargin{k}=shiftdim(varargin{k}, nshift);
        end
        shifted = true;
    end
    firstdims = repmat({':'},1,ndims(data)-1);
    if isempty(dim)
        varargs = cell(1:nargin-2);
    else
        varargs = cell(1:nargin-4);
    end
    try
        output = pagefun(FUN, data, varargin);
    catch
        % number of arguments for function "FUN"
        if isempty(dim)
            nvarargs = nargin-2;
        else
            nvarargs = nargin-4;
        end
        output = cell(sz(end),1);
        for i = 1:sz(end)
            % the arguments to be input into "FUN"
            for j = 1:nvarargs
                varargs{j} = varargin{j}(firstdims{:},i);
            end
            try
                output{i}=FUN(data(firstdims{:},i), varargs{:});
            catch
                output{i}=[];
            end
%             if i == 1 % pre-allocate
%                 temp = FUN(data(firstdims{:},i), varargs{:});
%                 szOut = size(temp);
%                 output = zeros(szOut);
%                 if isequal(class(temp),'sym'), output=sym(output); end
%                 output(firstdims{:},i)=temp;
%             else
%                 output(firstdims{:},i) = FUN(data(firstdims{:},i), varargs{:});
%             end
        end
    end
    if shifted
        output = cellfun(@(x) shiftdim(x,-nshift),output, 'UniformOutput',false);
%         output = shiftdim(output,-nshift);
    end
end

end