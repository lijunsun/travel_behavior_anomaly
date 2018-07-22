# travel_behavior_anomaly

The codes mainly estimate a 2d-simplex LDA model (for both spatial and temporal features) with Gibbs sampling.

The main computational cost comes from generating the word-topic assignment z from multinomial distribution. 
We provide two mex function mnrnd_mex.c and mnrnd_mex_noscale.c to speed up the computation.

The use of 'mnrnd_mex' is the same as 'mnrnd' in matlab.
The 'mnrnd_mex_noscale' function can take unscaled distribution input, i.e., mnrnd_mex_noscale([1,2,3,4]) is equivalent to mnrnd_mex([.1,.2,.3,.4]) 
