// (c) adafruit industries - public domain!

#include "ST7565.h"
#include <avr/sleep.h>

int ledPin =  13;    // LED connected to digital pin 13
unsigned int val = 0;//for breathalyzer
unsigned char PIN = 0; //breathalyzer
int intNumber = 1023; // the inter number range is from -32767 to 32767.
 char ST1[10]; //char array or string
 char bar[21]; //horizontal graph
 const int buttonPin = 3; //pin that button is attached to
int buttonState = 0; //variable for reading button status
int wakePin = 2;
int sleepStatus = 0;
int count = 0;
int runningAverage = 0;
int justSlept = 0;
int average = 0;

//#define BACKLIGHT_LED 10
// The setup() method runs once, when the sketch starts

ST7565 glcd(9, 8, 7, 6, 5);

#define LOGO16_GLCD_HEIGHT 16 
#define LOGO16_GLCD_WIDTH  16 

void wakeUpNow(){
//if you want to do anything after waking up before heading to the main loop, 
//do it here.
}


void setup()   {   

  ///////////////////////////////////////
  // Setup pins, show splash screen, and
  // show text warning.
  ///////////////////////////////////////
  
//  Serial.begin(9600);

//  Serial.print(freeRam());
  
//  pinMode(BACKLIGHT_LED, OUTPUT);
 // digitalWrite(BACKLIGHT_LED, HIGH);
pinMode(wakePin, INPUT);
pinMode(PIN,INPUT); //MQ-3 sensor
pinMode(buttonPin, INPUT); //button  

attachInterrupt(0, wakeUpNow, HIGH); //use interrupt 0 (pin 2) and run wakeUpNow()
                                     //when pin 2 goes low.
  glcd.st7565_init();
  glcd.st7565_command(CMD_DISPLAY_ON);
  glcd.st7565_command(CMD_SET_ALLPTS_NORMAL);
  glcd.st7565_set_brightness(0x18);

  glcd.display(); // show splashscreen
  delay(3000);
  glcd.clear();

  // draw a string at location (0,0)
  glcd.drawstring(0, 0, "Warning: Do NOT      use these results to  decide if you should drive.  If you drank at all, DO NOT DRIVE ");
  glcd.display();
  delay(6000);
  glcd.clear();
  
  // clear screen
  glcd.clear();

  
}

void sleepNow()         // here we put the arduino to sleep
{
    /* Now is the time to set the sleep mode. In the Atmega8 datasheet
     * http://www.atmel.com/dyn/resources/prod_documents/doc2486.pdf on page 35
     * there is a list of sleep modes which explains which clocks and 
     * wake up sources are available in which sleep mode.
     *
     * In the avr/sleep.h file, the call names of these sleep modes are to be found:
     *
     * The 5 different modes are:
     *     SLEEP_MODE_IDLE         -the least power savings 
     *     SLEEP_MODE_ADC
     *     SLEEP_MODE_PWR_SAVE
     *     SLEEP_MODE_STANDBY
     *     SLEEP_MODE_PWR_DOWN     -the most power savings
     *
     */  
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);   // sleep mode is set here

    sleep_enable();          // enables the sleep bit in the mcucr register
                             // so sleep is possible. just a safety pin 

    /* Now it is time to enable an interrupt. We do it here so an 
     * accidentally pushed interrupt button doesn't interrupt 
     * our running program. if you want to be able to run 
     * interrupt code besides the sleep function, place it in 
     * setup() for example.
     * 
     * In the function call attachInterrupt(A, B, C)
     * A   can be either 0 or 1 for interrupts on pin 2 or 3.   
     * 
     * B   Name of a function you want to execute at interrupt for A.
     *
     * C   Trigger mode of the interrupt pin. can be:
     *             LOW        a low level triggers
     *             CHANGE     a change in level triggers
     *             RISING     a rising edge of a level triggers
     *             FALLING    a falling edge of a level triggers
     *
     * In all but the IDLE sleep modes only LOW can be used.
     */

    attachInterrupt(0,wakeUpNow, HIGH); // use interrupt 0 (pin 2) and run function
                                       // wakeUpNow when pin 2 gets LOW 

    sleep_mode();            // here the device is actually put to sleep!!
                             // THE PROGRAM CONTINUES FROM HERE AFTER WAKING UP

    sleep_disable();         // first thing after waking from sleep:
                             // disable sleep...
    detachInterrupt(0);      // disables interrupt 0 on pin 2 so the 
                             // wakeUpNow code will not be executed 
                             // during normal running time.

}


