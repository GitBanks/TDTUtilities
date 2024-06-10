function data = readncs(fnames,pth,varargin)

%
% Basic script to read continuous neuralynx data.
%
% Usage:
%
%   D = readncs([filename(s)],[file path])
%
% Without input arguments files are selected by UI menu.
%
% Output:
%
%   D:  Struct array with the following fields
%
%       D.dat : data in column vector as single
%       D.fs  : average sampling rate as determined from the time
%              stamps. This value appears to deviate slightly from the
%              nominal sampling rate reported in the header.
%       D.name : File name without extension
%       D.TimeStamp   : TimeStamps for each recording segment
%       D.ChannelNumber : Channel number for each recording segment
%       D.SampFreq : Sampling frequency recprded for each recording segment
%       D.NumValidSamples : Number of valid samples for each recording
%                          epoch
%       D.time_fmt  : Time format, default 'unix_usec' = unix time in microseconds
%       D.file      : File name with extension
%
%       D.time_compensator: A sparse vector which can be used to adjust
%                   samples according to the labeled sample time. This is
%                   explained below.
%
%       D.total_sample_time_gap: The maximum discrepancy between sample 
%                   index and sample time in units of samples based on the
%                   total number of gaps and jumps in the time stamps. The
%                   time compensator must be used if this value is nonzero.
%                   
%
% HOW TO USE THE TIME COMPENSATOR:
%
%    It is often not safe to infer timing from the sample number because
%    interruptions and errors in the acquisition can lead to jumps in 
%    the true delays between samples. Rather than the sample index, timing 
%    should be inferred from the TimeStamp field, which gives the time of 
%    the first sample in every block of 512. The time compensator provides
%    a convenient way to construct an array of indices into the data 
%    with the proper uniform sample timing. Because such an array has the same
%    length as the data, simply including it in the data structure for every
%    channel would add too much storage and memory overhead, so the 
%    compensator is stored instead as a sparse array of sample step 
%    differences minus one, which is zero except where there are  
%    gaps in the data.
%
%    To reconstruct the desired index array, use the following line of code:
%
%       index_array = cumsum(D.time_compensator + cumsum(D.gap_boundaries) + 1);
%
%    The delay-corrected data are then obtained as:
%
%       adjusted_data = D.dat(index_array);
% 
%    The assumption of uniform sampling is safe for adjusted_data, so that
%
%      adjusted_time = (0:length(index_array)-1)/D.fs;
%
%   gives the correct time stamp for each sample in adjusted_data relative
%   to the onset of the recording.
%   
%   Using this method, any gaps in the data will be filled with the value of 
%   the most recent preceding sample.
%
%
% See also READNLX and READNEV
%

%
% C Kovach 2017
%
%


params.header_bytes = 16384;
params.data_precision = 'int16';
% params.samphead_bytes=20;
params.samptime_precision='uint64';
params.samphead = struct('TimeStamp','uint64','ChannelNumber','uint32','SampFreq','uint32','NumValidSamples','uint32');
params.unitVscale= 1e6; % scale voltage by this amount (eg. 1e6 = microvolt )
params.native_sampling_rate = 16e3; % This is the assumed native sampling rate
                                    % of the recording system. As of Pegasus ver. 2.1.1, 
                                    % Neuralynx fails to record this rather
                                    % vital bit of infomration in the
                                    % header.
%%% This script checks the header data and applies the delay correction to 
%%% timestamps for data recorded with pegasus ver. < 2.0.1. Options are:
%%%     'correcting' - apply the correction with a warning. This is the
%%%                    recommended setting.
%%%     'warning'    - throw a warning without doing anything
%%%     'asking'     - stop and ask if the correction should be applied.
%%%     'shift'     -  correct by shifting the data so that samples align. This is not recommended.  
params.handle_pegasus_v201_bug_by = 'correct';
params.enforce_polarity = true; % Check if the InputInverted is true and invert sign if so.
params.headers_only = false; %Don't load the actual data if true
persistent path warned warned2

i = 1;
while i <length(varargin)
   if ismember(lower(varargin{i}),fieldnames(params))
       params.(varargin{i})=varargin{i+1};
   else
       error('%s is not a recognized keywork',varargin{i})
   end
   i=i+2;
end

if nargin < 2
    pth = '';
end


% if nargin > 0 
%     [pth2,fnames] = fileparts(fn);
%     pth = fullfile(pth,pth2);
% end

if ~isempty(pth)
    path = pth;
end


