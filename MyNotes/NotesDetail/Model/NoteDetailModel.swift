//
//  NoteDetailModel.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 26.08.2024.
//

import Foundation

protocol NoteDetailModelProtocol {
    
    var note: Note { get }
    
        func update(note: Note) //сносил но пришлось вернуть из-за отображаемых картинок
    
}

final class NoteDetailModel {
    
    weak var controller: NoteDetailControllerProtocol?
    
    public var storedNote: Note
    
    init(storedNote: Note) {
        self.storedNote = storedNote
    }
    
}

//MARK: - Протокол модели

extension NoteDetailModel: NoteDetailModelProtocol {
    
    var note: Note { storedNote }
    
        func update(note: Note) { //сносил но пришлось вернуть из-за отображаемых картинок
            storedNote = note
        }
    
}
