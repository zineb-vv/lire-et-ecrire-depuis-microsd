/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp32-microsd-card-arduino/
  
  This sketch can be found at: Examples > SD(esp32) > SD_Test
*/
#include <Arduino.h>
#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include <ArduinoJson.h>
#include <WiFi.h>
#include <HTTPClient.h>

#define Z 5
char dataToPost[150] = "";
int wr = 0;
int p = 55;
int v = 4;
int o = 33;

String server = "";
String userName = "";

const char *ssid = "HUAWEI-8e4e";
const char *password = "ifran123";
//Your Domain name with URL path or IP address with path
String serverName = "http://velovolt.ddns.net:1880/moaad/";

void wifiPrint(String message);

/*ALL WHAT YOU CAN DO WITH A FILE*/
/*LISTING YOUR FILES*/
void listDir(fs::FS &fs, const char *dirname, uint8_t levels)
{
  Serial.printf("Listing directory: %s\n", dirname);

  File root = fs.open(dirname);
  if (!root)
  {
    Serial.println("Failed to open directory");
    return;
  }
  if (!root.isDirectory())
  {
    Serial.println("Not a directory");
    return;
  }

  File file = root.openNextFile();
  while (file)
  {
    if (file.isDirectory())
    {
      Serial.print("  DIR : ");
      Serial.println(file.name());
      if (levels)
      {
        listDir(fs, file.name(), levels - 1);
      }
    }
    else
    {
      Serial.print("  FILE: ");
      Serial.print(file.name());
      Serial.print("  SIZE: ");
      Serial.println(file.size());
    }
    file = root.openNextFile();
  }
}

void createDir(fs::FS &fs, const char *path)
{
  Serial.printf("Creating Dir: %s\n", path);
  if (fs.mkdir(path))
  {
    Serial.println("Dir created");
  }
  else
  {
    Serial.println("mkdir failed");
  }
}

void removeDir(fs::FS &fs, const char *path)
{
  Serial.printf("Removing Dir: %s\n", path);
  if (fs.rmdir(path))
  {
    Serial.println("Dir removed");
  }
  else
  {
    Serial.println("rmdir failed");
  }
}

void readFile(fs::FS &fs, const char *path)
{
  Serial.printf("Reading file: %s\n", path);

  File file = fs.open(path);

  if (!file)
  {
    Serial.println("Failed to open file for reading");
    return;
  }

  Serial.print("Read from file: ");
  while (file.available())
  {
    /*affiche ce qu'on a ecrit*/ Serial.write(file.read());
   
  }
  file.close();
}

void writeFile(fs::FS &fs, const char *path, const char *message)
{
  Serial.printf("Writing file: %s\n", path);

  File file = fs.open(path, FILE_WRITE);
  
  if (!file)
  {
    Serial.println("Failed to open file for writing");
    return;
  }
  if (file.print(message))
  { 
    // char *target="}";
    // file.find((char *)target);
    Serial.println("File written");

  }
  else
  {
    Serial.println("Write failed");
  }
  file.close();
}

void INTappendFile(fs::FS &fs, const char *path, int j)
{
  Serial.printf("Writing file: %s\n", path);

  File file = fs.open(path, FILE_APPEND);
  if (!file)
  {
    Serial.println("Failed to open file for writing");
    return;
  }
  if (file.print(j))
  {
    Serial.println("File written");
  }
  else
  {
    Serial.println("Write failed");
  }
  file.close();
}

void appendFile(fs::FS &fs, const char *path, const char *message)
{
  Serial.printf("Appending to file: %s\n", path);

  File file = fs.open(path, FILE_APPEND);
  if (!file)
  {
    Serial.println("Failed to open file for appending");
    return;
  }
  if (file.print(message))
  {   
    //const char* ta=;
    
    file.find("X");
    Serial.write(file.find("X"));
    Serial.println("Message appended");
  }
  else
  {
    Serial.println("Append failed");
  }
  file.close();
}

void renameFile(fs::FS &fs, const char *path1, const char *path2)
{
  Serial.printf("Renaming file %s to %s\n", path1, path2);
  if (fs.rename(path1, path2))
  {
    Serial.println("File renamed");
  }
  else
  {
    Serial.println("Rename failed");
  }
}

void deleteFile(fs::FS &fs, const char *path)
{
  Serial.printf("Deleting file: %s\n", path);
  if (fs.remove(path))
  {
    Serial.println("File deleted");
  }
  else
  {
    Serial.println("Delete failed");
  }
}

void testFileIO(fs::FS &fs, const char *path)
{
  File file = fs.open(path);
  static uint8_t buf[512];
  size_t len = 0;
  uint32_t start = millis();
  uint32_t end = start;
  if (file)
  {
    len = file.size();
    size_t flen = len;
    start = millis();
    while (len)
    {
      size_t toRead = len;
      if (toRead > 512)
      {
        toRead = 512;
      }
      file.read(buf, toRead);
      len -= toRead;
    }
    end = millis() - start;
    Serial.printf("%u bytes read for %u ms\n", flen, end);
    file.close();
  }
  else
  {
    Serial.println("Failed to open file for reading");
  }

  file = fs.open(path, FILE_WRITE);
  if (!file)
  {
    Serial.println("Failed to open file for writing");
    return;
  }

  size_t i;
  start = millis();
  for (i = 0; i < 2048; i++)
  {
    file.write(buf, 512);
  }
  end = millis() - start;
  Serial.printf("%u bytes written for %u ms\n", 2048 * 512, end);
  file.close();
}
/*reading from a number*/
void pointReadingFile(fs::FS &fs, const char *path)
{
  Serial.printf("Reading file: %s\n", path);

  File file = fs.open(path);

  if (!file)
  {
    Serial.println("Failed to open file for reading");
    return;
  }

  char _rx_buffer[200];
  size_t frameSize = 8;
  file.readBytes((char *)_rx_buffer, frameSize);

  Serial.print("Read from file: ");
  while (file.available())
  {
    /*affiche ce qu'on a ecrit*/ Serial.write(file.read());
  }
  file.close();
}

