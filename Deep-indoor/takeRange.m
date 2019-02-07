function takeRange(lidar_dev)
%Initiate a distance measurement by writing 0x01 to register 0x00.
%NOTE: arduino connectivity and i2c lidar object need to be initiated 
%beforehand!

writeRegister(lidar_dev, 0, 1, 'uint8');

end