//
//  MIDIManager.swift
//  BlueMO
//
//  Created by JP Carrascal on 09/03/16.
//  Copyright © 2016 Spacebarman. All rights reserved.
//
// NOTE1:
// Properties shoud be obtained with MIDIObjectGetIntegerProperty() and MIDIObjectGetStringProperty(),
// but MIDIObjectGetStringProperty() is a mess for OSX (maybe not so much for iOS).
// Check:
// http://stackoverflow.com/questions/27169807/swift-unsafemutablepointerunmanagedcfstring-allocation-and-print
// And the best solution I could find is this one:
// http://qiku.es/pregunta/78314/necesitas-ayuda-conversi%C3%B3n-cfpropertylistref-nsdictionary-a-swift-need-help-converting-cfpropertylistref-nsdictionary-to-swift


import Foundation
import CoreMIDI

open class MIDIManager:NSObject {
    
    fileprivate var midiClient = MIDIClientRef()
    fileprivate var outputPort = MIDIPortRef()
    fileprivate var virtualMidiClient = MIDIClientRef()
    fileprivate var virtualOutputPort = MIDIPortRef()
    fileprivate var activeMIDIDevices = [Int]()
    //private let np:MIDINotifyProc = { (notification:UnsafePointer<MIDINotification>, refcon:UnsafeMutableRawPointer) in } as! MIDINotifyProc
    private let np: MIDINotifyProc? = nil
    fileprivate var destination:MIDIEndpointRef = MIDIEndpointRef()
    fileprivate(set) open var selectedMIDIDevice = Int()
    open var activeMIDIDeviceNames = [String]()
    
    public init(dev:Int = -1) {
        super.init()
        getMIDIDevices()
        // -1 is the virtual MIDI port
        setActiveMIDIDevice(dev)
    }
    
    /*
     setActiveMIDIDevice()
     Sets the active MIDI device from the list of the devices available in the system.
     Input argument: the device index.
     If the index is -1, it creates a virtual MIDI device called "BlueMO".
     */
    open func setActiveMIDIDevice(_ index:Int)
    {
        var status = OSStatus(noErr)
        if index >= 0 {
            // MIDIClientDispose(virtualMidiClient)
            status = MIDIClientCreate("MIDIClient" as CFString, np, nil, &midiClient)
            status = MIDIOutputPortCreate(midiClient, "Output" as CFString, &outputPort);
            destination = MIDIGetDestination(index)
        } else {
            // MIDIClientDispose(midiClient)
            status = MIDIClientCreate("VirtualMIDIClient" as CFString, np, nil, &virtualMidiClient)
            status = MIDIOutputPortCreate(virtualMidiClient, "Output2" as CFString, &virtualOutputPort);
            MIDISourceCreate(virtualMidiClient, "BlueMO port" as CFString, &virtualOutputPort);
        }
        selectedMIDIDevice = index
        if status != 0 {
            print("Error while selecting MIDI device!")
        }
    }
    
    /*
     getMIDIDevices()
     Finds all the MIDI devices avalible and online in ths system.
     This function is a little hacky, but so far it gets the work done.
     */
    open func getMIDIDevices() {
        activeMIDIDeviceNames.removeAll()
        activeMIDIDevices.removeAll()
        for i in 0...MIDIGetNumberOfDevices()-1 {
            let device:MIDIDeviceRef = MIDIGetDevice(i)
            var offline:Int32 = 0
            MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &offline)
            if offline != 1 {
                let entityCount:Int = MIDIDeviceGetNumberOfEntities(device);
                for j in 0...entityCount {
                    let entity:MIDIEntityRef = MIDIDeviceGetEntity(device, j);
                    let destCount:Int = MIDIEntityGetNumberOfDestinations(entity);
                    if destCount > 0 {
                        var eOffline:Int32 = 0
                        MIDIObjectGetIntegerProperty(entity, kMIDIPropertyOffline, &eOffline)
                        if eOffline != 1 {
                            var unmanagedProperties: Unmanaged<CFPropertyList>?
                            /* JP: See NOTE1 at the beginning of file */
                            MIDIObjectGetProperties(entity, &unmanagedProperties, true)
                            if let midiProperties: CFPropertyList = unmanagedProperties?.takeUnretainedValue() {
                                let entityName = midiProperties["name"] as! String
                                let entityID = midiProperties["uniqueID"] as! Int
                                if !activeMIDIDevices.contains(entityID) {
                                    activeMIDIDeviceNames.append(entityName)
                                    activeMIDIDevices.append(entityID)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //If almost one midi device use this :
        //for i in 0...MIDIGetNumberOfDestinations() -1
        for i in 0...MIDIGetNumberOfDestinations() {
            let device:MIDIDeviceRef = MIDIGetDestination(i)
            var offline:Int32 = 0
            MIDIObjectGetIntegerProperty(device, kMIDIPropertyOffline, &offline)
            if offline != 1 {
                var unmanagedProperties: Unmanaged<CFPropertyList>?
                /* JP: See NOTE1 at the beginning of file */
                MIDIObjectGetProperties(device, &unmanagedProperties, true)
                if let midiProperties: CFPropertyList = unmanagedProperties?.takeUnretainedValue() {
                    if midiProperties["name"]! != nil {
                        let entityName = midiProperties["name"] as! String
                        let entityID = midiProperties["uniqueID"] as! Int
                        if !activeMIDIDevices.contains(entityID) {
                            activeMIDIDeviceNames.append(entityName)
                            activeMIDIDevices.append(Int(entityID))
                        }
                    }
                }
            }
        }
    }
    
    /*
     send()
     Actually sends midi DATA, to either the virtual MIDI port (see setActiveMIDIDevice() above)
     or to a system MIDI port.
     Right now it only sends CC data, but with some simple tweaking it could send any message.
     As arguments, it expects 1) the MIDI channel number, 2) CC number and 3) value to send.
     */
    open func send(_ MIDIChannel: UInt8, _ NoteNumber: UInt8, _ Velocity: UInt8) ->OSStatus {
        var packet:MIDIPacket = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        
        
        packet.data.0 = UInt8(144) + MIDIChannel-1 // Controller + channel number
        packet.data.1 = NoteNumber // Control number
        packet.data.2 = Velocity // Control value
        var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: packet);
        if selectedMIDIDevice < 0 {
            return MIDIReceived(virtualOutputPort, &packetList)
        }
        else {
            //return MIDISend(outputPort, destination, &packetList)
            return MIDIReceived(virtualOutputPort, &packetList)
        }
    }

}






