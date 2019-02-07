Arduino IDE option

1. Install Arduino IDE from the official site
2. Ensure that Tools->Board is Arduino Mega 2560
3. Install the .zip libraries from Deep-indoor folder (Sketch->Include library->Add .ZIP library...)
4. Perform BEFORE THE MEASUREMENTS
5. The measurements can be taken by running Lidar programme

Matlab option:

1. Use Matlab 2018b
2. Get the Arduino support package
3. Add all .m files from Deep-indoor folder to Matlab path
4. Perform BEFORE THE MEASUREMENTS
5. The measurements can be taken by running arduinoTest.m 

BEFORE THE MEASUREMENTS and/or after a power cycle of the lasers (no matter which option):

1. Disconnect SDA and SCL wires of one of the LIDARs (blue+green)
2. Run i2c_scanner script in Arduino IDE - it changes the I2C address of the remaining LIDAR from the default one (0x62) to 0x61
3. Connect SDA and SCL wires of the second LIDAR.
4. THe measurements taking scripts in either Arduino IDE or Matlab can be now run.