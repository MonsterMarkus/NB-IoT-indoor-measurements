/*------------------------------------------------------------------------------

  LIDARLite Arduino Library
  v3HP/v3HP_I2C

  This example shows methods for running the LIDAR-Lite v3 HP in various
  modes of operation. To exercise the examples open a serial terminal
  program (or the Serial Monitor in the Arduino IDE) and send ASCII
  characters to trigger the commands. See "loop" function for details.

  Connections:
  LIDAR-Lite 5 Vdc (red) to Arduino 5v
  LIDAR-Lite I2C SCL (green) to Arduino SCL
  LIDAR-Lite I2C SDA (blue) to Arduino SDA
  LIDAR-Lite Ground (black) to Arduino GND

  (Capacitor recommended to mitigate inrush current when device is enabled)
  680uF capacitor (+) to Arduino 5v
  680uF capacitor (-) to Arduino GND

  See the Operation Manual for wiring diagrams and more information:
  http://static.garmin.com/pumac/LIDAR_Lite_v3HP_Operation_Manual_and_Technical_Specifications.pdf

------------------------------------------------------------------------------*/

#include <stdint.h>
#include <Wire.h>
#include <LIDARLite_v3HP.h>

LIDARLite_v3HP lidarX;//, lidarY; //lidarX has address 0x61, lidarY 0x62 

#define FAST_I2C
#define LIDARX 0x61
#define LIDARY 0x62

enum rangeType_T
{
    RANGE_NONE,
    RANGE_SINGLE,
    RANGE_CONTINUOUS,
    RANGE_TIMER
};

void setup()
{
    uint8_t dataByte;

    // Initialize Arduino serial port (for display of ASCII output to PC)
    Serial.begin(115200);

    // Initialize Arduino I2C (for communication to LidarLite)
    Wire.begin();
    #ifdef FAST_I2C
        #if ARDUINO >= 157
            Wire.setClock(400000UL); // Set I2C frequency to 400kHz (for Arduino Due)
        #else
            TWBR = ((F_CPU / 400000UL) - 16) / 2; // Set I2C frequency to 400kHz
        #endif
    #endif

    // Configure the LidarLite internal parameters so as to lend itself to
    // various modes of operation by altering 'configure' input integer to
    // anything in the range of 0 to 5. See LIDARLite_v3HP.cpp for details.
    lidarX.configure(0, LIDARX);
    lidarX.configure(0, LIDARY);
}


void loop()
{
    uint16_t distance, *test = NULL;
    uint8_t  newDistance = 0;
    uint8_t  c;
    rangeType_T rangeMode = RANGE_NONE;
    char textToPrint[10];

    // Continuous loop
    while (1)
    {
        // Each time through the loop, look for a serial input character
        if (Serial.available() > 0)
        {
            //  read input character ...
            c = (uint8_t) Serial.read();

            // ... and parse
            switch (c)
            {
                case 'S':
                case 's':
                    rangeMode = RANGE_SINGLE;
                    break;

                case 'C':
                case 'c':
                    rangeMode = RANGE_CONTINUOUS;
                    break;

                case 'T':
                case 't':
                    rangeMode = RANGE_TIMER;
                    break;

                case '.':
                    rangeMode = RANGE_NONE;
                    break;

                case 'D':
                case 'd':
                    rangeMode = RANGE_NONE;
                    dumpCorrelationRecord();
                    break;

                case 0x0D:
                case 0x0A:
                    break;

                default:
                    Serial.println("=====================================");
                    Serial.println("== Type a single character command ==");
                    Serial.println("=====================================");
                    Serial.println(" S - Single Measurement");
                    Serial.println(" C - Continuous Measurement");
                    Serial.println(" T - Timed Measurement");
                    Serial.println(" . - Stop Measurement");
                    Serial.println(" D - Dump Correlation Record");
                    break;
            }
        }

        switch (rangeMode)
        {
            case RANGE_NONE:
                newDistance = 0;
                break;

            case RANGE_SINGLE:
                test = distanceOnce();
                newDistance = 1;
                break;

            case RANGE_CONTINUOUS:
                //newDistance = distanceContinuous(&distance);
                test = distanceContinuousBoth();
                //delay(500);
                newDistance = 1;
                break;

            case RANGE_TIMER:
                //delay(250); // 4 Hz
                newDistance = distanceFast(&distance);
                break;

            default:
                newDistance = 0;
                break;
        }

        // When there is new distance data, print it to the serial port
        if (newDistance)
        {
            sprintf(textToPrint, "X:%d Y:%d", *test, *(test + 1));
            Serial.println(textToPrint);          
        }

        // Single measurements print once and then stop
        if (rangeMode == RANGE_SINGLE)
        {
            rangeMode = RANGE_NONE;
        }
    }
}