if nargin < 1 || isempty(fnames)
    
    [fnames,pth] = uigetfile({'*.ncs','NCS files';'*.*','All files'},'Select NLX data file',path,'multiselect','on');
    if isnumeric(fnames)
        return
    else
        path = pth;
    end
    
    if ~iscell(fnames)
        fnames = {fnames};
    end
    
    % sort numerically
    decell= @(x)[x{:}];
    reg = regexp(fnames,'(\d+)','tokens');
    chn = fliplr(arrayfun(@(x)str2num(decell(decell(x))),cat(1,reg{:}))); %#ok<*ST2NM>
    [~,srti] = sortrows(chn);
    fnames = fnames(srti);
else

    if ~iscell(fnames)
        fnames = {fnames};
    end
end
%Valid fieldname characters
fnchars ='abcdefghijklmnopqrstuvwxyz1234567890_';
fnchars = unique([fnchars,upper(fnchars)]);

data = struct('dat',[],'fs',[],'name','','units','','header',[]);

%parse sample header
sampheadfn = fieldnames(params.samphead);

for k = 1:length(sampheadfn)
    sampheadbyteN(k) =  cellfun(@str2double,regexp(params.samphead.(sampheadfn{k}),'(\d+)','tokens','once'))/8; %#ok<*AGROW>
end
params.samphead_bytes = sum(sampheadbyteN);

delay_correction = 0;

bug_version_range = [2 1 0; 2 1 1]; %First row is 1st version affected and 2nd row is first version fixed
bverns = bug_version_range*(2.^(8*(2:-1:0)))';
native_sampling_rate = 16e3;
for k = 1:length(fnames)
  
    [pth,fn,ext] = fileparts(fnames{k});
    if ~isempty(pth)
        path=pth;
    end
    fn = fullfile(path,[fn,ext]);
    fid = fopen(fn);
    txt = fread(fid,16384,'uchar=>char')';
    txt = regexprep(txt,char(181),'u');
    flds = regexp(txt,'-([^\s]*)\s*([^\n]*)','tokens');
    flds = cat(1,flds{:})';
    flds(1,:) = cellfun(@(x)x(ismember(x,fnchars)),flds(1,:),'uniformoutput',false);
    flds(2,:) = cellfun(@(x)deblank(x),flds(2,:),'uniformoutput',false);
        
    data(k).header = struct(flds{:});
    data(k).fs = str2double(data(k).header.SamplingFrequency);

    %%% Check version and correct bug
    re = regexp(data(k).header.ApplicationName,'Pegasus "([^"]*)','tokens','once');
    ver = cellfun(@str2double,regexp(re{1},'\d*','match'));
    vern = ver*2.^(8*((0:-1:-length(ver)+1)+2))';
    
    if vern>=bverns(1) && vern<bverns(2)
        
        if isfield(data(k).header,'SubsamplingBugFix')
            switch lower(data(k).header.SubsamplingBugFix)
                case {'true'}
                    if k ==1 && isempty(warned)
                        warning('These data were recorded with Pegasus version %s and may have been affected by a bug which results in erroneous DSP filter cutoffs and delays for subsampled data. According to information in the header, a correction has already been applied.',vstr)                   
                    end
                    params.handle_pegasus_v201_bug_by='ignore';

                    %                 case {'false'}
%                     warning('These data were recorded with Pegasus version %s and may have been affected by a bug which results in erroneous DSP filter cutoffs and delays for subsampled data. According to information in the header, a correction has already been applied.',vstr)                   
%                      params.handle_pegasus_v201_bug_by='ignore';
            end
        end
            
        vstr = re{1};
        
        switch params.handle_pegasus_v201_bug_by
            case {'warning','warn'}
                if k ==1 && isempty(warned)
                    warning('These data were recorded with Pegasus version %s and may be affected by a bug which results in erroneous DSP filter cutoffs and delays for subsampled data. With current settings, NO correction will be applied. Change the value of params.handle_pegasus_v201_bug_by in %s.m if that is not the desired behavior.',vstr,mfilename)                   
%                     warned = true;

                end
                do_correct = false;
            case {'correcting','correct','asking','ask','shift','shifting'}
                    do_correct = true;
                    shift_data=false;
                    switch params.handle_pegasus_v201_bug_by
                        case {'asking','ask'}
                            if k ==1
                                do_correct=strcmp(questdlg(sprintf('These data were recorded with Pegasus version %s and are likely affected by a bug in subsampling resulting in erroneous DSP filter cutoffs and delays. Should timing delay be corrected?',vstr)),'Yes');
                            end
                        case {'shifting','shift'}
                            shift_data = true;
                        otherwise
                            if k ==1 && isempty(warned)
                                 warning('These data were recorded with Pegasus version %s and are assumed to be affected by a bug which results in erroneous DSP filter cutoffs and delays for subsampled data. A correction will be applied.',vstr)
