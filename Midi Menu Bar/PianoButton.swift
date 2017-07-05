//
//  PianoButton.swift
//  Midi Menu Bar
//
//  Created by kl on 21/08/16.
//  Copyright © 2016 kl. All rights reserved.
//

import Cocoa

@IBDesignable open class PianoButton: NSButton {
    
    let midiManager = MIDIManager()

    @IBInspectable var noteString: String = ""
    @IBInspectable var isBlackKey: Bool = false
    
    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        midiManager.getMIDIDevices()
    }
    
    
    //MARK: Handle the click state to start and stop correctly the midi note.
    override open func mouseDown(with theEvent: NSEvent) {
        //Swift.print("MouseDown !")
        tintImage(isBlackKey, mouseState: true)
        midiManager.send(UInt8(1), UInt8(noteToInt(noteString,octave: MidiKeyboardViewController.currentOctave)), UInt8(127))
    }
    
    override open func mouseUp(with theEvent: NSEvent) {
        //Swift.print("Mouse Up !")
        tintImage(isBlackKey, mouseState: false)
        midiManager.send(UInt8(1), UInt8(noteToInt(noteString,octave: MidiKeyboardViewController.currentOctave)), UInt8(0))
    }
    
    
    //MARK: Note to Int, convert the string note name to the corresponding midi number.
    func noteToInt(_ note: String, octave: Int) -> Int  {
        
        let addOctave = octave * 12
        
        switch note {
            
        case "C":
            return 60 + addOctave
        case "C#":
            return 61 + addOctave
        case "D":
            return 62 + addOctave
        case "D#":
            return 63 + addOctave
        case "E":
            return 64 + addOctave
        case "F":
            return 65 + addOctave
        case "F#":
            return 66 + addOctave
        case "G":
            return 67 + addOctave
        case "G#":
            return 68 + addOctave
        case "A":
            return 69 + addOctave
        case "A#":
            return 70 + addOctave
        case "B":
            return 71 + addOctave
        default :
            return 0
        }
    }
    
    
    func tintImage(_ keyBool: Bool, mouseState: Bool){
        
        if(mouseState) {
            if (!keyBool) {
                self.image = NSImage(named: "whiteKeyTint")
            } else {
                self.image = NSImage(named: "blackKeyTint")
            }
        } else {
            if (!keyBool) {
                self.image = NSImage(named: "whiteKey")
            } else {
                self.image = NSImage(named: "blackKey")
            }
        }
    }

    
}

