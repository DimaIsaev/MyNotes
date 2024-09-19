//
//  NoteListModel.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 21.08.2024.
//

import Foundation

struct Note {
    let title: String
    let detailText: String
}

protocol NoteListModelProtocol {
    var notes: [Note] {get}
    
    func saveNote(note: Note)
    func deleteNote(noteIndex: Int)
}

final class NoteListModel {
    
    private var storedNotes: [Note]
    
    init() {
        storedNotes = [
            Note(title: "test1", detailText: "1.01.2024"),
            Note(title: "test2", detailText: "2.01.2024"),
            Note(title: "test3", detailText: "3.01.2024"),
            Note(title: "test4", detailText: "4.01.2024"),
            Note(title: "test5", detailText: "5.01.2024")
        ]
    }
}

extension NoteListModel: NoteListModelProtocol {
    
    var notes: [Note] {
        storedNotes
    }
    
    func saveNote(note: Note) {
        storedNotes.insert(note, at: 0)
    }
    
    func deleteNote(noteIndex: Int) {
        storedNotes.remove(at: noteIndex)
    }
}
