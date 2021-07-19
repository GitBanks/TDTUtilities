function checkConnection(location)
    if exist(location,'dir') == 7
        disp([getMyIPAddress ' connecting to ' location ' confirmed']);
    else
        error(['Cannot connect ' getMyIPAddress ' to ' location ' Check connection to remote computer']);
    end
end
