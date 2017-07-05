//
//  AppDelegate.swift
//  Midi Menu Bar
//
//  Created by kl on 8/4/16.
//  Copyright © 2016 kl. All rights reserved.
//

import Cocoa
import CoreMIDI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named: "keyboardIcon")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = MidiKeyboardViewController(nibName: "MidiKeyboardViewController", bundle: nil)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    
    //MARK: PopUp
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    

    func quit(_ sender : NSMenuItem) {
        NSApp.terminate(self)
    }
    
   
}

