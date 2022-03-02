function dataOut = redefineTrial(cfg, dataIn)
%   cfg.length    = single number (in unit of time, typically seconds) of the required snippets
%   cfg.overlap   = single number (between 0 and 1 (exclusive)) specifying the fraction of overlap between snippets (0 = no overlap)
% data = 1x1 struct:
% data.label{1,1} = 'Mag-Ch1'; % data.label is a 1xnChans cell-array containing string labels for each channel
% data.fsample = 1/magDT; % sampling frequency in Hz, single number
% data.sampleinfo = [1, size(magData)]; %n points
% data.trial{1} = magData; % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is a Nchan*Nsamples matrix
% data.time{1} = magTime;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % cut the existing trials into segments of the specified length
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  dataOut = dataIn;
  dataOut = rmfield(dataOut,'trial');
  dataOut = rmfield(dataOut,'time');
  % create dummy trl-matrix and recursively call ft_redefinetrial
  nSamples = length(dataIn.trial{1});
  winLength    = round(cfg.length*dataIn.fsample);
  nShift  = round((1-cfg.overlap)*winLength);
  
  iStart = 1;
  iStop = winLength;
  iTrial = 1;
  while iStop < nSamples
      dataOut.trial{iTrial} = dataIn.trial{1}(iStart:iStop);
      dataOut.time{iTrial} = dataIn.time{1}(iStart:iStop);
      iStart = iStop - nShift + 2; 
      %No idea why this should be +2, but needed to be to match FieldTrip 
      %function we were trying to replace
      iStop = iStart + winLength - 1;
      iTrial = iTrial +1;
  end
  disp(num2str(iTrial));
end
