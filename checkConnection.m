function checkConnection(location)


    [~, result] = system('ipconfig');
    result = result(strfind(result,'IPv4 Address'):end);
    result = result(strfind(result,':')+2:end);
    result = result(1:15);
    ipAddress = split(result,'.');
    for ii=1:4 %there should only be 3 dots in an address
        ipAddressNum(ii) = str2num(ipAddress{ii});
        ipAddress{ii} = num2str(ipAddressNum(ii)); % reinput the text to clean it up
    end
    thisIP = [ipAddress{1}, '.' ipAddress{2}, '.' ipAddress{3}, '.' ipAddress{4}];
   
    
    if exist(location,'dir') == 7
        disp([thisIP ' connecting to ' location ' confirmed']);
    else
        error(['Cannot connect ' thisIP ' to ' location ' Check connection to remote computer']);
    end
end
