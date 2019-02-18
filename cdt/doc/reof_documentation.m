%% |reof| documentation 
% reof reconstructs a time series of eof anomalies from specified EOF modes. 
%  
% See also: <eof_documentation.html |eof|>.
% 
% <CDT_Contents.html Back to Climate Data Tools Contents>.
%% Syntax
% 
%  A = reof(eof_maps,pc,modes)
% 
%% Description
% 
% |A = reof(eof_maps,pc,modes)| reconstructs a gridded time series of the 
% specified modes, from eigenmode maps |eof_maps| and principal component
% time series |pc|, which are both outputs of the <eof_documentation.html |eof|> function. 
% 
%% Example
% Let's say we have some big gridded dataset, and the modes associated with 
% the first 75% of variance are desirable, but all the higher-order modes 
% that make up the last 25% percent of variance we assume (for this exampe) 
% are just noise. We want to filter out all that noise, and we can do such 
% filtering with |reof|. 
% 
% Start by very quickly running through the steps of EOF analysis which 
% are described in excruciating detail in the <eof_documenation.html |eof|>
% documentation: 

load pacific_sst

sst = deseason(detrend3(sst,t),t); 

[eof_maps,pc,expv] = eof(sst); 

%% 
% We said we want to keep the first modes, because they're the most significant, 
% but how many modes does it take to explain 75% of the variance of the dataset? 
% For that, we'll have to plot the cumulative variance explained, as a function 
% of mode number: 

figure
plot(cumsum(expv))
axis tight
box off
xlabel mode
ylabel 'cumulative variance explained (%)'

%%
% As you can see, it only takes a few of the 802 modes to explain 75% of the 
% sst dataset, and we'll assume that means all the other modes are just noise. 
% Zooming in, it looks like only takes 11 modes to explain 75% of the variance:

xlim([0 20])
hline(75) % 75% variance explained
vline(11) % corresponds to about mode 11

%% 
% Let's check. The sum of the variance explained by the first 11 modes is 

sum(expv(1:11))

%% 
% Perfect, 75%. So let's "filter out" that last 25% of noisy variance with
% |reof|. Just give it the |eof_maps| and |pc| array we calculated earlier:, 
% and specify modes 1:11, like this: 

sst_f = reof(eof_maps,pc,1:11); 

%%
% Now we can make a side-by-side animation, showing the original (<detrend3_documentation.html detrended>
% and <deseason_documentation.html deseasoned>) time series, next to our filtered
% one. Start by plotting the first frame, save it with the <gif_documentation.html |gif|> 
% function, and then loop through the remaining frames, updating the data 
% and saving each frame with |gif|. 
% 
% To keep the filesize small, I'm just plotting frames 200 to 300, which 
% correspond to 1966 to 1974, and we'll only plot every other month. 
% 
%  figure
%  subplot(1,2,1) 
%  h = imagescn(lon,lat,sst(:,:,200)); 
%  caxis([-3 3])
%  cmocean bal
%  title 'all modes'
%  axis image off 
%  
%  subplot(1,2,2) 
%  h_f = imagescn(lon,lat,sst_f(:,:,200)); 
%  caxis([-3 3])
%  cmocean bal
%  title 'modes 1-11'
%  axis image off 
%  
%  % Save the first frame: 
%  gif('eof_filtering.gif','frame',gcf,'nodither')
%  
%  for k = 202:2:300
%     h.CData = sst(:,:,k);     % updates raw data
%     h_f.CData = sst_f(:,:,k); % updates filtered data
%     gif                       % saves this frame
%  end
% 
% <<eof_filtering.gif>>
%% 
% And you can see, in the animation above, that keeping only first 11 modes 
% preserves the large-scale, large-magnitude variability, but eliminates 
% the smaller-scale noisiness. 
% 
%% Author Info
% This function is part of the <http://www.github.com/chadagreene/CDT Climate Data Toolbox for Matlab>.
% The function and supporting documentation were written by Chad A. Greene
% of the University of Texas at Austin. 