%% |rect2cube| documentation 
% The |rect2cube| function reshapes and permutes a 2D matrix into a 3D cube. 
% |rect2cube| is the complement of <cube2rect_documentation.html |cube2rect|>. 
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  A3 = rect2cube(A2,gridsize)
%  A3 = rect2cube(A2,mask)
% 
%% Description
% 
% |A3 = rect2cube(A2,gridsize)| reshapes 2D matrix |A2| into a 3D matrix whose first
% two dimensions are spatial (e.g., lat x lon or lon x lat) and whose third 
% dimension is time or perhaps ocean depth or some variable along which operations
% are performed. The final dimensions of |A3| are specified by |gridsize|, which 
% may be a complete 3 element array describing |A3|, or gridsize may be just a 2 
% element array containing the first two dimensions of |A3|. 
% 
% |A3 = rect2cube(A2,mask)| reshapes the elements of |A2| into the |true| grid
% cells in a 2D matrix |mask|. 
%
%% Why does this function exist? 
% Good question! The short answer is it enables fast and easy vectorization, 
% meaning no more nested loops. A more nuanced explanation with lots of examples
% can be found in this <tutorial_3D_analysis.html Tutorial on 3D data analysis>.

%% Example 1: Simplest case 
% This example starts with a random 4x3x2 matrix, meaning it is a grid that
% has spatial dimensions 4x3 and there are two measurements--two "time" slices--
% for each point in the grid: 

% A random 4x3x2 matrix:
A3 = randi(50,[4 3 2])

%% 
% Convert |A3| into a 2D matrix via <cube2rect_documentation.html |cube2rect|>: 

A2 = cube2rect(A3)

%% 
% Above we see that the top row of |A2| contains the values of each grid cell
% in the first "time slice" of |A3|, and the second row of |A2| corresponds 
% to the second time slice. 
% 
% To get A3 back into its original 3D arrangement, use |rect2cube| and specify
% the dimensions you'll want |A3| to be: 

A3 = rect2cube(A2,[4 3 2]) 

%% 
% And that brings us back to where we started. 
% 
% Note: You don't actually have to specify the third dimension of |A3| when you
% use the syntax above. You can just specify the first two dimensions and 
% |rect2cube| will figure out the third one, like this: 

A3 = rect2cube(A2,[4 3]); 

%% Example 2: Masking
% If you're working with very large grids of climate data, you might 
% find it more computationally efficient to remove regions that aren't 
% of interest before performing calculations. To accomplish this, create
% a mask containing |true| values for any grid cells you want to keep. 
% 
% In this example, we'll also use a mask with 7 |true| values 
% indicating grid cells we want to analyze and 5 |false| values that
% we don't want to include in our analysis: 

% Create a mask:
mask = true([4 3]); 
mask([3 4 6 10 11]) = false

%% 
% Convert |A3| into a 2D matrix via <cube2rect_documentation.html |cube2rect|>: 

A2 = cube2rect(A3,mask)

%% 
% Above we see that every |true| grid cell in the |mask| gets a column
% in |A2|, and the rows of |A2| correspond to the time slices of |A3|. 
% 
% Now if we want to get |A2| back into a 3D grid, use the same mask:  

A3b = rect2cube(A2,mask)

%% 
% Above, you'll notice that |A3b| does not exactly match the |A3| matrix 
% we started with, because we threw away all the information in the grid 
% cells that corresponded to |0| in the |mask|, and then later we had to 
% fill them in with |NaN| values. This is a lossy way of doing
% analysis, but if those grid cells were not relevant to the analysis anyway, 
% then was anything really lost? 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 