void loop()                     
{

  //////////////////////
  //////////////////////
  // Main program loop//
  //////////////////////
  //////////////////////
  
val = analogRead(PIN);
buttonState = digitalRead(buttonPin);
//Serial.println(val);
delay(500);
glcd.clear();
 if(buttonState == LOW){
 //if the button isn't pushed, show sensor data
 runningAverage = runningAverage + val;

if(justSlept = 1){
 count = 0;
 justSlept = 0;
}
  /*
if(count < 6 ){ //calibrate sensor
  runningAverage = runningAverage + val;
count = count + 1;
 if(count == 0) glcd.drawstring(0, 0, "Calibrating. Please  wait");
 if(count == 1) glcd.drawstring(0, 0, "Calibrating. Please  wait.");
 if(count == 2) glcd.drawstring(0, 0, "Calibrating. Please  wait..");
 if(count == 3) glcd.drawstring(0, 0, "Calibrating. Please  wait...");
 if(count == 4) glcd.drawstring(0, 0, "Calibrating. Please  wait....");
 if(count == 5) glcd.drawstring(0, 0, "Calibrating. Please  wait.....");
 if(count > 5) glcd.drawstring(0, 0, "Calibrating. Please  wait.......");
 glcd.display();
 // runningAverage = runningAverage + val;
//count = count + 1;
} else {
  */
//  average = runningAverage/5;
  
  
   itoa(val, ST1, 10); // covert the sensor value (an int) to a string  
  // print current sensor value at the top left corner
  //order is (column, row, string)
  //each column is the height of a character, it's not 64
  glcd.drawstring(0, 0, "Raw value: ");
  glcd.drawstring(64, 0, ST1);
  
//display a horizontal bar graph of BAC
//bar is 50 long
//replace these with drawing the string in each if statement
if(val <= 51){
  glcd.drawstring(0, 2, "|                   ");
  glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 51 && val <= 102){
  glcd.drawstring(0, 2, "||                  ");
  glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 102 && val <= 153){
   glcd.drawstring(0, 2, "|||                 ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 153 && val <= 204){
   glcd.drawstring(0, 2, "||||                ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 204 && val <= 255){
   glcd.drawstring(0, 2, "|||||               ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 255 && val <= 306){
   glcd.drawstring(0, 2, "||||||              ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 306 && val <= 357){
   glcd.drawstring(0, 2, "|||||||             ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 357 && val <= 408){
   glcd.drawstring(0, 2, "||||||||            ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 408 && val <= 459){
   glcd.drawstring(0, 2, "|||||||||           ");
   glcd.drawstring(0, 4, "You probably aren't  drunk");
}
if(val > 459 && val <= 510){
   glcd.drawstring(0, 2, "||||||||||          ");
   glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 510 && val <= 561){
   glcd.drawstring(0, 2, "|||||||||||         ");
   glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 561 && val <= 612){
  glcd.drawstring(0, 2, "||||||||||||       ");
  glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 612 && val <= 663){
   glcd.drawstring(0, 2, "|||||||||||||       ");
   glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 663 && val <= 714){
   glcd.drawstring(0, 2, "||||||||||||||      ");
   glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 714 && val <= 765){
   glcd.drawstring(0, 2, "|||||||||||||||     ");
   glcd.drawstring(0, 4, "You might be a little drunk");
}
if(val > 765 && val <= 816){
   glcd.drawstring(0, 2, "||||||||||||||||    ");
   glcd.drawstring(0, 4, "You're drunk");
}
if(val > 816 && val <= 867){
   glcd.drawstring(0, 2, "||||||||||||||||   ");
   glcd.drawstring(0, 4, "You're drunk");
}
if(val > 867 && val <= 918){
   glcd.drawstring(0, 2, "||||||||||||||||||  ");
   glcd.drawstring(0, 4, "You're drunk");
}
if(val > 918 && val <= 969){
   glcd.drawstring(0, 2, "||||||||||||||||||| ");
   glcd.drawstring(0, 4, "You're super drunk");
}
if(val > 969 && val <= 1023){
   glcd.drawstring(0, 2, "||||||||||||||||||||");
   glcd.drawstring(0, 4, "You're super drunk");
}

//glcd.drawstring(0, 27, bar);

//display text telling how drunk they are
  //drunkness = 'testing';
//glcd.drawstring(0, 63, drunkness);
  
  
  glcd.display();
  delay(500);
 
//}
}
else {
 //if the button is pushed, go to sleep mode until it's pushed again
 justSlept = 1;
 glcd.clear();
 glcd.drawstring(0, 0, "Sleeping...");
 glcd.display();
 delay(1000);
 glcd.clear();
  glcd.drawstring(0, 0, "           ");
 glcd.display();
 glcd.clear();
 delay(100);
  sleepNow();
  
  }
}
////////////////////
// Other functions
///////////////////

// this handy function will return the number of bytes currently free in RAM, great for debugging!   
int freeRam(void)
{
  extern int  __bss_end; 
  extern int  *__brkval; 
  int free_memory; 
  if((int)__brkval == 0) {
    free_memory = ((int)&free_memory) - ((int)&__bss_end); 
  }
  else {
    free_memory = ((int)&free_memory) - ((int)__brkval); 
  }
  return free_memory; 
} 


#define NUMFLAKES 10
#define XPOS 0
#define YPOS 1
#define DELTAY 2



void testdrawchar(void) {
  for (uint8_t i=0; i < 168; i++) {
    glcd.drawchar((i % 21) * 6, i/21, i);
  }    
}

void testdrawcircle(void) {
  for (uint8_t i=0; i<64; i+=2) {
    glcd.drawcircle(63, 31, i, BLACK);
  }
}


void testdrawrect(void) {
  for (uint8_t i=0; i<64; i+=2) {
    glcd.drawrect(i, i, 128-i, 64-i, BLACK);
  }
}

void testfillrect(void) {
  for (uint8_t i=0; i<64; i++) {
      // alternate colors for moire effect
    glcd.fillrect(i, i, 128-i, 64-i, i%2);
  }
}

void testdrawline() {
  for (uint8_t i=0; i<128; i+=4) {
    glcd.drawline(0, 0, i, 63, BLACK);
  }
  for (uint8_t i=0; i<64; i+=4) {
    glcd.drawline(0, 0, 127, i, BLACK);
  }

  glcd.display();
  delay(1000);

  for (uint8_t i=0; i<128; i+=4) {
    glcd.drawline(i, 63, 0, 0, WHITE);
  }
  for (uint8_t i=0; i<64; i+=4) {
    glcd.drawline(127, i, 0, 0, WHITE);
  }
}