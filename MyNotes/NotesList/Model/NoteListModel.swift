//
//  NoteListModel.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 21.08.2024.
//

import Foundation

final class NoteListModel {
    
    weak var controller: NotesListControllerProtocol?
    
    private var storedNotes: [Note] {
        didSet {
            controller?.didUpdate()
        }
    }
    
    init() {
        storedNotes = []
    }
    
}

//MARK: - Протокол модели

extension NoteListModel: NoteListModelProtocol {
    
    var notes: [Note]  {
        storedNotes
    }
    
    func createNote() -> Note {
        let note = Note(text: "", id: UUID().uuidString, date: Date())//??
        storedNotes.append(note)
        return note
    }
    
    func deleteNote(with id: String) {
        for (index, note) in storedNotes.enumerated() {
            if id == note.id {
                storedNotes.remove(at: index)
                return
            }
        }
    }
    
    func editTextNote(with id: String, newText: String) {
        for (index, note) in storedNotes.enumerated() {
            if id == note.id {
                var note = storedNotes[index]
                note.text = newText
                note.date = Date()
                storedNotes[index] = note
            }
        }
    }
    
    func addToNote(image name: String, note id: String) -> Note? { // может не нужно возвращать. подумать!
        for (index, note) in storedNotes.enumerated() {
            if id == note.id {
                var note = storedNotes[index]
                
                if note.fileNames == nil {//как упростить?
                    note.fileNames = []
                }
                
                note.fileNames?.append(name)
                note.date = Date()
                storedNotes[index] = note
                
                return note // может не нужно возвращать. подумать!
            }
        }
        return nil // может не нужно возвращать. подумать!
    }
    
}
