%% |hfill| documentation
% |hfill| creates horizontal filled regions on a plot. 
% 
% See also <hline_documentation.html |hline|> and <vfill_documentation.html |vfill|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  hfill(yl,yu)
%  hfill(...,ColorSpec)
%  hfill(...,ColorSpec,'PatchProperty','PatchValue')
%  hfill(...,'bottom')
%  h = hfill(...)
% 
%% Description 
%
% |hfill(yl,yu)| creates a horizontal shaded region between lower bounds
% |yl| and upper bounds |yu|. Inputs |yl| and |yu| must each contain 1 element
% per shaded region. 
%
% |hfill(...,ColorSpec)| defines the face color of the patch(es) created by
% |hfill|. |ColorSpec| can be one of the Matlab color names (e.g. |'red'|),
% abbreviations (e.g. |'r'|, or rgb triplet (e.g. |[1 0 0]|). Or you can
% use the <rgb_documentation.html |rgb|> function. 
%
% |hfill(...,ColorSpec,'PatchProperty','PatchValue')| defines patch properties
% such as |'EdgeColor'| or |'FaceAlpha'|. 
% 
% |hfill(...,'bottom')| places the newly created patch(es) at the bottom of
% the uistack.  
%
% |h = hfill(...)| returns handle(s) of newly created patch objects. 
% 
%% 
% Starting with this plot: 

plot((1:100).^0.5,'linewidth',2)

%%
% Fill the area between 2 and 3 on y axis: 

hfill(2,3)

%% 
% Make red regions 0.3 units high between 6 and 10: 

yl = 6:10; 
hfill(yl,yl+0.3,'r') 

%% 
% Make a brown patch from 3.5 to 4 with no edge color and put it below 
% everything: 

hfill(3.5,4,rgb('brown'),'edgecolor','none','bottom') 

%% 
% Semitransparent mauve region from 4.5 to 5.5, with dotted gray edges: 

hfill(4.5,5.5,rgb('mauve'),...
   'edgecolor',rgb('gray'),...
   'linestyle',':',...
   'facealpha',0.8); 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 