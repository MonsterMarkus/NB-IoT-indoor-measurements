/*This script can be used to verify proper I2C addressing 
 * and communication with LIDAR lasers. 
 * After power cycle both LIDARs keep the default address 0x62.
 * In order to fix this problem do the following:
 * 1. Connect only one LIDAR (unplug SDA and SCL of the other one)
 * 2. Uncomment the !!! lines and upload the code. Ensure that 0x61
 * device is found
 * 3. Comment the !!! lines and upload the code again. You should
 * see 2 devices: 0x61 and 0x62.
*/

#include <Wire.h>
#include <I2C.h> //!!!
#include <LIDARLite_v3HP.h>

LIDARLite_v3HP l;
 
void setup()
{

  Serial.begin(9600);

  Serial.println("\nI2C Scanner");
  Wire.begin();
  Wire.setClock(400000UL);
  l.setI2Caddr(0x61, 1, 0x62); //!!!
  //l.read(0x16, addr, 2, 0x61);

  I2c.begin(); //!!!
  I2c.setSpeed(1); //!!! //400kHz
}
 
 
void loop()
{

  I2c.scan(); //!!!
  delay(5000); //!!!
}

