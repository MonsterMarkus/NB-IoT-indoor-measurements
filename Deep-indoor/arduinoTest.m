%% Setup measurement
clear all;
%Create filename for easy recognition
%Generate ID:
t = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss:ms Z');
metaData.dstr = datestr(t, 'dd-mmm-yyyy HH:MM:SS:fff');
metaData.ID = '343 001';%metaData.dstr; %Or input specific own ID
metaData.altitude = 105; %Initially 0, can be set or calculated
metaData.building = 'b343'; %Alterntively address
metatData.room = '-1st by the stairs';
metaData.LOS = 'noLOS'; %Set to 'NLOS' for near LOS and 'nLOS' for no LOS
metaData.floor = -1; %ground floor equals 0th floor
metaData.material = 'walls'; %Describes which material walls are made from, e.g. glass, contrete, wood, etc.
metaData.numBarriers = '??'; %number of barriers or walls
metaData.offsetx = 0; %offset in cm
metaData.offsety = 0; %offset in cm
metaData.orientation = 'y points north with angle corresponding to building';
metaData.start = 'Starts in north west corner';

%% Initialize arduino
%IMPORTANT always follow the described steps in the readme file.
a = arduino();
%connect to the lidars (NOTE the addresses should be different!)
LidarX = i2cdev(a, '0x61');
LidarY = i2cdev(a, '0x62');


%% Capture measurements.

data = [0 ; 0 ];
timeStamp = [];
num_measurements = 0;
ref_time = now;

%Press button on pop up figure to terminate.
set(gcf, 'currentchar',' ')
while(get(gcf,'currentchar')==' ')

   %reading process: waitForBusy, takeRange, waitForBusy, readDistance
   waitForBusy(LidarX);
   waitForBusy(LidarY);

   takeRange(LidarX);
   takeRange(LidarY);

   waitForBusy(LidarX);
   waitForBusy(LidarY);

   distX = double(readDistance(LidarX))+metaData.offsetx;
   distY = double(readDistance(LidarY))+metaData.offsety;

   %Write to data
  
   data = [data(1,:) distX; data(2,:) distY;];
   t = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss:ms Z');
   datestring = datestr(t, 'dd-mmm-yyyy HH:MM:SS:fff');
   timeStamp = [timeStamp string(datestring)];

   %fprintf("\n%s, Y: %d\n", datestr(now-ref_time, 'HH:MM:SS.FFF'), distY);
   %fprintf("\n%s, X: %d\n", datestr(now-ref_time, 'HH:MM:SS.FFF'), distX);
   fprintf("\n%s, X: %d. Y: %d\n", datestr(now-ref_time, 'HH:MM:SS.FFF'), distX, distY);
   %fprintf("\n%s, X: %d\n", datestr(now-ref_time, 'HH:MM:SS.FFF'), distX);


   num_measurements = num_measurements + 1;
   pause(0.5)



end
data = data(:,2:end);
fileID =strcat(metaData.ID,'_',num2str(num_measurements),'.mat');
save(fileID , 'data','timeStamp','metaData');
disp(['Done measureing, data stored in file: ', fileID]);
close all;
clear all;