/*append what it was incrimented*/
void benimAppendedFile(fs::FS &fs, const char *path, int i)
{
  Serial.printf("Writing file: %s\n", path);

  File file = fs.open(path, FILE_APPEND);
  if (!file)
  {
    Serial.println("Failed to open file for writing");
    return;
  }

  for (i = 0; i < 50; i++)
  { /*FILE PRINT IS A FILE WRITING FUNCTION*/
    if (file.print(i))
    {
      Serial.println("File written");
    }
    else
    {
      Serial.println("Write failed");
    }
  }

  file.close();
}

void setup()
{
  Serial.begin(9600);
  while (!Serial)
  {
    ;
  }

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
  }
  // String IPWifi = WiFi.localIP().toString();

  if (!SD.begin(5))
  {
    Serial.println("Card Mount Failed");
    return;
  }
  uint8_t cardType = SD.cardType();

  if (cardType == CARD_NONE)
  {
    Serial.println("No SD card attached");
    return;
  }

  Serial.print("SD Card Type: ");
  if (cardType == CARD_MMC)
  {
    Serial.println("MMC");
  }
  else if (cardType == CARD_SD)
  {
    Serial.println("SDSC");
  }
  else if (cardType == CARD_SDHC)
  {
    Serial.println("SDHC");
  }
  else
  {
    Serial.println("UNKNOWN");
  }

  uint64_t cardSize = SD.cardSize() / (1024 * 1024);
  Serial.printf("SD Card Size: %lluMB\n", cardSize);

  writeFile(SD, "/hello.txt", "hello everyone my name is zeyno oyle darlarke onlar ve ban bunu dedan çok sevyoruùm!\n");
  /*add writing to the file*/
  appendFile(SD, "/hello.txt", "world!\n");

  int i;

  for (i = 0; i < Z; i++)
  {

    if (i == 0)
    {
      sprintf(dataToPost, "[{\"X\":\"%d,%d,%d\"},", p, v, o);
    }

    if (i >= 1 && i < (Z - 1))
    {
      sprintf(dataToPost, "{\"X\":\"%d,%d,%d\"},", p, v, o);
    }
    if (i == (Z - 1))
    {
      sprintf(dataToPost, "{\"X\":\"%d,%d,%d\"}]", p, v, o);
    }
    p = p + 1;
    v = v + 1;
    o = o + 1;
    wr = wr + 1;
    appendFile(SD, "/hello.txt", dataToPost);
    wifiPrint(dataToPost);
    //httpPost(dataToPost);
  }
  Serial.print("wslouk ");
  Serial.print(wr);
  Serial.print(" points LATGOLO MA");
  writeFile(SD, "/numero de point LU.txt", "ON A RECU  ");

  INTappendFile(SD, "/numero de point LU.txt", wr);
  appendFile(SD, "/numero de point LU.txt", " POINTS :)  ");
  readFile(SD, "/numero de point LU.txt");

  //listDir(SD, "/", 0);
  //createDir(SD, "/mydir");
  //listDir(SD, "/", 0);
  //removeDir(SD, "/mydir");
  //listDir(SD, "/", 2);

  //benimAppendedFile (SD, "/hello.txt", 21);
  //readFile(SD, "/hello.txt");

  // deleteFile(SD, "/foo.txt");
  // renameFile(SD, "/hello.txt", "/foo.txt");
  readFile(SD, "/hello.txt");

  // testFileIO(SD, "/test.txt");
  //Serial.printf("Total space: %lluMB\n", SD.totalBytes() / (1024 * 1024));
  //Serial.printf("Used space: %lluMB\n", SD.usedBytes() / (1024 * 1024));
  //pointReadingFile(SD, "/hello.txt");
}
void wifiPrint(String message)
{
  for (uint16_t i = 0; i < message.length(); i++)
  {
    if (message[i] == ' ')
    {
      message[i] = '-';
    }
  }
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;

    String serverPath = serverName + message;

    // Your Domain name with URL path or IP address with path
    http.begin(serverPath.c_str());

    // Send HTTP GET request
    int httpResponseCode = http.GET();

    if (httpResponseCode > 0)
    {
      // //Serial.print("HTTP Response code: ");
      // //Serial.println(httpResponseCode);
      String payload = http.getString();
      // //Serial.println(payload);
    }
    else
    {
      // //Serial.print("Error code: ");
      // //Serial.println(httpResponseCode);
    }
    // Free resources
    http.end();
  }
  else
  {
    // //Serial.println("WiFi Disconnected");
  }
}

void loop()
{
}



