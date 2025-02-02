//
//  NoteDetailToolbar.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 29.01.2025.
//

import UIKit

final class NoteDetailToolbar: UIView {
    
    enum ToolButtons {
        case checklist((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case addFile((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case drawing((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case addNewNote((() -> Void)?) //убрать опционал когда будут прописаны все действия
    }
    
    private let buttons: [ToolButtons]
    private lazy var buttonsStack: UIStackView = makeButtonsStack()
    
    init(buttons: [ToolButtons]) {
        self.buttons = buttons
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension NoteDetailToolbar {
    
    func setupView() {
        addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: topAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        buttons.forEach { button in// Почему это в setupView. Встегда оформялять stack в setupView. Или можно в функции makeButtonsStack?
            buttonsStack.addArrangedSubview(make(button: button))
        }
    }
    
    func makeButtonsStack() -> UIStackView {
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        hStack.translatesAutoresizingMaskIntoConstraints = false
        return hStack
    }
    
    func make(button: ToolButtons) -> UIButton {
        let toolButton = UIButton(type: .system)
        toolButton.tintColor = .systemOrange
        toolButton.translatesAutoresizingMaskIntoConstraints = false
        
        switch button {
        case .checklist(let action):
            toolButton.setImage(UIImage(systemName: "checklist"), for: .normal)
            toolButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .addFile(let action):
            toolButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
            toolButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .drawing(let action):
            toolButton.setImage(UIImage(systemName: "pencil.tip.crop.circle"), for: .normal)
            toolButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .addNewNote(let action):
            toolButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            toolButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        }
        
        return toolButton
    }
    
}
