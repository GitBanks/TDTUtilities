%tableFile = 'C:\Users\Grady\Documents\Zarmeen Data\SingleTrialPeakMax\singleTrialDataCombined';
clear all
close all
 
animalTable = readtable('SRTableComplete2'); % read in metadata
%animalTable = animalTable(animalTable.use==1,:); % remove animals that should be excluded from analysis 

outputTable = [];


animalList = unique(animalTable.Index)


% loop through entries in table
for ii =  1:size(animalList,1)
    exptDateIndex = animalList(ii);
    exptDateIndex = char(exptDateIndex);

        searchString = ['M:\Zarmeen\Data\SR Model Fits\SingleTrialResponsesFilt\' exptDateIndex];
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
           y = yData*-1; 
           
           
          %Convert stim values to Amps so that x and y values on approximately the same scale
            x = x/1.e6;
            % Get average responses to use in estimating the parameters and also to
            % plot with the data
            xStim = unique(x,'stable');
            yMn = zeros(length(xStim),1);
            for iStim = 1:length(xStim)
                yMn(iStim) = mean(y(x==xStim(iStim)));
            end
            %Subtract from y the average response to lowest stim intensity
            y = y-yMn(xStim==min(xStim));
            %Initial parameter estimates. Note that the slope parameter is estimated
            %from multiple values. It should be undefined at stim = c and at response =
            %a, so use the median rather than the mean.
            a = yMn(xStim==max(xStim));% Rmax
            c = (max(xStim)-min(xStim))/2;% S_50%
            bEst = -(xStim-c)./log(a./yMn - 1);
            b = median(bEst);%slope; should be around 1.e-4
            %Fitting function inputs
            expression = 'a/(1+exp(-(x-c)/b))';
            sigmoid = fittype(expression,'indep','x');
            p0 = [a b c];% initial conditions
            lower = [0   2.e-6  1.e-5];
            upper = [a*5 2.e-4 8.e-4];
            
            %Try four different approaches just as a demonstration.
            fo = fitoptions('Method','NonlinearLeastSquares','StartPoint',p0);
            [mdl,gof,out] = fit(x,y,sigmoid,fo);
            
            fo_bounded = fitoptions('Method','NonlinearLeastSquares','Lower',lower,'Upper',upper,'StartPoint',p0);
            [mdl_bounded,gof_bounded,out_bounded] = fit(x,y,sigmoid,fo_bounded);
            
            fo_robust = fitoptions('Robust','LAR','Method','NonlinearLeastSquares','StartPoint',p0);
            [mdl_robust,gof_robust,out_robust] = fit(x,y,sigmoid,fo_robust);

            fo_robust_bounded = fitoptions('Robust','LAR','Method','NonlinearLeastSquares','Lower',lower,'Upper',upper,'StartPoint',p0);
            [mdl_robust_bounded,gof_robust_bounded,out_robust_bounded] = fit(x,y,sigmoid,fo_robust_bounded);

            %Plot results
            figure();
            hold on
            plot(x,y,'o');
            plot(xStim,yMn,'o','MarkerSize',10,'MarkerFaceColor','k','markerEdgeColor','k');
            %Note that you can plot the model directly, but you can't set all the plot 
            %parameters directly so use handles.
            hLine = plot(mdl);
            hLine.Color = 'r'; hLine.LineWidth = 2;
            hLine = plot(mdl_bounded);
            hLine.Color = 'b'; hLine.LineWidth = 2;
            hLine = plot(mdl_robust);
            hLine.Color = 'g'; hLine.LineWidth = 2;
            hLine = plot(mdl_robust_bounded);
            hLine.Color = 'k'; hLine.LineWidth = 2;

            ax = gca;
            ax.XLabel.String = 'Stim inte nsity (A)';
            ax.YLabel.String = 'Peak response (mV)';

            legend({'data','avg','unbounded','bounded','robust','robust+bounded'},'Location','northwest');

           % fill in table details
           tempTable = table();
           tempTable.animalID = animalTable.Animal(ii);
           tempTable.dateIndex = animalTable.Index(ii,:);
           tempTable.description = animalTable.ExperimentDescription(ii)
           tempTable.treatment = animalTable.Treatment(ii);
           tempTable.dose = animalTable.Dose(ii)
           
           %extract parameter values
           cnames_mdl = coeffnames(mdl);
           cvals_mdl = coeffvalues(mdl);
           
           for cc = 1:length(cnames_mdl)
               tempTable.(cnames_mdl{cc}) = cvals_mdl(cc);
           end
           
           cnames_mdlBounded = coeffnames(mdl_bounded);
           cvals_mdlBounded = coeffvalues(mdl_bounded);
           
           for cc = 1:length(cnames_mdlBounded)
               tempTable.(cnames_mdlBounded{cc}) = cvals_mdlBounded(cc);
           end
           
           cnames_mdlRobust = coeffnames(mdl_robust);
           cvals_mdlRobust = coeffvalues(mdl_robust);
           
           for cc = 1:length(cnames_mdlRobust)
               tempTable.(cnames_mdlRobust{cc}) = cvals_mdlRobust(cc);
           end
           
           cnames_mdlRobustBounded = coeffnames(mdl_robust_bounded);
           cvals_mdlRobustBounded = coeffvalues(mdl_robust_bounded);
           
           for cc = 1:length(cnames_mdlRobustBounded)
               tempTable.(cnames_mdlRobustBounded{cc}) = cvals_mdlRobustBounded(cc);
           end
           
           temptTable.gof_rmse = gof.rmse;
           temptTable.gofBounded_rmse = gof_bounded.rmse;
           temptTable.gofRobust_rmse = gof_robust.rmse;
           temptTable.gofRobustBounded_rmse = gof_robust_bounded.rmse;
           
           %tempTable.modelFit = {f};
           tempTable.rsquare = gof.rsquare;
           %tempTable.goodness = {goodness};
           
           if isempty(outputTable)
               % use this line for the first entry
               outputTable = tempTable;
           else
               % concatenate this table with a larger table to use across animals
               outputTable = vertcat(outputTable,tempTable);
           end
       

   else
      warning(['search for: ' searchString ' unsuccessful']);
       end
       
    saveas(figure,['M:\Zarmeen\Data\SR Model Fits\Sigmoid Fit Plots\' exptDateIndex '.png'])
    saveas(figure,['M:\Zarmeen\Data\SR Model Fits\Sigmoid Fit Plots\' exptDateIndex '.fig'])
    

    

end


outPath = ('M:\Zarmeen\Data\SR Model Fits\')
csvFile = [outPath 'sigmoid fit table.csv'];
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