//
//  NoteDetailModel.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 26.08.2024.
//

import Foundation

protocol NoteDetailModelProtocol {
    
    var note: Note { get }
    
    func addFile(name: String)//почему Сергей записал его не в протокол?
    
}

final class NoteDetailModel {
    
    weak var controller: NoteDetailControllerProtocol?
    
    public var storedNote: Note { //следим?
        didSet {
            controller?.didUpdate()
        }
    }
    
    init(storedNote: Note) {
        self.storedNote = storedNote
    }
    
}

//MARK: - Протокол модели

extension NoteDetailModel: NoteDetailModelProtocol {
    
    var note: Note { storedNote }
    
    func addFile(name: String) { //почему Сергей записал его не в протокол?
        if storedNote.fileNames == nil {// точно норм?
            storedNote.fileNames = []
        }
        storedNote.fileNames?.append(name)
    }
    
}
