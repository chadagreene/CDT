%% |vfill| documentation
% |vfill| creates vertical filled regions on a plot. 
% 
% See also <vline_documentation.html |vline|> and <hfill_documentation.html |hfill|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>
%% Syntax
% 
%  vfill(xl,xu)
%  vfill(...,ColorSpec)
%  vfill(...,ColorSpec,'PatchProperty','PatchValue')
%  vfill(...,'bottom')
%  h = vfill(...)
% 
%% Description 
%
% |vfill(xl,xu)| creates a vertical shaded region between lower bounds
% |xl| and upper bounds |xu|. Inputs |xl| and |xu| must each contain 1 element
% per shaded region. 
%
% |vfill(...,ColorSpec)| defines the face color of the patch(es) created by
% |vfill|. |ColorSpec| can be one of the Matlab color names (e.g. |'red'|),
% abbreviations (e.g. |'r'|, or rgb triplet (e.g. |[1 0 0]|). Or you can
% use the <rgb_documentation.html |rgb|> function. 
%
% |vfill(...,ColorSpec,'PatchProperty','PatchValue')| defines patch properties
% such as |'EdgeColor'| or |'FaceAlpha'|. 
% 
% |vfill(...,'bottom')| places the newly created patch(es) at the bottom of
% the uistack.  
%
% |h = vfill(...)| returns handle(s) of newly created patch objects. 
% 
%% 
% Starting with this plot: 

plot((1:100).^2,'linewidth',2)

%%
% Fill the range between 10 and 20: 

vfill(10,20)

%% 
% Make red regions 3 units wide between 70 and 90: 

yl = 70:5:90; % lower bounds

vfill(yl,yl+3,'r') 

%% 
% Make a brown patch from 30 and 40 with no edge color and put it below 
% everything: 

vfill(30,40,rgb('brown'),'edgecolor','none','bottom') 

%% 
% Semitransparent mauve region from 45 and 55 with dotted gray edges: 

vfill(45,55,rgb('mauve'),...
   'edgecolor',rgb('gray'),...
   'linestyle',':',...
   'facealpha',0.8); 

%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 