%Postprocessing of data for deep indoor measurements
function P = postprocess(fileID_arduino,fileID_TSMW)
%load the .mat file
load(fileID_arduino, 'data', 'metaData', 'timeStamp');

%load the .txt file
TSMW_table = readtable(fileID_TSMW);

%%%%%%find the earliest entry
TSMW_start = [char(TSMW_table{2,1}) ' ' char(TSMW_table{2,2})];
%remove ';'
TSMW_start = TSMW_start(1:end-1);

d = milliseconds(datetime(char(timeStamp(1)),'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS')-datetime(TSMW_start,'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS'));
if d<=0     %arduino mesurements starts before TSMW
   %remove early measurements from arduino data.
   
else        %TSMW measurement starts before arduino
   %remove early measurements from TSMW data
   T = char(TSMW_table{:,2}); %Create array of TSMW timestamps with seconds precision
   T = T(:,1:end-5);
   S = char(timeStamp(1)); %Create 1st timestamp of arduino with seconds precision
   S = S(13:end-4);
   f = ismember(T,S,'rows');
   f = find(f);
   index = f(1);
   TSMW_table = TSMW_table{index:end,:};
   TSMW_start = [char(TSMW_table{2,1}) ' ' char(TSMW_table{2,2})];
   TSMW_start = TSMW_start(1:end-1);
   %convert the timestamps to differences in milliseconds
    m = zeros(length(timeStamp),1);
    for i=1:length(timeStamp)
        %convert the arduino measurements
        m(i) = milliseconds(datetime(char(timeStamp(i)),'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS')-datetime(TSMW_start,'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS'));

    end
    n = zeros(length(TSMW_table),1);
    for i =2:length(TSMW_table)
        %convert the TSMW measurements
        TSMW_now = [char(TSMW_table{i,1}) ' ' char(TSMW_table{i,2})];
        TSMW_now = TSMW_now(1:end-1);
        n(i) = milliseconds(datetime(TSMW_now,'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS')-datetime(TSMW_start,'InputFormat','d-MMM-y HH:mm:ss:SSSSSSS'));

    end
   
end

%Remove last indecies
if n(end) > m(end)
    n=n(n-500<m(end));
    TSMW_table = TSMW_table(1:length(n),:);
else
    m=m(m<n(end));
    data = data(:,1:length(m));
    timeStamp= timeStamp(1:length(m));
end

%Retrieve power measurements from TSMW
PW = zeros(length(n),1);
for i=1:length(n)
    PW(i) = str2double(TSMW_table{i,3});
end


%Calculate a power for each arduino measurement
P = zeros(1,length(m));
for i =1:length(P)
    
    if i ==1
        p =  PW(n<m(1));
    elseif i== length(P)
        p = PW(n>m(end));
    else
        k = n> m(i)-300;
        l = n< m(i)+300;
        p= PW(k==l);
    end
    
    P(i) = mean(p);
    
end


end



