#!/bin/python

# ./dump1090 --net | python ../share/pollandpicture.py

# Imports
import sys
import subprocess
import re
import math
import time
import sqlite3 as lite
import getopt
import json
from pprint import pprint
from datetime import datetime, date
from subprocess import call

# constants and globals
 
def formNumber (pInputText):
    try:
        return float(pInputText.replace('\r', ''))
    except:
        return float(0)
 
def formText (pInputText):
    return pInputText.replace('\r', '')

def printStuff (pText):
     print "{:%Y%m%d %H:%M:%S} {}".format(datetime.now(), pText)

################################################################################ 
# Setup
textblock = ''
vDebugMode = 0
vSnapMode = 0
vManualBrg=-1
vManualAzm=-1

try:
    opts, args = getopt.getopt(sys.argv[1:],"sda:b:", ["snap", "debug", "azimuth=", "bearing="] )
except getopt.GetoptError:
    print 'piplanepicture.py [-s|--snap] [-d|--debug] [-a XX|--azimuth=XX] [-b YY|--bearing=YY]'
    sys.exit(2)
for opt, arg in opts:
    if opt in ('-d', '--debug') :
        vDebugMode = 1
    elif opt in ('-s', '--snap') :
        vSnapMode = 1
    elif opt in ('-a', '--azimuth'):
        vManualAzm = arg
    elif opt in ('-b', '--bearing'):
        vManualBrg = arg


if vDebugMode == 0: 
    sproc = subprocess.Popen('/home/pi/dump1090/dump1090', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
else:
    print '*** DEBUG MODE ***'
    sproc = subprocess.Popen('cat /home/pi/test/dump1090_test2.txt', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)




################################################################################ 
# Begin main read loop

printStuff('Started')

while True: 
    if vDebugMode == 1: 
        time.sleep(.001)

    line = sproc.stdout.readline()
    textblock = textblock + line
    
    if len(line) == 1:
        # Start of block of info
        searchICAO = re.search( r'(ICAO Address   : )(.*$)', textblock, re.M|re.I)
        searchFeet = re.search( r'(Altitude : )(.*)(feet)(.*$)', textblock, re.M|re.I)
        searchLatitude = re.search( r'(Latitude : )(.*$)', textblock, re.M|re.I)
        searchLongitude = re.search( r'(Longitude: )(.*$)', textblock, re.M|re.I)
        searchIdent = re.search( r'(Identification : )(.*$)', textblock, re.M|re.I)

        if searchICAO and searchIdent:
            valICAO = formText(searchICAO.group(2))
            valIdent = formText(searchIdent.group(2)).strip()
            printStuff('valICAO:{} valIdent:{}'.format(valICAO, valIdent)) 
            call(["./send_kafka",  "ident-topic", valICAO, valIdent])
            #storeAndRefineICAOandCode(valICAO, valIdent)
 
        if searchFeet and searchICAO and searchLatitude and searchLongitude:
            # Found a valid combination 
            valICAO = formText(searchICAO.group(2))
            valFeet = formNumber(searchFeet.group(2))
            valLatitude = formNumber(searchLatitude.group(2))
            valLongitude = formNumber(searchLongitude.group(2))
            printStuff('valICAO:{} valFeet:{} valLatitude:{} valLongitude:{}'.format(valICAO, valFeet, (valLatitude), (valLongitude)))
            # ./send_kafka location-topic ico height location
            call(["./send_kafka",  "location-topic", valICAO, "{}".format(valFeet), "{},{}".format(valLatitude, valLongitude)])
#            processSquark (valICAO, valFeet, (valLatitude), (valLongitude))
 
        # End of block of info
        textblock = ''
    # End of read of line

retval = sproc.wait()
