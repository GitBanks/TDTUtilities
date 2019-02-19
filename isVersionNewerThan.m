function [verBool,thisVer] = isVersionNewerThan(baseVer)

%2018b = 9.5000,2018a = 9.4000

thisVer = version;
thisVer = str2num(thisVer(1:3));

verBool = baseVer < thisVer;
%verBool = true if thisVer is newer than baseVer
end