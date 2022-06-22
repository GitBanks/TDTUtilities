% Defines the frequency bands and smoothing for the DBT. Also used by other 
%   functions (e.g. WPLI and plotting) for convenience. 
classdef FreqBands
   properties (Constant)
       % Listing the human-readable names explicitly saves us from having to 
       %  parse structs with 'fieldnames' or 'isfield'. 
       Names    = {'delta', 'theta', 'alpha', 'beta', 'gamma', 'highGamma'};
       Limits   = struct('delta',     [1 4], ...
                         'theta',     [4 8], ...
                         'alpha',     [8 14], ...
                         'beta',      [14 30], ...
                         'gamma',     [30 70], ...
                         'highGamma', [70 120]);
       % Center frequency step sizes for each band
       Widths   = struct('delta',     1, ...
                         'theta',     1, ...
                         'alpha',     2, ...
                         'beta',      4, ...
                         'gamma',     10, ...
                         'highGamma', 20);
   end
end

