classdef mousePaths
   % an attempt to keep tricky file paths contained in one area.
   % access them like: mousePaths.w
   % Using the static IP address so hopefully avoiding mapping issues
    properties (Constant)
        
        M = '\\144.92.237.185\Data\'; % M drive
        W = '\\144.92.218.131\Data\'; % W drive % keep in mind W has a ...\data\data\... path structure, so be sure that's accounted for when using this
        Z = '\\144.92.237.181\Data\'; % Z drive
        
    end
end
