#! /usr/bin/python

"""Copyright 2011 Phidgets Inc.
This work is licensed under the Creative Commons Attribution 2.5 Canada License.
To view a copy of this license, visit http://creativecommons.org/licenses/by/2.5/ca/
"""

__author__="Adam Stelmack"
__version__="2.1.8"
__date__ ="14-Jan-2011 2:29:14 PM"

"""edited by Jon Renslo for testing the dry adhesive human-climbing panel
   7/30/13
   added multiple ports and set interval to take data
    8/1/13
    added file output to csv format
    added command line support: Bridge-4panel_setup.py dataRate (in ms) dataTime(in s)
    
"""

#Basic imports
import sys
from time import *
from datetime import *
#Phidget specific imports
from Phidgets.PhidgetException import PhidgetException
from Phidgets.Devices.Bridge import Bridge, BridgeGain
from optparse import OptionParser


#Create a bridge object
try:
    bridge = Bridge()
except RuntimeError as e:
    print("Runtime Exception: %s" % e.details)
    print("Exiting....")
    exit(1)

#Information Display Function
def displayDeviceInfo():
    print("|------------|----------------------------------|--------------|------------|")
    print("|- Attached -|-              Type              -|- Serial No. -|-  Version -|")
    print("|------------|----------------------------------|--------------|------------|")
    print("|- %8s -|- %30s -|- %10d -|- %8d -|" % (bridge.isAttached(), bridge.getDeviceName(), bridge.getSerialNum(), bridge.getDeviceVersion()))
    print("|------------|----------------------------------|--------------|------------|")
    print("Number of bridge inputs: %i" % (bridge.getInputCount()))
    print("Data Rate Max: %d" % (bridge.getDataRateMax()))
    print("Data Rate Min: %d" % (bridge.getDataRateMin()))
    print("Input Value Max: %d" % (bridge.getBridgeMax(0)))
    print("Input Value Min: %d" % (bridge.getBridgeMin(0)))

#Event Handler Callback Functions
def BridgeAttached(e):
    attached = e.device
    print("Bridge %i Attached!" % (attached.getSerialNum()))

def BridgeDetached(e):
    detached = e.device
    print("Bridge %i Detached!" % (detached.getSerialNum()))

def BridgeError(e):
    try:
        source = e.device
        print("Bridge %i: Phidget Error %i: %s" % (source.getSerialNum(), e.eCode, e.description))
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))

def BridgeData(e):
    source = e.device
    savedData[e.index].append(e.value)
#print("Bridge %i: Input %i: %f" % (source.getSerialNum(), e.index, e.value))

#Convenience functions

def setEnabledAllChannels(device, state):
    for i in range(0,device.getInputCount()):
        device.setEnabled(i, state)

def setGainAllChanels(device,gain):
    for i in range(0,device.getInputCount()):
        device.setGain(i,gain)


#Main Program Code

parser = OptionParser()
parser.add_option("-t", "--time", dest="time",
                  help="duration of test in s", default=10)
parser.add_option("-r", "--rate", dest="dataRate",
                  help="duration of test in s", default=100)
parser.add_option("-m", "--manualtime",dest="manuallength",
                  help="manually end the data collection", default=False)
(options, args) = parser.parse_args()
options.dataRate = int(options.dataRate)
options.time = int(options.time)


savedData = [[],[],[],[]]


try:
    bridge.setOnAttachHandler(BridgeAttached)
    bridge.setOnDetachHandler(BridgeDetached)
    bridge.setOnErrorhandler(BridgeError)
    bridge.setOnBridgeDataHandler(BridgeData)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

print("Opening phidget object....")

try:
    bridge.openPhidget()
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

print("Waiting for attach....")

try:
    bridge.waitForAttach(20000)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    try:
        bridge.closePhidget()
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)
    print("Exiting....")
    exit(1)
else:
    displayDeviceInfo()

try:
    print("Set data rate to %i ms ..." % (int(options.dataRate)))
    bridge.setDataRate(int(options.dataRate))
    sleep(2)

    print("Set Gain to 1...")
    gain = BridgeGain.PHIDGET_BRIDGE_GAIN_8
    ##bridge.setGain(0, BridgeGain.PHIDGET_BRIDGE_GAIN_8)
    setGainAllChanels(bridge,gain)
    sleep(2)

    print("Enable the Bridge input for reading data...")
    setEnabledAllChannels(bridge,True)
##    bridge.setEnabled(0, True)
##    bridge.setEnabled(1, True)
##    bridge.setEnabled(2, True)
##    bridge.setEnabled(3, True)
    sleep(2)

except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    try:
        bridge.closePhidget()
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)
    print("Exiting....")
    exit(1)


if manuallength:
    print("Taking data... (enter to stop)")
    chr = sys.stdin.read(1)
else
    print("Taking Data for %i seconds...."% (options.time))
    sleep(options.time)

print("Closing...")

try:
    print("Disable the Bridge input for reading data...")
    setEnabledAllChannels(bridge,False)
##    bridge.setEnabled(0, False)
##    bridge.setEnabled(1, False)
##    bridge.setEnabled(2, False)
##    bridge.setEnabled(3, False)
    sleep(2)
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    try:
        bridge.closePhidget()
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)
    print("Exiting....")
    exit(1)

try:
    bridge.closePhidget()
except PhidgetException as e:
    print("Phidget Exception %i: %s" % (e.code, e.details))
    print("Exiting....")
    exit(1)

print("Done.")

#save to file

now = datetime.datetime.today().__str__()[:-7]
lNow = now.split()
lNow[1:1] = "_"
filename = 'data/Phidget_test_'+''.join(lNow)+'.csv'
    
print("Outputting data to file: %s"%(filename))
try:
    f = open(filename,'w')
    #f.write('Phidget Test Data\nTaken:,'+now+'\n')
    #f.write('Sensor1,Sensor2,Sensor3,Sensor4\n')
    
    #first line contains metadata
    f.write(''+str(options.dataRate)+','+str(gain))
    f.write(',%i,%i' % (len(savedData), len(savedData[0])))
    f.write('\n')
    for row in range(0,len(savedData[0])):
        for col in range(0,len(savedData)):
            f.write(str(savedData[col][row])+',')
        f.write('\n')
        if row%1000==0:
            f.flush()
except IOError as e:
    print("File error %i %s" % (e.code, e.details))
    print("Exiting.....")
    exit(1)
except IndexError as e:
    print("Index error %s" % (e))
    print("data length: %i, %i" % (len(savedData), len(savedData[0])))
    print("row: %i col: %i" % (row, col))
    f.flush()
f.close()

sleep(4)

##run the accompanying matlab script to plot the values
       
import os
command = "/Applications/MATLAB_R2012b.app/bin/matlab -nosplash -nodesktop -r \"filename=\'"+filename+"\';Phidget_data_reader\""
os.system(command)
sleep(1)        

exit(0)
