# dim3fun
Like cellfun and pagefun, but indifferent to which. If input is a cell, use cellfun; if input is multi-page array, try pagefun / catch for-loop. 

Sometimes cellfun, pagefun, and for-loops can be used interchangeably granted the data is formatted correctly for the use-case. 
I got annoyed having to write new loops every time I decided one format was better than the other, so I just smashed it all together into one function.
Good for testing optimization of your code based on which version of the function you use. 

Only works on intensity images for now. 

## Example: Image processing
Say you want to use @rot90 on a set of 20 intensity images of size 10 x 10. 
You then may have a matrix of said imageset with size [10 10 20] or a cell of length 20 arrays of size [10 10]
You might be wondering if it's computationally worth it to convert your imageset to a gpuArray and use pagefun or to just use cellfun
Use dim3fun to compare the processing times

```
dirs = fullfile({dir([fileparts(which('kobi.png')), '\AT3*.tif']).folder}, {dir([fileparts(which('kobi.png')), '\AT3*.tif']).name});
A = cellfun(@(x) im2gray(imread(x)), dirs, 'uniformoutput', false);
profile clear
profile on
a = dim3fun(@rot90, A);
c = profile('info');
profile off
profile clear
profile on
sz = size(A{1});
B = gpuArray(reshape(cell2mat(A),sz(1), sz(2), []));
b = dim3fun(@rot90, B);
C = profile('info');
profile off

disp(['cellfun time: ' num2str(sum([c.FunctionTable.TotalTime])) ' s'])
disp(['gpuArray time: ' num2str(sum([C.FunctionTable.TotalTime])) ' s'])
```
