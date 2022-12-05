clear all
close all
slicePath = '/Users/banks_admin/Box Sync/My documents/Papers/Current/Sultan Hippocampal LTP/';
dataPath = [slicePath 'LTP Decay Data/'];
slopePath = [dataPath 'DOI, Ketamine, Saline - 24hr/'];
outPath = dataPath;
figurePath = [slicePath 'LTP Decay Model Fit Figures/'];
outputTable = table();
count = 1;
figCount = 0;
nRows = 4;
nCols = 6;
flagCriterion = 0.001;

tableFile = 'Mouse Records.xlsx';
s = 'recordingNotes'; % sheet
dataTable = readtable([dataPath tableFile],'Sheet',s); % read in metadata
dataTable = dataTable(dataTable.use==1,:); % remove animals that should be excluded from analysis

% convert the date format to the format used to name the excel files
formatOut = 'yymmdd';
dataTable.date = datestr(dataTable.date,formatOut);

dirCheck = dir(slopePath);
fNames = {dirCheck.name};

% loop through entries in table
for iSlice = 1:height(dataTable)
    searchString = [dataTable.date(iSlice,:) ' - ch' num2str(dataTable.channel(iSlice))]; % Constrruct string to search for excel file
    
    % does a file matching the search criteria exist in directory?
    fExist = contains(fNames,searchString);
    
    if sum(fExist)==1
        % load file if so
        workbookFile = [slopePath fNames{fExist}];
        sheetName = 'Sheet1';
        
        [tVec,dataVec] = loadEPSPSlopes(workbookFile,sheetName);
        dataVec = dataVec(tVec>=0);
        tVec = tVec(tVec>=0);
        % fill in table details
        tempTable = table();
        tempTable.animalID = dataTable.animal(iSlice);
        tempTable.sex = dataTable.sex(iSlice);
        tempTable.date = dataTable.date(iSlice,:);
        tempTable.drug = dataTable.drug(iSlice);
        tempTable.channel = dataTable.channel(iSlice);
        
        tempTable.last5Data = mean(dataVec(tVec>55 & tVec<60));
        tempTable.first5Data = mean(dataVec(tVec>=0 & tVec<5));
        maxVal = tempTable.first5Data-tempTable.last5Data;
        if maxVal<0
            maxVal = 1.2*tempTable.last5Data;
        end
        % calculate model fit
        expression = 'a1*exp(-x/t1)+a2*exp(-x/t2)+c'; % define expression for model fit in cell array
        expFit = fittype(expression,'independent','x'); % create fittype object
        a1 = maxVal*0.5;
        t1 = 5; % fast time constant
        a2 = maxVal*0.5;
        t2 = 50; % slow time constant
        c = tempTable.last5Data; %data(t==0) % steady-state
        p0      = [a1           a2          c                       t1      t2]; % start point
        lower   = [0            0           100                     1       10];  %a1, a2, c, t1, t2
        upper   = [2*maxVal     2*maxVal    2*tempTable.first5Data  100     1000];%a1, a2, c, t1, t2 - i.e., alphabetical order
        fo = fitoptions('Method','NonlinearLeastSquares','Lower',lower,'Upper',upper,'StartPoint',p0);               
        
        tempTable.a1Constr = [lower(1), upper(1)]; 
        tempTable.t1Constr = [lower(4), upper(4)];
        tempTable.a2Constr = [lower(2), upper(2)];
        tempTable.t2Constr = [lower(5), upper(5)];        
        tempTable.cConstr = [lower(3), upper(3)];
        
        [f,goodness] = fit(tVec,dataVec,expFit,fo);
        tempTable.modelFit_a1 = f.a1;
        tempTable.modelFit_t1 = f.t1;
        tempTable.modelFit_a2 = f.a2;
        tempTable.modelFit_t2 = f.t2;
        tempTable.modelFit_c = f.c;
         
        % Create parameter flags
        tempFlag = '';
        
        if abs((tempTable.modelFit_a1-tempTable.a1Constr(1))/tempTable.modelFit_a1) <flagCriterion || ...
                abs((tempTable.modelFit_a1-tempTable.a1Constr(2))/tempTable.modelFit_a1) < flagCriterion
            tempFlag = [tempFlag 'a1 '];
        end

        if abs((tempTable.modelFit_a2-tempTable.a2Constr(1))/tempTable.modelFit_a2) <flagCriterion || ...
                abs((tempTable.modelFit_a2-tempTable.a2Constr(2))/tempTable.modelFit_a2) < flagCriterion
            tempFlag = [tempFlag 'a2 '];
        end
        
        if abs((tempTable.modelFit_c-tempTable.cConstr(1))/tempTable.modelFit_c) <flagCriterion || ...
                abs((tempTable.modelFit_c-tempTable.cConstr(2))/tempTable.modelFit_c) < flagCriterion
            tempFlag = [tempFlag 'c '];
        end

        if abs((tempTable.modelFit_t1-tempTable.t1Constr(1))/tempTable.modelFit_t1) <flagCriterion || ...
                abs((tempTable.modelFit_t1-tempTable.t1Constr(2))/tempTable.modelFit_t1) < flagCriterion
            tempFlag = [tempFlag 't1 '];
        end

        if abs((tempTable.modelFit_t2-tempTable.t2Constr(1))/tempTable.modelFit_t1) <flagCriterion || ...
                abs((tempTable.modelFit_t2-tempTable.t2Constr(2))/tempTable.modelFit_t1) < flagCriterion
             tempFlag = [tempFlag 't2 '];
        end
        
        tempTable.FLAG{1} = tempFlag;
        tempTable.weightedTau = (f.a1*f.t1 + f.a2*f.t2)/(f.a1+f.a2);      
        tempTable.rsquare = goodness.rsquare;
        tempTable.goodness = {goodness};
        outputTable = [outputTable;tempTable];
        
        % plot data and save output to check later
        if count == 1
            figCount = figCount+1;
            figName = ['Slice LTP decay fits plot ' num2str(figCount)];
            thisFig = figure('Name',figName);
        end
        subplot(nRows,nCols,count);
        plot(f,tVec,dataVec);
        ax = gca;
        ax.XLim = [-5 65];
        ax.YLim = [100 1.1*tempTable.first5Data];
        if count == (nRows-1)*nCols+1
            ax.XLabel.String = 'time (min)';
            ax.YLabel.String = 'nmlz EPSP slope';
        else
            ax.XLabel.String = [];
            ax.YLabel.String = [];
        end
        ax.Title.String = searchString;
%         legend();
        
        count = count+1;
        if count > nRows*nCols %Time for a new figure...
            disp(['Saving figure ' figName]);
            saveas(thisFig,[figurePath figName '.fig']);
%             close(thisFig);
            count = 1;
        elseif iSlice == height(dataTable) %Done. Save partial figure...
            disp(['Saving figure ' figName]);
            saveas(thisFig,[figurePath figName '.fig']);
        end
        clear tempTable
    else
        warning(['search for: ' searchString ' unsuccessful']);
    end
    writetable(outputTable,[outPath 'SultanLTPDecayFits.xlsx']);
end