//
//  QuotesViewController.swift
//  Midi Menu Bar
//
//  Created by kl on 8/4/16.
//  Copyright © 2016 kl. All rights reserved.
//

import Cocoa

class MidiKeyboardViewController: NSViewController {
    
    
    @IBOutlet weak var octaveLabel: NSTextField!
    
    
    static var currentOctave: Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        octaveLabel.stringValue = "0"
        //Init value : 
        octaveLabelUpdate(currentOctave: 0)
        
    }
    



    // MARK: Octave function
    @IBAction func octavePlus(_ sender: AnyObject) {
        MidiKeyboardViewController.currentOctave += 1
        octaveLabelUpdate(currentOctave: MidiKeyboardViewController.currentOctave)
    }
    @IBAction func octaceMoins(_ sender: AnyObject) {
        MidiKeyboardViewController.currentOctave -= 1
        octaveLabelUpdate(currentOctave: MidiKeyboardViewController.currentOctave)
    }
    
    func octaveLabelUpdate(currentOctave: Int) {
        octaveLabel.stringValue = String(currentOctave)
    }
    
    
    @IBAction func closeApp(_ sender: Any) {
        NSApplication.shared.terminate(sender)
    }
    
    
}
