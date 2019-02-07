function waitForBusy(lidar_dev)
%Blocking function to wait until the Lidar Lite's internal busy flag goes 
%low. The only parameter here is the i2cdev object for lidar. NOTE: it is
%assumed that arduino and i2cdev connectivity is already initialised!

%the body of waitForBusy
busyCounter = 0;
busyFlag = 1;

while(busyFlag)
    if(busyCounter > 9999)
        break;
    end
    %register 1 being low means busy, that's why bitand
    busyFlag = bitand(readRegister(lidar_dev, 1, 'uint8'), hex2dec('01'));
        
    busyCounter = busyCounter + 1;
     
end
    
if (busyCounter > 9999)
    disp('bailing out of waitForBusy()');
end

end