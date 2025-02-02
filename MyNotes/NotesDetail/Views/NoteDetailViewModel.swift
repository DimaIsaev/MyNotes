//
//  NoteDetailViewModel.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 29.01.2025.
//

import UIKit

struct NoteDetailViewModel {
    let note: Note
    
    var displayedImages: [UIImage]? {
        note.fileNames?.compactMap({ fileName in
            let noteURL = URL.noteDirectory(for: note.id)
            let imageURL = noteURL.appending(path: fileName)
            
            if let fileData = FileManager.default.contents(atPath: imageURL.path), let fileContent = UIImage(data: fileData) {
                return fileContent
            }
            return nil
        })
    }
    
    var attributedText: NSAttributedString {
        makeAttributedText()
    }
    
    var isCollectionViewHidden: Bool {//Сергей данную строку поставил после note. Мне кажется ее место тут.Точно не убрать в контроллер?
        displayedImages?.isEmpty ?? true
    }
    
    private func makeAttributedText() -> NSMutableAttributedString {
        let textCombination = NSMutableAttributedString()
        let title = makeTitle(with: note.text)
        
        if let detailText = makeDetailText(with: note.text) {
            textCombination.append(title)
            textCombination.append(NSAttributedString(string: "\n"))
            textCombination.append(detailText)
        } else {
            textCombination.append(title)
        }
        
        return textCombination
    }
    
    private func makeTitle(with text: String) -> NSAttributedString {
        let start = text.startIndex
        let end = text.firstIndex(of: "\n") ?? text.endIndex
        let titleSubstring = text[start..<end]
        
        let attributeForTitle = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold),
                                  NSAttributedString.Key.foregroundColor: UIColor.white ]
        
        return NSAttributedString(string: String(titleSubstring), attributes: attributeForTitle)
    }
    
    private func makeDetailText(with text: String) -> NSAttributedString? {
        if let index = text.firstIndex(of: "\n") {
            let startIndex = text.index(after: index)
            let endIndex = text.endIndex
            let detailTextSubstring = text[startIndex..<endIndex]
            
            let attributeForDetailText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                                           NSAttributedString.Key.foregroundColor: UIColor.white ]
            
            return NSAttributedString(string: String(detailTextSubstring), attributes: attributeForDetailText)
        }
        
        return nil
    }
    
}
