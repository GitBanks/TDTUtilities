function [out] = removeNonKeywordFromSpecAnalysis(out,searchWord)
% this part finds the keyword we're interested in
if ~exist('searchWord','var')
    searchWord = 'Spon';
end
segmentList = fieldnames(out.specAnalysis{1,1});
validSegments = contains(segmentList,searchWord);
% this part trims off the invalid sections from segmentTimes
times = out.segmentTimes{1,1};
newTimes = times(validSegments);
out.segmentTimes{1,1} = newTimes;
% this part gets rid of the data spec values from out.specAnalysis
tempData = out.specAnalysis{1,1};
listOfSegmentNamesToKeep = segmentList(validSegments);
for i = 1:size(listOfSegmentNamesToKeep)
    newSpecAnalysisList{1,1}.(listOfSegmentNamesToKeep{i}) = out.specAnalysis{1,1}.(listOfSegmentNamesToKeep{i});
end
out.specAnalysis{1,1} = newSpecAnalysisList{1,1};
% this part trims off the invalid sections from segmentTimeOfDay
timesOfDay = out.segmentTimeOfDay{1,1};
newTimesOfDay = timesOfDay(validSegments);
out.segmentTimeOfDay{1,1} = newTimesOfDay;