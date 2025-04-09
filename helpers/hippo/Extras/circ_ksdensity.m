function [vfEstimate] = circ_ksdensity(vfObservations, vfPDFSamples, vfDomain, fSigma, vfWeights)

% circ_ksdensity FUNCTION - Compute a kernel density estimate over a periodic domain
%
% Usage: [vfEstimate] = circ_ksdensity(vfObservations, vfPDFSamples, 
%                                      <vfDomain, fSigma, vfWeights>)
%
% This function calculates a kernel density estimate of an (optionally
% weighted) data sample, over a periodic domain.
%
% 'vfObservations' is a set of observations made over a periodic domain,
% optionally defined by 'vfDomain': [fMin fMax]. The default domain is
% [0..2*pi]. 'vfPDFSamples' defines the sample points over which to perform
% the kernel density estimate, over the same domain as 'vfObservations'.
%
% Weighted estimations can be performed by providing the optional argument
% 'vfWeights', where each element in 'vfWeights' corresponds to the
% matching element in 'vfObservations'.
%
% The kernel density estimate will be performed using a wrapped Gaussian
% kernel, with a width estimated as
%    (4/3)^0.2 * circ_std(vfObservations, vfWeights) * (length(vfObservations^-0.2)
%
% The optional argument 'fSigma' can be provided to set the width of the
% kernel.
%
% 'vfEstimate' will be a vector with a (weighted) estimate of the
% underlying distribution, with an entry for each element of
% 'vfPDFSamples'. If no weighting is supplied, the estimate will be scaled
% such that it forms a PDF estimate over the supplied sample domain, taking
% into account sample bin widths. If a weight vector is supplied then the
% estimate will be scaled such that the sum over the domain attempts to
% match the sum of weights, taking into account sample bin widths.

% Author: Dylan Muir <dylan.muir@unibas.ch>
% Created: 23rd October, 2013

% -- Defaults

DEF_vfDomain = [0 2*pi];


% -- Check arguments

if (nargin < 2)
   help circ_ksdensity;
   error('circ_ksdensity:Usage', ...
         '*** circ_ksdensity: Incorrect usage');
end

if (~exist('vfDomain', 'var') || isempty(vfDomain))
   vfDomain = DEF_vfDomain;
end

% - Do we need to estimate fSigma?
if (~exist('fSigma', 'var'))
   % - Sigma will be estimated
   fSigma = [];
end

vfObservations = vfObservations(:);
vnPSFSamplesSize = size(vfPDFSamples);
vfPDFSamples = vfPDFSamples(:);

% - If weights are not provided, weight each observation equally
if (~exist('vfWeights', 'var'))
   vfWeights = ones(size(vfObservations)) ./ numel(vfObservations);

% - Check the number of observations matches the number of weights
elseif (numel(vfObservations) ~= numel(vfWeights))
   error('circ_ksdensity:Usage', ...
         '*** circ_ksdensity: The number of observations must be equal to the number of weights.');
end


% -- Map everything to [0..2pi] and wrap over domain

vfObservations = (vfObservations - vfDomain(1)) ./ diff(vfDomain) .* 2*pi;
vfObservations = mod(vfObservations, 2*pi);

vfPDFSamples = (vfPDFSamples - vfDomain(1)) ./ diff(vfDomain) .* 2*pi;
vfPDFSamples = mod(vfPDFSamples, 2*pi);


% - Estimate sigma, if necessary
if (isempty(fSigma))
   fSigma = (4/3)^0.2 * circ_std(vfObservations, vfWeights) * (numel(vfObservations)^-0.2);
end


% -- Pad observations above and below domain

vfObservations = [vfObservations;
                  vfObservations - 2*pi;
                  vfObservations + 2*pi];
vfWeights = repmat(vfWeights, 3, 1) ./ 3;


% -- Perform kernel density estimate

vfEstimate = ksdensity(vfObservations, vfPDFSamples, 'weights', vfWeights', 'width', fSigma);

% - Reshape return to match shape of 'vfPDFSamples'
vfEstimate = reshape(vfEstimate, vnPSFSamplesSize);

% - Correct scaling of histogram estimate
vfEstimate = vfEstimate .* 3 .* sum(vfWeights);

% --- END of circ_ksdensity FUNCTION ---


% circ_std FUNCTION Estimate the weighted circular standard deviation of a dataset
function [s s0] = circ_std(alpha, w)

% compute mean resultant vector length
r = circ_r(alpha,w);

s = sqrt(2*(1-r));      % 26.20
s0 = sqrt(-2*log(r));    % 26.21


% circ_r FUNCTION Compute the weighted resultant of a dataset
function r = circ_r(alpha, w)

% compute weighted sum of cos and sin of angles
r = sum(w.*exp(1i*alpha),1);

% obtain length
r = abs(r)./sum(w,1);


% --- END of circ_ksdensity.m ---