%                                  warned = true;
                            end
                    end
                
            case {'ignore','ignoring'}   
               do_correct = false;
           
            otherwise
                error(sprintf('params.handle_pegasus_v201_bug_by must be one of ''warning'',''correcting'' or ''asking''')) %#ok<*SPERR>
        end
        
        if do_correct && strcmp( data(k).header.DspDelayCompensation,'Enabled')
            if k ==1 && isempty(warned)
                warning('The subsampling bug fix assumes that data were recorded at a base samping rate of %i Hz (a detail not recorded in the file header). Please change params.native_sampling_rate to the correct value if this is wrong.',params.native_sampling_rate)
                if ~shift_data
                    warning('Note that the timing delay correction is only applied to the recording segment time stamps, but the offset in data samples is not adjusted. Channels subsampled at different rates from each other are still misaligned with respect to sample index. The correcion only means that any delay is now reflected in the respecive time stamps.')
                end
            end
            high_cut_enabled = strcmpi(data(k).header.DSPHighCutFilterEnabled,'True') && strcmpi(data(k).header.DspHighCutFilterType,'FIR');
            low_cut_enabled = strcmpi(data(k).header.DSPLowCutFilterEnabled,'True')&& strcmpi(data(k).header.DspLowCutFilterType,'FIR');
            low_cut_freq = str2double(data(k).header.DspLowCutFrequency);
            if low_cut_enabled || high_cut_enabled
                ntaps = high_cut_enabled*str2double(data(k).header.DspHighCutNumTaps) + low_cut_enabled*str2double(data(k).header.DspLowCutNumTaps)-1;
                high_cut_freq = str2double(data(k).header.DspHighCutFrequency);
                err_factor = native_sampling_rate/data(k).fs;
    %             if high_cut_enabled || low_cut_enabled
    %                 data(k).header.DspHighCutFrequency = 
                assumed_delay = str2double(data(k).header.DspFilterDelay_us);
                correct_delay = ntaps./params.native_sampling_rate/2*1e6;

                delay_correction = assumed_delay-correct_delay;

                data(k).header.ApplicationName = sprintf('%s subsampling bug fix applied by extraction script.',deblank(data(k).header.ApplicationName));
                data(k).header.SubsamplingBugFix = 'True';
                ccl = {'True','False'};
                data(k).header.SubsamplingBugFixDataResampled = ccl{shift_data+1};
                data(k).header.BugFixDelayCorrection = sprintf('%f',delay_correction);
                data(k).header.DspFilterDelay_us = sprintf('%i',round(correct_delay));
                if high_cut_enabled
                    data(k).header.DspHighCutFrequency = sprintf('%f',high_cut_freq*err_factor);
                end
                if low_cut_enabled
                     data(k).header.DspLowCutFrequency = sprintf('%f',low_cut_freq*err_factor);
                end
            end
        end
        
    else
        warned = []; %#ok<*NASGU>
    end
    
    
    params.ndatabytes = round(log2(str2num(data(k).header.ADMaxValue))+1)/8;
    
    params.nsamp  = (str2num(data(k).header.RecordSize)-params.samphead_bytes)./params.ndatabytes;
    
    params.scale = str2num(data(k).header.ADBitVolts)*params.unitVscale;
    
    if params.enforce_polarity && strcmpi(data(k).header.InputInverted,'true')
        warning(sprintf('The "InputInverted" flag is "True." Data sign will be flipped to compensate for this.\nSet params.enforce_polarity = false if this is not what you want'))
        params.scale = -params.scale;
        data(k).header.InputInverted = 'False';
    elseif strcmpi(data(k).header.InputInverted,'true')
        warning(sprintf('The "InputInverted" flag is "True." \nSet params.enforce_polarity = true to automatically compensate for this by flipping the sign.')) %#ok<*SPWRN>
       
    end
        
    
    % get the sampleheader_values
     skip = 0;
    databytes = params.ndatabytes*params.nsamp;
    for kk = 1:length(sampheadfn)
        fseek(fid,params.header_bytes+skip,-1);
        data(k).(sampheadfn{kk}) = fread(fid,[params.samphead.(sampheadfn{kk}),'=>',params.samphead.(sampheadfn{kk})],databytes+params.samphead_bytes-sampheadbyteN(kk));
        skip = skip+sampheadbyteN(kk);
    end
    if ~params.headers_only
       % Get the data
		fseek(fid,params.header_bytes+skip,-1);    
		data(k).dat = fread(fid,sprintf('%i*%s=>single',params.nsamp,params.data_precision),params.samphead_bytes)*params.scale;
		nrec = length(data(k).TimeStamp);
		recsz = length(data(k).dat)/nrec;
		
		%%%% Correct the sampling frequency based on time stamps. These imply a
		%%%% slightly different rate than the nominal rate.
		dts = double(diff(data(k).TimeStamp))/1e6;
		blockfs = recsz./dts;
		gaps = abs(dts.*(blockfs-data(k).fs))>1;
        if min(blockfs) > data(k).fs*.9
            if k ==1 && isempty(warned2)
              warning('Sampling rate reported the header, %g, does not appear to match the measured acquisition rate, %g!\nGoing with the measured rate.',data(k).fs,mean(blockfs))
              warned2=true;
            end
            gaps(:)=false;
        end
        data(k).fs = mean(blockfs(~gaps)); %%% This is the average sampling rate based on the time stamps
		
		time_stamp = repmat((0:recsz-1)'/data(k).fs,1,nrec)+repmat(double(data(k).TimeStamp-data(k).TimeStamp(1))'/1e6,recsz,1);
		time_stamp = time_stamp(:);
		dtstamp = diff(round(time_stamp*data(k).fs));
	%     tsamp = round(time_stamp*data(k).fs)+1;
	%     time_compensator = zeros(max(tsamp),1);
	%     time_compensator(tsamp) = 1:length(data(k).dat);
	%     gaps = time_compensator==0;
	%     time_compensator = time_compensator + cumsum([diff(gaps);0].*time_compensator).*gaps;
	%     time_compensator = sparse([1;diff(time_compensator)]-1);
	%     dtsamp = round(diff(time_stamp*data(k).fs));
		time_compensator = zeros(sum(dtstamp),1);
		time_compensator(cumsum(dtstamp)) = -dtstamp+1;
		time_compensator=sparse(time_compensator);
		tgap = find(time_compensator<0);
		gap = sparse(zeros(length(time_compensator),1));
        for kk=1:length(tgap) % Fill the gaps with constant data
            gap(tgap(kk)+[0,time_compensator(tgap(kk))])=[1, -1 ];
            time_compensator(tgap(kk)) = 0;
        end
