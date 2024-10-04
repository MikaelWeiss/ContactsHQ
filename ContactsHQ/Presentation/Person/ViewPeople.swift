//
//  ViewPeople.swift
//  Strive
//
//  Created by Mikael Weiss on 6/7/24.
//  Copyright © 2024 Mikael Weiss. All rights reserved.
//

import SwiftUI
import SwiftData

@MainActor
struct ViewPeople: View {
    @Query(sort: \Person.givenName) private var people: [Person]
    @Query private var allPeople: [Person]
    @State private var addPersonSheetShowing = false
    @State private var personToEdit: Person?
    @State private var showConfirmDeletePerson = false
    @State private var personToDelete: Person?
    
    init(search: String) {
        _people = Query(filter: #Predicate {
            if search.isEmpty {
                return true
            } else {
                return $0.givenName.localizedStandardContains(search)
            }
        }, sort: \Person.givenName)
    }
    
    var body: some View {
        NavigationView {
            if allPeople.isEmpty {
                VStack {
                    Text("Looks like you don't have any people saved yet. Let's get started!")
                    StandardButton(title: "Import from Contacts", action: checkImportContacts)
                    StandardButton(title: "Add New Contact", action: addPerson)
                }
                .padding()
                .navigationTitle("People")
            } else {
                List(people) { person in
                    NavigationLink {
                        ViewPersonTimeline(person: person)
                    } label: {
                        Text(person.givenName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .swipeActions(allowsFullSwipe: true) {
                                Button(action: {
                                    showConfirmDeletePerson = true
                                    personToDelete = person
                                }, label: {
                                    Label("Delete", systemImage: "trash.fill")
                                })
                                .tint(Color.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    personToEdit = person
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                    }
                }
                .navigationTitle("People")
            }
        }
        .sheet(item: $personToEdit) { AddEditPerson(personToEdit: $0) }
        .sheet(isPresented: $addPersonSheetShowing) {
            AddEditPerson(personToEdit: nil)
        }
        .alert("Delete Person?",
               isPresented: $showConfirmDeletePerson,
               presenting: personToDelete) { person in
            Button(role: .cancel, action: { }, label: { Text("cancel") })
            Button(role: .destructive, action: {
                StorageManager.shared.delete(person)
            }) {
                Text("Delete")
            }
        } message: { _ in
            Text("Are you sure you want to delete this person? This action cannot be undone.")
        }
        .overlay(addButton)
    }
    
    private var addButton: some View {
        Button(action: addPerson) {
            Image(systemName: "plus")
                .foregroundStyle(.background)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding()
                .background {
                    Circle()
                        .foregroundStyle(Color.accentColor)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom)
        .padding(.trailing, 38)
    }
}

// MARK: - Interacting

extension ViewPeople {
    func checkImportContacts() {
        if people.isEmpty {
            if ContactsManager.shared.fetchAuthorizationNotDetermined() == true {
                ContactsManager.shared.requestAuthorization { authorized, error in
                    if authorized {
                        importContacts()
                    } else {
                        print("ERROR: \(error?.localizedDescription ?? "")")
                    }
                }
            } else {
                importContacts()
            }
        }
    }
    
    func importContacts() {
        withAnimation {
            do {
                let fetchedContacts = try ContactsManager.shared.retreaveContactsList()
                for contact in fetchedContacts {
                    let person = contact
                    StorageManager.shared.insert(person)
                    print("it worked for \(person.givenName)")
                }
            } catch {
                print("Oof")
            }
        }
    }
    
    func addPerson() {
        addPersonSheetShowing = true
    }
}

#Preview {
    ViewPeople(search: "")
}
