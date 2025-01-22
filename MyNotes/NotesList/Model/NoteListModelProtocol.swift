//
//  NoteListModelProtocol.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 25.12.2024.
//

import Foundation

protocol NoteListModelProtocol {
    
    var notes: [Note] { get }
    
    func createNote() -> Note
    func deleteNote(with id: String)
    func editTextNote(with id: String, newText: String)
    func addToNote(imageName: String, note id: String) -> Note? // может не нужно возвращать. подумать!
    
}
