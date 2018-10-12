function [exptDate_dbForm] = houseConvertDateTo_dbForm(exptDate)

yrStr = ['20' exptDate(1:2)];
dyStr = exptDate(4:5);

switch exptDate(3)
    case {'o'; 'O'}
        moStr = '10';
    case {'n'; 'N'}
        moStr = '11';
    case {'d'; 'D'}
        moStr = '12';
    otherwise
        moStr = ['0' exptDate(3)];
end

exptDate_dbForm = [yrStr '-' moStr '-' dyStr];

           
            