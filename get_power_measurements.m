function get_power_measurements(id)



[ErrorText,ErrorCode] = TSMWInitInterface;      
if ErrorCode ~= 0
    fprintf(ErrorText);
    fprintf('\n');
    TSMWReleaseInterface;
    return  
end

TSMW_IP = ('192.168.0.2');

%   TSMW Options-structure  
TSMWOptions.Frontends = 3;
TSMWOptions.AMPS_CH1 = 2^32-1;
TSMWOptions.AMPS_CH2 = 2^32-1;
TSMWOptions.Mode = 0;

[ErrorCode, TSMW_ID] = TSMWConnect(TSMW_IP, TSMWOptions);
pause(1); % this may take some moments

if ErrorCode ~= 0
    [ErrorText,ErrorCode] = TSMWGetLastError;
    fprintf(ErrorText);
    fprintf('\n');
    TSMWReleaseInterface;
    return  
end

MeasCtrl = MeasCtrlTemplate_RF1;

% To change several parameters, for example the Number of Samples 
% from 1000 to 10000, do: 
MeasCtrl.MeasCtrl.NoOfSamples       = 1000;
MeasCtrl.ChannelCtrl1.Frequency     = 0.811e9;

[ErrorCode,Meas_ID] =  TSMWIQMeasure(TSMW_ID,[],MeasCtrl); 

if ErrorCode ~= 0
    [ErrorText,ErrorCode] = TSMWGetLastError;
    fprintf(ErrorText);
    fprintf('\n');
    TSMWReleaseInterface;
    return  
end


% Write to file with ID
if ~exist('TSMW_measurements','dir')
	mkdir('TSMW_measurements')
end
fileID = fopen(sprintf('TSMW_measurements/%i.txt',id),'w');
fprintf(fileID,'measurement ID: %i\n', id);


% Do measurements

while true
    %[ErrorCode,Meas_ID] =  TSMWIQMeasure(TSMW_ID,[],MeasCtrl);
	%powerdBm = get_tsmw_measurement(1, TSMW_ID, MeasCtrl);
    %avgPowerdBm = mean(powerdBm);
    
    [ErrorCode,Meas_ID] =  TSMWIQMeasure(TSMW_ID,[],MeasCtrl); 
    [ErrorCode, ResultParam, IData, QData, Scaling, Overflow, Calibrated] = ...
                                TSMWIQGetDataDouble(TSMW_ID, Meas_ID, 10000, ...
                                              MeasCtrl.MeasCtrl.NoOfSamples,1);
    %s(ii) = ResultParam.Fsample;


    if ErrorCode ~= 0
        [ErrorText,ErrorCode] = TSMWGetLastError;
        fprintf(ErrorText);
        fprintf('\n');
        TSMWReleaseInterface;
        return  
    end

    % To get complex values in dBm you have to apply the Scaling factor:
    x = (IData + i*QData) * 10^(double(Scaling)/2000);
    if ~exist('lpFilt')
        lpFilt = designfilt('lowpassiir','FilterOrder',64, ...
                'PassbandFrequency',9e6,'PassbandRipple',0.2, ...
                'SampleRate',ResultParam.Fsample);  
    end
    x_filt = filter(lpFilt,x);

    P = 10*log10(mean(abs(x_filt).^2));

    avgPowerdBm=mean(P);
    
	t = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss:ms Z');
	datestring = datestr(t, 'dd-mmm-yyyy HH:MM:SS:fff');
    disp(datestring)
	fprintf(fileID,'%s; %12.8f\n',datestring, avgPowerdBm);
end

TSMWReleaseInterface
fprintf('TSMW_measurements/%i.txt\n',id)
fclose(fileID);

end