%         tcomp = diff([cumsum([time_compensator;0]+1)]).*(1-cumsum(gap));
        
		data(k).gap_boundaries = gap;
		
	%     time_compensator = sparse(time_compensator);
	%     time_compensator =sparse(ones(1,nrec),1:nrec,[0,diff(double(data(k).TimeStamp'-data(k).TimeStamp(1)))/1e6 - recsz/data(k).fs],recsz,nrec);
		
		data(k).time_compensator = time_compensator;
		
		
		data(k).total_sample_time_gap = sum(abs(time_compensator));
     else
%          for kk = 1:length(sampheadfn)
%             
%             data(k).(sampheadfn{kk}) = [];
%         end
        data(k).dat=[];
        data(k).gap_boundaries=[];
        data(k).time_compensator=[];
       data(k).total_sample_time_gap =[];
    end
    [~,data(k).name] = fileparts(fn);
    switch params.unitVscale
        case 1e6
            data(k).units='uV';
        case 1e3
            data(k).units='mV';
        case 1
            data(k).units='V';
        otherwise
             data(k).units=sprintf('%fxV',params.unitVscale);
    end
    data(k).time_fmt = 'unix_usec';   
    data(k).file = fnames{k};
    data(k).path= path;
    
    if delay_correction~=0 
        if ~shift_data
            data(k).TimeStamp = data(k).TimeStamp+uint64(round(delay_correction));
        elseif ~params.headers_only
            ndelay = round(delay_correction/1e6*data(k).fs);
            data(k).dat = circshift(data(k).dat,[ndelay 0]);
            if k==1
                warning(sprintf('Data have been shifted by %i samples to compensate for the timing bug.\nThis may have unintended consquences; for example, changes during data acquisition will not align with the start of a frame. \nThe recommended way to handle this is to apply the correction to time stamps. Your scripts should be reconciling event times based on the time stamps, anyway, not on the assumption that recordings are synchronous in all channels.\nOK, you''ve been warned.',ndelay) ) 
            end

        end     
    end
    warned = true;
end
fclose(fid);
