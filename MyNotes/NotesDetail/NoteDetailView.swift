//
//  NoteDetailView.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 18.08.2024.
//

import UIKit

protocol NoteDetailViewProtocol: UIView {
    func getTitle() -> String 
    func getDetailText() -> String
    func setText(title: String, detailText: String)
}

final class NoteDetailView: UIView, NoteDetailViewProtocol {

    private lazy var textView: UITextView = makeTextView()
    private lazy var title = makeTitle()
    private lazy var detailText = makeDetailText()
    
    var controller: NoteDetailControllerProtocol
    
    init(controller: NoteDetailControllerProtocol) {
        self.controller = controller
        super.init(frame: .zero)
        setupLoyaut()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTitle() -> String {
        return title
    }
    
    func getDetailText() -> String {
        return detailText
    }
    
    func setText(title: String, detailText: String) {
        textView.text = title + "\n" + detailText
    }
}

private extension NoteDetailView {
    
    func setupLoyaut() {
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 45),
            textView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -56),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textColor = .white
        textView.backgroundColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }
    
    func makeTitle() -> String {
        var title: String
        let start = textView.text.startIndex
        let end = textView.text.firstIndex(of: "\n") ?? textView.text.endIndex
        let range = start..<end
        let mySubstring = textView.text[range]
        
        title = String(mySubstring)
        return title
    }
    
    func makeDetailText() -> String {
        let detailText: String
        let start = textView.text.index(after: textView.text.firstIndex(of: "\n") ?? textView.text.startIndex)
        let end = textView.text.endIndex
        let range = start..<end
        let mySubstring = textView.text[range]
        
        detailText = String(mySubstring)
        return detailText
    }
            
    
}
