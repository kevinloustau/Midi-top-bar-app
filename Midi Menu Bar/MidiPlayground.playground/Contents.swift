//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

enum Note {
    case C,CSharp,D,DSharp,E,F,FSharp,G,GSharp,A,ASharp,B
    switch self {
    case .C:
    return 60
    default :
    return 0
    }
    
}