//---------------------------------------------------------------------
// Read Single Distance Measurement
//
// This is the simplest form of taking a measurement. This is a
// blocking function as it will not return until a range has been
// taken and a new distance measurement can be read.
//---------------------------------------------------------------------
uint8_t distanceSingle(uint16_t * distance, uint8_t addr)
{
    // 1. Wait for busyFlag to indicate device is idle. This must be
    //    done before triggering a range measurement.
    lidarX.waitForBusy(addr);

    // 2. Trigger range measurement.
    lidarX.takeRange(addr);

    // 3. Wait for busyFlag to indicate device is idle. This should be
    //    done before reading the distance data that was triggered above.
    lidarX.waitForBusy(addr);

    // 4. Read new distance data from device registers
    *distance = lidarX.readDistance(addr);

    return 1;
}

//Read X and Y distances from the lidars.
uint16_t * distanceOnce()
{
  static uint16_t dist[2];
  //char buf[10];
  
//  lidarX.waitForBusy(addr);
//  lidarX.takeRange(addr);
//  lidarX.waitForBusy(addr);
//  return lidarX.readDistance(addr);

  lidarX.waitForBusy(LIDARX);
  lidarX.takeRange(LIDARX);
  lidarX.waitForBusy(LIDARX);
  dist[0] = lidarX.readDistance(LIDARX);

  lidarX.waitForBusy(LIDARY);
  lidarX.takeRange(LIDARY);
  lidarX.waitForBusy(LIDARY);
  dist[1] = lidarX.readDistance(LIDARY);

  return dist;
}

//
uint16_t * distanceContinuousBoth()
{
  static uint16_t dist[2];
  //ensure that both lidars finished the measurements
  while(lidarX.getBusyFlag(LIDARX) != 0);
  while(lidarX.getBusyFlag(LIDARY) != 0);
  lidarX.takeRange(LIDARX);
  lidarX.takeRange(LIDARY);
  dist[0] = lidarX.readDistance(LIDARX);
  dist[1] = lidarX.readDistance(LIDARY);
  return dist;
}

//---------------------------------------------------------------------
// Read Continuous Distance Measurements
//
// The most recent distance measurement can always be read from
// device registers. Polling for the BUSY flag in the STATUS
// register can alert the user that the distance measurement is new
// and that the next measurement can be initiated. If the device is
// BUSY this function does nothing and returns 0. If the device is
// NOT BUSY this function triggers the next measurement, reads the
// distance data from the previous measurement, and returns 1.
//---------------------------------------------------------------------
uint8_t distanceContinuous(uint16_t * distance)
{
    uint8_t newDistance = 0;

    // Check on busyFlag to indicate if device is idle
    // (meaning = it finished the previously triggered measurement)
    if (lidarX.getBusyFlag(0x61) == 0)
    {
        // Trigger the next range measurement
        lidarX.takeRange(0x61);

        // Read new distance data from device registers
        *distance = lidarX.readDistance(0x61);

        // Report to calling function that we have new data
        newDistance = 1;
    }

    return newDistance;
}

//---------------------------------------------------------------------
// Read Distance Measurement, Quickly
//
// Read distance. The approach is to poll the status register until the device goes
// idle after finishing a measurement, send a new measurement command, then read the
// previous distance data while it is performing the new command.
//---------------------------------------------------------------------
uint8_t distanceFast(uint16_t * distance)
{
    // 1. Wait for busyFlag to indicate device is idle. This must be
    //    done before triggering a range measurement.
    lidarX.waitForBusy(0x61);

    // 2. Trigger range measurement.
    lidarX.takeRange(0x61);

    // 3. Read previous distance data from device registers.
    //    After starting a measurement we can immediately read previous
    //    distance measurement while the current range acquisition is
    //    ongoing. This distance data is valid until the next
    //    measurement finishes. The I2C transaction finishes before new
    //    distance measurement data is acquired.
    *distance = lidarX.readDistance(0x61);

    return 1;
}

//---------------------------------------------------------------------
// Print the correlation record for analysis
//---------------------------------------------------------------------
void dumpCorrelationRecord()
{
    lidarX.correlationRecordToSerial(256, 0x61);
}
