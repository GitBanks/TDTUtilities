function foundPoints = cleanDataByThresholdAnimalDateEEG(animalName,exptDate)
% for now let's use the method we just used in QA to look for reasonable

% problem ZZ animals? 
% animalName = 'ZZ15'; 
% exptDate = '22203'; 
% animalName = 'ZZ10'; 
% exptDate = '21623'; 
% animalName = 'ZZ20'; problem in last index with code line 67
% exptDate = '22907';


trySixtyHzFilter = false;
tryOneHzFilter = true;

% you can use the output foundPoints to trigger a rerunning of specAnalysis
% or otherwise generate a list of animals that have had points cleaned.

% careful! these are a few hardcoded thresholds which will be much
% different if we're not giving it EEG data recorded by Synapse.  Which is
% why I called this function 'EEG'
secondsAroundNoiseToErase = 4;
minThreshold = 0.0015;
STDmultiplier = 3;

foundPoints = false;

findExptType = 'Spon';
[operationList] = getExperimentsByAnimalAndDate(animalName,exptDate,findExptType);
year = exptDate(1:2);


% % get electrode maps?
% electrodeLocs = getElectrodeLocationFromDateIndex(operationList{1,1}(1:5),operationList{1,1}(7:9));
% isempty(electrodeLocs)



