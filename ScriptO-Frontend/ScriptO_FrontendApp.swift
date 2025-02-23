//
//  ScriptO_FrontendApp.swift
//  ScriptO-Frontend
//
//  Created by Michael Gorman on 2/21/25.
//

/*
 ScriptO_FrontendApp.swift
 
 The main entry point for the ScriptO iOS application. This file contains the app's root structure
 and initializes the primary ContentView. ScriptO is a note-taking application that allows users
 to create, edit, and manage handwritten digital notes with drawing capabilities.
 
 Key Features:
 - SwiftUI-based application structure
 - Initializes main ContentView
 - Handles app lifecycle
*/

import SwiftUI

@main
struct ScriptO_FrontendApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
