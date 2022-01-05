classdef mousePaths
    
% an attempt to keep tricky file paths contained in one area.
% access them like: mousePaths.w
% Using the static IP address so hopefully avoiding mapping issues
properties (Constant)
    M = getPathGlobal('M'); % M drive
    W = getPathGlobal('W'); % W drive % keep in mind W has a ...\data\data\... path structure, so be sure that's accounted for when using this
    Z = '\\144.92.237.181\Data\'; % Z drive
    RECA = '\\144.92.237.187\Data\PassiveEphys\';
    RECB = ['\\' getPathGlobal('REC') '\Data\PassiveEphys\'];
end


methods
    
    function checkConnection(location)
        if exist(location,'dir') == 7
            disp(['Connection to ' location ' confirmed']);
        else
            error(['Cannot connect to ' location ' Check connection to remote computer']);
        end
    end
    
    function checkAllConnections
        mc = ?mousePaths
        mc.PropertyList(1,1).DefaultValue
    end
    
    

end

end