for i=1:size(operationList,1)
    dirStr = [getPathGlobal('importedData') '20' year '\' operationList{i,1} '\'];
    try % making it work for any data, not just EEG
        load([dirStr operationList{i,1} '_EEGData0.mat'],"ephysData","dT");
        isEEG = true;
    catch
        load([dirStr operationList{i,1} '_data0.mat'],"ephysData","dT");
        isEEG = false;
    end
    [nChans,nPts] = size(ephysData);
    t = (0:nPts-1)*(dT); % time array for EEG signal
    % save([dirStr '\' operationList{i,1} '_BACKUP_D_ata0.mat'],"ephysData","dT");
    % find and remove any big outliers
    % here's the threshold
    blankingWindow = round(1/dT)*secondsAroundNoiseToErase;
    tempSetNanArray = zeros(1,nPts);
    for iChan = 1:nChans
        % check this noiselimit against some threshold - take the
        % MAX to prevent overselection of points
        noiseLimit = std(ephysData(iChan,:),'omitnan')*STDmultiplier;
        if minThreshold > noiseLimit
            noiseLimit = minThreshold;
            display([num2str(STDmultiplier) ' SD is below our minimum threshold.' 'Noise threshold will be: ' num2str(noiseLimit)]); 
        else
            display(['Noise threshold will be: ' num2str(noiseLimit)]); 
        end
        % here we find points.  we're taking abs to catch both + and - going noise
        setNan = abs(ephysData(iChan,:)) >noiseLimit;
        % next, let's be thorough and trim a few seconds off each side
%         tempSetNanArray = setNan;
        for ii = blankingWindow:size(setNan,2)-blankingWindow
            if setNan(ii)
                tempSetNanArray(ii-blankingWindow:ii+blankingWindow) = true;
            end
        end
    end
    % plot to show our progress
    figure('Units','Normalized','Position',[0 0.2 0.8 0.5]);
    tempEphysData = ephysData;
    for iChan = 1:nChans
        tempEphysData(iChan,logical(tempSetNanArray)) = nan;
    end
    for iPlot = 1:nChans
        subtightplot(nChans,1,iPlot)
        plot(t,ephysData(iPlot,:),'r');
        hold on
        plot(t,tempEphysData(iPlot,:),'b');
    end
%     drawnow;
%     pause(0.5);




    % now we need some user input
    %disp([num2str(sum(tempSetNanArray)) ' points found to eliminate.']);
    disp([num2str(sum(tempSetNanArray)*dT) ' seconds found to eliminate.']);
        
    if sum(tempSetNanArray) > 0
        % should we save over the files?  ask here
        b2name = questdlg_timer(60,'Should we eliminate these points (red)?',...
        'Save Dialogue Box','Yes','No','No');
        switch b2name
            case 'Yes'
                ephysData = tempEphysData;
                if isEEG
                    disp('Red points set to NaN. Overwriting EEGData0!');
                    save([dirStr operationList{i,1} '_EEGData0.mat'],"ephysData","dT");
                    disp([dirStr operationList{i,1} '_EEGData0.mat overwritten.']);
                else
                    disp('Red points set to NaN. Overwriting data0!');
                    save([dirStr operationList{i,1} '_data0.mat'],"ephysData","dT");
                    disp([dirStr operationList{i,1} '_data0.mat overwritten.']);
                end
                disp('rerun fileMaint and reimport to revert to original.');
                foundPoints = true;
            case 'No'
                disp('No changes will be made.')
        end
    else
        disp('since no points found we''re skipping this index.')
    end
    close all



    if trySixtyHzFilter
        clear tempEphysData
        tempEphysData = ephysData;
%         tempEphysData(1,:) = cos(2*pi*60*t); test 60Hz sine
        [tempEphysData] = filterData_dbVer(ephysData,0,0,dT);
        figure('Units','Normalized','Position',[0 0.2 0.8 0.5]);
        for iPlot = 1:nChans
            subtightplot(nChans,1,iPlot)
            plot(t,ephysData(iPlot,:),'r');
            hold on
            plot(t,tempEphysData(iPlot,:),'b');
            ylim([-3e-4,3e-4]);
            xlim([500,500.1]);
        end
        drawnow;
        pause(0.5);
            b2name = questdlg_timer(60,'Are the red points noticable, to justify an additional 60Hz filter run?',...
            'Save Dialogue Box','Yes','No','No');
            switch b2name
                case 'Yes'
                    ephysData = tempEphysData;
                    if isEEG
                        disp('using blue from the plot. Overwriting EEGData0!');
                        save([dirStr operationList{i,1} '_EEGData0.mat'],"ephysData","dT");
                        disp([dirStr operationList{i,1} '_EEGData0.mat overwritten.']);
                    else
                        disp('using blue from the plot. Overwriting data0!');
                        save([dirStr operationList{i,1} '_data0.mat'],"ephysData","dT");
                        disp([dirStr operationList{i,1} '_data0.mat overwritten.']);
                    end
                    disp('rerun fileMaint and reimport to revert to original.');
                    foundPoints = true;
                case 'No'
                    disp('No changes will be made.')
            end
            close all
    end

    if tryOneHzFilter
        clear tempEphysData
        tempEphysData = ephysData;
%         tempEphysData(1,:) = cos(2*pi*60*t); test 60Hz sine
        [tempEphysData] = filterData_dbVer(ephysData,1,0,dT);
        figure('Units','Normalized','Position',[0 0.2 0.8 0.5]);
        for iPlot = 1:nChans
            subtightplot(nChans,1,iPlot)
            plot(t,ephysData(iPlot,:),'r');
            hold on
            plot(t,tempEphysData(iPlot,:),'b');
            ylim([-3e-4,3e-4]);
            xlim([500,502]);
        end
%         drawnow;
%         pause(0.5);

%             b2name = questdlg_timer(60,'Are the red points noticable, to justify a 1Hz filter run?',...
%             'Save Dialogue Box','Yes','No','No');
            b2name = 'Yes'
            switch b2name
                case 'Yes'
                    ephysData = tempEphysData;
                    if isEEG
                        disp('using blue from the plot. Overwriting EEGData0!');
                        save([dirStr operationList{i,1} '_EEGData0.mat'],"ephysData","dT");
                        disp([dirStr operationList{i,1} '_EEGData0.mat overwritten.']);
                    else
                        disp('using blue from the plot. Overwriting data0!');
                        save([dirStr operationList{i,1} '_data0.mat'],"ephysData","dT");
                        disp([dirStr operationList{i,1} '_data0.mat overwritten.']);
                    end
                    disp('rerun fileMaint and reimport to revert to original.');
                    foundPoints = true;
                case 'No'
                    disp('No changes will be made.')
            end
            close all
    end



end

