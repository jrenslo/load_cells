#! /usr/bin/python

"""Copyright 2011 Phidgets Inc.
This work is licensed under the Creative Commons Attribution 2.5 Canada License.
To view a copy of this license, visit http://creativecommons.org/licenses/by/2.5/ca/
"""

__author__="Adam Stelmack"
__version__="2.1.8"
__date__ ="14-Jan-2011 2:29:14 PM"

"""
    edited by Jon Renslo for the BDML at Stanford
    Calibrates and records calibration constant for selected Phidget bridges
    August, 2013
"""

#Basic imports
import sys, os
from time import time as getCurrentTime
from time import sleep
from datetime import *
#Phidget specific imports
from Phidgets.PhidgetException import PhidgetException
from Phidgets.Devices.Bridge import Bridge, BridgeGain

#Event Handler Callback Functions
def BridgeAttached(e):
    attached = e.device
    print("Bridge %i Attached!" % (attached.getSerialNum()))

def BridgeDetached(e):
    detached = e.device
    print("Bridge %i Detached!" % (detached.getSerialNum()))

def BridgeError(e):
    # TODO add out of range error detection
    try:
        source = e.device
        print("Bridge %i: Phidget Error %i: %s" % (source.getSerialNum(), e.eCode, e.description))
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))

def BridgeData(e):
    # TODO add out of range error detection
    try:
        source = e.device
        savedData.append(e.value)
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))


#Convenience functions

def displayDeviceInfo(bridge):
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

def setEnabledAllChannels(device, state):
    for i in range(0,device.getInputCount()):
        device.setEnabled(i, state)

def setGainAllChanels(device,gain):
    for i in range(0,device.getInputCount()):
        device.setGain(i,gain)

def openBridge(serialNum):
    #Create a bridge object
    try:
        bridge = Bridge()
    except RuntimeError as e:
        print("Runtime Exception: %s" % e.details)
        print("Exiting....")
        exit(1)

    try:
        bridge.setOnAttachHandler(BridgeAttached)
        bridge.setOnDetachHandler(BridgeDetached)
        bridge.setOnErrorhandler(BridgeError)
        bridge.setOnBridgeDataHandler(BridgeData)
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)

    print("Calibration Script.\nOpening phidget object....")

    try:
        bridge.openPhidget(serialNum)
    except PhidgetException as e:
        print("Phidget Exception %i: %s" % (e.code, e.details))
        print("Exiting....")
        exit(1)

    print("Waiting for attach....")

    try:
        bridge.waitForAttach(20000)
        
        print("Set data rate to %i ms ..." % (rate))
        bridge.setDataRate(rate)
        sleep(1)

        print("Set Gain to %s..." % str(gainTable[gain]))
        setGainAllChanels(bridge,gain)
        sleep(1)

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
        displayDeviceInfo(bridge)
    return bridge

def collectMeanVal(bridge,index):
    #print("Enabling %i-%i"%(bridge.getSerialNum(),index))
    bridge.setEnabled(index,True)
    chr = raw_input("Press enter when ready\n")
    global savedData
    savedData = []
    time = 4
    print("Taking Data for %i seconds"%time)
    sleep(time)
    dataPart = savedData[:]
    #print("Disabling %i-%i"%(bridge.getSerialNum(),index))
    bridge.setEnabled(index,False)
    return sum(dataPart)/float(len(dataPart))

def approveVal(val):
    print("Is this constant okay? %f (y/n)"%val)
    a = raw_input()
    return str(a[0])=='y' if a else 0


#Main Program Code
startTime = getCurrentTime()
savedData = []
toTest = [293783, 293743, 293780, 293749, 293138, 293824] # bridges to test, identified by serial number.
gainTable = ['invalid',1,8,16,32,64,128,'unknown']
gain = BridgeGain.PHIDGET_BRIDGE_GAIN_8
rate = 8

#open output file

now = datetime.today().__str__()[:-7]
lNow = now.split()
lNow[1:1] = "_"
dirname = 'data'
if dirname not in os.listdir('.'):
    os.makedirs(dirname)
os.chdir(dirname)

filename = 'Phidget_calibration_'+''.join(lNow)+'.csv'

print("Board indicies for reference:")
print("|0       3|\n|         |\n|1  usb  2|")

weightInKG = raw_input("Enter the weight of the calibration load in KG\n")

try:
    f = open(filename,'w')
except IOError as e:
    print("error opening file. exiting...")
    exit(1)

#metadata in first row: [dataRate, gain]
f.write(''+str(rate)+',' \
          +str(gainTable[gain])+'\n')

for bridgeNum in toTest:
    try:
        bridge = openBridge(bridgeNum)
        for cellIndex in range(4):
            print("Calibrating bridge %i, index %i..."%(bridgeNum,cellIndex))
            while 1:
                print("Collecting zero value. Do not add weight")
                zero = collectMeanVal(bridge,cellIndex)
                print("Collecting calibrated value. Add weight now")
                weighted = collectMeanVal(bridge,cellIndex)
                const = float(weightInKG)/(weighted-zero)
                if approveVal(const):
                    break
                print("Repeating measurement...")
            f.write(''+str(bridgeNum)+','+str(cellIndex)+','+str(const)+'\n')
        print("Closing...")
        bridge.closePhidget()
        f.flush()        
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
    except IOError as e:
        print("error writing file. Exiting...")
        f.close()
        try:
            bridge.closePhidget()
        except PhidgetException as e:
            print("Phidget Exception %i: %s" % (e.code, e.details))
            print("Exiting....")
            exit(1)
        exit(1)
f.close()

print("Output to data/%s"%filename)

exit(0)
