//
//  URL+Notes.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 22.01.2025.
//

import Foundation

extension URL {
    
    static func noteDirectory(for noteId: String) -> URL {
        URL.documentsDirectory.appending(path: "Notes/\(noteId)/")
    }
    
}
