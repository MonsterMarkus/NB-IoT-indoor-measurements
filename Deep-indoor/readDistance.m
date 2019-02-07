function distance = readDistance(lidar_dev)
%Read and return result of distance measurement. Arduino and i2c
%connectivity with Lidar need to be initialised beforehand.
%1. Read and save 2 bytes from register 0x8f
%2. Shift the first value from 0x8f << 8 and add to the second value from
%0x8f. The result is the measured distance in centimetres.


highByte = readRegister(lidar_dev, 15, 'uint8');
lowByte = readRegister(lidar_dev, 16, 'uint8');


distance = typecast([lowByte highByte],'uint16');%bitor(bitshift(highByte, 8), lowByte);

end