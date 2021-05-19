function checkConnection(location)
    if exist(location,'dir') == 7
        disp([thisIP ' connecting to ' location ' confirmed']);
    else
        error(['Cannot connect ' thisIP ' to ' location ' Check connection to remote computer']);
    end
end
