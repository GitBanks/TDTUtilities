tableFile = 'C:\Users\Grady\Documents\Zarmeen Data\SingleTrialPeakMax\singleTrialDataCombined';

 
animalTable = readtable(tableFile); % read in metadata
%animalTable = animalTable(animalTable.use==1,:); % remove animals that should be excluded from analysis 

outputTable = [];

animalList = unique(animalTable.DateIndex)


% loop through entries in table
for ii = 1:size(animalList,1)
    exptDateIndex = animalList(ii);
    exptDateIndex = char(exptDateIndex);

        searchString = ['C:\Users\Grady\Documents\Zarmeen Data\SingleTrialPeakMax\' exptDateIndex];
        dataComplete = readtable(searchString);
        dataToUse = dataComplete(:,4:34)
        data = table2array(dataToUse)
       
       if ~isempty(data)
           cols_with_all_zeros = find(all(data==0));
           n = numel(cols_with_all_zeros);
           columnCount = size(data,2) - n;
           trialsToUse = data(:, 2:columnCount)
           xData = data(:,1)
           stimIntensity = repmat(xData, columnCount-1,1)
           yData = trialsToUse
           yData = yData(:)
           
        
           x = stimIntensity; % stimulus intensity (uA)
           y = yData; 
           
           % Set paramter estimates and fit sigmoid to stim-response data
           a = 2; % height
           b = .15; % temperature/"heat" parameter of sigmoid, i.e. the slope
           c = 200; % center point of function
           k = mean(trialsToUse(1,:));
           p0 = [a b c]; % initial conditions
           lower = [k 0 0 0];
           upper = [k 5 1 400];
           
          %expression = 'a/(1+exp(-b*(x-c)))'; we are adding K to account
          %for the variance in the sub threshold sim intensity this will
          %let the Y intercpt vary
           expression = 'k + (a-k)/(1+exp(-b*(x-c))';
           sigmoid = fittype(expression); 
           fo = fitoptions('Method','NonlinearLeastSquares','Lower',lower,'Upper',upper,'StartPoint',p0);
           
               [f,goodness] = fit(x,y,sigmoid,fo);
               
           % extract values from the model fit
           cnames = coeffnames(f);
           cvals = coeffvalues(f);
           
           figH = figure;
           plot(f,x,y);
           text(min(x),max(y)*.5,['r^2=' num2str(goodness.rsquare)]); % display r^2 value on plot
           text(min(x),max(y)*.9,['f(x)=' expression]);
           xlabel('stim intensity (uA)');
           ylabel('fEPSP slope');
%            ylim([0 5]);
           title(exptDateIndex);
           legend('Location','southeast');
           fname = [outPath searchString];
           %print('-painters',fname,'-dpng');
           print('-painters',fname,'-depsc');
           close(figH);
           
           % fill in table details
           tempTable = table();
           tempTable.animalID = animalTable.animal(ii);
           tempTable.sex = animalTable.sex(ii);
           tempTable.date = animalTable.date(ii,:);
           tempTable.drug = animalTable.drug(ii);
           tempTable.channel = animalTable.channel(ii);
           
           
           
           for cc = 1:length(cnames)
               tempTable.(cnames{cc}) = cvals(cc);
           end
           
           tempTable.modelFit = {f};
           tempTable.rsquare = goodness.rsquare;
           tempTable.goodness = {goodness};
           
           if isempty(outputTable)
               % use this line for the first entry
               outputTable = tempTable;
           else
               % concatenate this table with a larger table to use across animals
               outputTable = vertcat(outputTable,tempTable);
           end
       end

   else
      warning(['search for: ' searchString ' unsuccessful']);
end


outPath = getLocalPath('summaryData');
csvFile = [outPath '\sigmoid fit table new Post.csv'];
writetable(outputTable,csvFile);

%%

if ~exist('outputTable','var')
    outPath = getLocalPath('summaryData');
    csvFile = [outPath ' sigmoid fit table.csv'];
    outputTable = readtable(csvFile);
     expression = 'a/(1+exp(-b*(x-c)))';
end

varNames = {'b','a','c'};
cmap = [0.1 .1 .1;0.8500, 0.3250, 0.0980; 0 0.4470 0.7410]; %[0.75 0.75 .75; .2 .2 .2; 1 0 0];
ord = {'Saline','Ketamine','DOI'};
outPath = getLocalPath('summaryData');
% figure;
for iVar = 1:length(varNames)
    thisVar = varNames{iVar};
    
    figure;
    g = gramm('x',outputTable.drug,'y',outputTable.(thisVar));
    g.stat_boxplot('width',0.5);
%     g.set_title(['baseline stim-response sigmoidal fit coefficient ' thisVar]);
    g.set_color_options('map',[.95 .95 .95]);
    g.set_names('x','','y',thisVar,'color','','marker','');
    g.draw();
    
    g.update('color',outputTable.drug,'marker',outputTable.drug);
    g.set_color_options('map',cmap,'legend','merge');
    g.set_order_options('color',ord);
    g.set_point_options('base_size',7);
    g.axe_property('fontsize',20,'xlim',[.5 3.5]);
    g.geom_jitter('dodge',1.2,'width',0.4);
    g.draw();
    
    [yLims]=ylim;
%     text(0,.75*yLims(2),['f(x)=' expression],'fontsize',20);

    fname = [outPath '\sigmoidal fit coefficient ' thisVar];
    exportFigs(fname);
    close

end