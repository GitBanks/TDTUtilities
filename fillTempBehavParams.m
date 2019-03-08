function [tempBehavParams] = fillTempBehavParams(experimentInfo)
% only returns a single animal's single day tempBehavParams as a structure
% user still need to save, etc.  needs a fully built experimentInfo
% structure
% Calls: [threshEst] = behaviorThresholdEstimation(experimentInfo);
nSecToQualifyForStateChange = 4; % turn this to a parameter?
try
    [threshEst] = behaviorThresholdEstimation(experimentInfo);
catch
    threshEst = 3*std(experimentInfo.framesRaw);
end
% need to use this: Experiment(iList).frameTimeStamps as the time array
for iList = 1:length(experimentInfo)
    maxRead = min([length(experimentInfo(iList).frames) length(experimentInfo(iList).frameTimeStamps)]);
    xvals = experimentInfo(iList).frameTimeStamps(1:maxRead);
    framesPerSecondCalc = round(1/mean(diff(xvals)));
    nFrameToQualifyForStateChange = nSecToQualifyForStateChange*framesPerSecondCalc;
    testData = zeros(size(experimentInfo(iList).framesRaw(1:maxRead)));
    testData(experimentInfo(iList).framesRaw(1:maxRead)>threshEst)=1;

    [segLength, firstElem, lastElem, elemID] = SplitVec(testData, [], 'length','first','last', 'firstelem');
    tempMovtLength = segLength(logical(elemID));
    tempMovtFirst = firstElem(logical(elemID));
    tempMovtLast = lastElem(logical(elemID));

    boundaries.movt = [];
    tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('mobile').startStop = [];
    if ~isempty(tempMovtFirst(tempMovtLength>nFrameToQualifyForStateChange))
        boundaries.movt(:,1) = xvals(tempMovtFirst(tempMovtLength>nFrameToQualifyForStateChange));
        boundaries.movt(:,2) = xvals(tempMovtLast(tempMovtLength>nFrameToQualifyForStateChange));
        boundaries.movt(:,3) = xvals(tempMovtLength(tempMovtLength>nFrameToQualifyForStateChange));
        tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('mobile').startStop(:,1) = boundaries.movt(:,1);
        tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('mobile').startStop(:,2) = boundaries.movt(:,2);
    end
    tempQuietLength = segLength(~logical(elemID));
    tempQuietFirst = firstElem(~logical(elemID));
    tempQuietLast = lastElem(~logical(elemID));
    boundaries.quiet = [];
    tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('still').startStop = [];
    if ~isempty(tempQuietFirst(tempQuietLength>nFrameToQualifyForStateChange))
        boundaries.quiet(:,1) = xvals(tempQuietFirst(tempQuietLength>nFrameToQualifyForStateChange));
        boundaries.quiet(:,2) = xvals(tempQuietLast(tempQuietLength>nFrameToQualifyForStateChange));
        boundaries.quiet(:,3) = xvals(tempQuietLength(tempQuietLength>nFrameToQualifyForStateChange));
        tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('still').startStop(:,1) = boundaries.quiet(:,1);
        tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).('still').startStop(:,2) = boundaries.quiet(:,2);
    end
    % these are the trial start times by frame, adjusted so that
    % element 1 is time 0 of ephys (trial 1), element 2 is the
    % start of ephys trial 1, etc.
    tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).frameTimeStamps = experimentInfo(iList).frameTimeStamps;
    % tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).trialStartIndices = Experiment(iList).LEDTimes - Experiment(iList).LEDTimes(1)+1;
    tempBehavParams.(['date' experimentInfo(iList).index(1:5)]).(['expt' experimentInfo(iList).index(7:9)]).trialStartIndices = 1;
    clear boundaries;
end



