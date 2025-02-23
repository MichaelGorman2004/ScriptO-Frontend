//
//  ContentView.swift
//  ScriptO-Frontend
//
//  Created by Michael Gorman on 2/21/25.
//

import SwiftUI
import CoreGraphics
import Foundation


struct ContentView: View {
    @State private var currentNote = Note(
        id: UUID(),
        title: "New Note",
        tags: [],
        subject: "",
        content: [],
        createdAt: Date(),
        modifiedAt: Date()
    )
    @State private var showingSaveError = false
    @State private var isAuthenticated = false
    @State private var isRegistering = false
    
    // Login fields
    @State private var username = ""
    @State private var password = ""
    
    // Registration fields
    @State private var email = ""
    @State private var fullName = ""
    @State private var registerPassword = ""
    @State private var showingAuthError = false
    @State private var authErrorMessage = ""
    
    // Add state for save status
    @State private var isSaving = false
    @State private var showingSaveSuccess = false
    
    var body: some View {
        if isAuthenticated {
            noteView
        } else {
            if isRegistering {
                registerView
            } else {
                loginView
            }
        }
    }
    
    var loginView: some View {
        VStack {
            Text("Login")
                .font(.title)
                .padding()
            
            TextField("Email", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Login") {
                Task {
                    do {
                        _ = try await AuthManager.shared.login(username: username, password: password)
                        isAuthenticated = true
                    } catch APIError.customError(let message) {
                        authErrorMessage = message
                        showingAuthError = true
                    } catch {
                        authErrorMessage = "Invalid credentials"
                        showingAuthError = true
                        print("Login error: \(error)")
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Need an account? Register") {
                isRegistering = true
            }
            .padding()
        }
        .padding()
        .alert("Login Error", isPresented: $showingAuthError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authErrorMessage)
        }
    }
    
    var registerView: some View {
        VStack {
            Text("Register")
                .font(.title)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
            
            TextField("Full Name", text: $fullName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $registerPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Register") {
                Task {
                    do {
                        _ = try await AuthManager.shared.register(
                            email: email,
                            fullName: fullName,
                            password: registerPassword
                        )
                        isAuthenticated = true
                    } catch let error as APIError {
                        switch error {
                        case .customError(let message):
                            authErrorMessage = message
                        default:
                            authErrorMessage = "Registration failed: \(error)"
                        }
                        showingAuthError = true
                        print("Registration error: \(error)")
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Already have an account? Login") {
                isRegistering = false
            }
            .padding()
        }
        .padding()
        .alert("Registration Error", isPresented: $showingAuthError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authErrorMessage)
        }
    }
    
    var noteView: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Title", text: $currentNote.title)
                    .font(.title)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: {
                    Task {
                        await saveNote()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Save")
                    }
                }
                .disabled(isSaving)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            
            DrawingCanvas(noteElements: $currentNote.content)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .alert("Error Saving", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authErrorMessage)
        }
        .alert("Note Saved", isPresented: $showingSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your note has been saved successfully!")
        }
    }
    
    func saveNote() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            print("📝 Saving note: \(currentNote.title)")
            let savedNote = try await APIClient.shared.saveNote(currentNote)
            currentNote = savedNote
            showingSaveSuccess = true
            print("✅ Note saved successfully")
        } catch APIError.unauthorized {
            print("❌ Unauthorized - redirecting to login")
            isAuthenticated = false
            showingSaveError = true
            authErrorMessage = "Please log in again"
        } catch APIError.customError(let message) {
            print("❌ Save error: \(message)")
            showingSaveError = true
            authErrorMessage = message
        } catch {
            print("❌ Save error: \(error.localizedDescription)")
            showingSaveError = true
            authErrorMessage = "Failed to save note: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
