function [x,y,z] = xyzread(filename,varargin)
% xyzread simply imports the x,y,z columns of a .xyz file.  Note: there
% is no real standard for .xyz files, so your .xyz file may be different
% from the .xyz files I wrote this for.  I wrote this one for GMT/GIS
% files.  
% 
%% Syntax
% 
% [x,y,z] = xyzread(filename)
% [x,y,z] = xyzread(filename,Name,Value) 
% 
%% Description
% 
% [x,y,z] = xyzread(filename) imports the columns of a plain .xyz file. 
% 
% [x,y,z] = xyzread(filename,Name,Value) accepts any textscan arguments 
% such as 'headerlines' etc. 
% 
%% Examples: 
% For examples, type 
% 
%  cdt xyzread
% 
%% Author Info 
% This script was written by Chad A. Greene of the University of Texas 
% at Austin's Institute for Geophysics (UTIG), April 2016. 
% http://www.chadagreene.com 
% 
% See also xyz2grid and textscan. 

%% Error checks: 

narginchk(1,inf) 
nargoutchk(3,3)
assert(isnumeric(filename)==0,'Input error: filename must ba a string.') 
assert(exist(filename,'file')==2,['Cannot find file ',filename,'.'])

%% Open file: 

fid = fopen(filename); 
T = textscan(fid,'%f %f %f',varargin{:}); 
fclose(fid);

%% Get scattered data: 

x = T{1}; 
y = T{2}; 
z = T{3}; 

end