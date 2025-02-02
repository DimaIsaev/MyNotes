//
//  NoteDetailAddFileMenu.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 29.01.2025.
//

import UIKit

final class NoteDetailAddFileMenu: UIView {
    
    enum AddButtons {
        case attachFile((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case recordAudio((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case selectPhotoOrVideo((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case takePhotoOrVideo((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case scanDocument((() -> Void)?) //убрать опционал когда будут прописаны все действия
        case scanText((() -> Void)?) //убрать опционал когда будут прописаны все действия
        
        var label: String {
            switch self {
            case .attachFile:
                return "Вложить файл"
            case .recordAudio:
                return "Записать аудио"
            case .selectPhotoOrVideo:
                return "Выбрать фото или видео"
            case .takePhotoOrVideo:
                return "Снять фото или видео"
            case .scanDocument:
                return "Отсканировать документы"
            case .scanText:
                return "Сканировать текст"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .attachFile:
                return UIImage(systemName: "doc")
            case .recordAudio:
                return UIImage(systemName: "waveform")
            case .selectPhotoOrVideo:
                return UIImage(systemName: "photo.on.rectangle")
            case .takePhotoOrVideo:
                return UIImage(systemName: "camera")
            case .scanDocument:
                return UIImage(systemName: "doc.viewfinder")
            case .scanText:
                return UIImage(systemName: "text.viewfinder")
            }
        }
    }
    
    private let buttons: [AddButtons]
    private lazy var buttonsStack = makeButtonsStack()
    private lazy var lineView = makeLineView()// Елси оформлять stack нужно в setup.  То пришлось отдельно view создать. Или не нужно?
    
    init(buttons: [AddButtons]) {
        self.buttons = buttons
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension NoteDetailAddFileMenu {
    
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
        
        buttonsStack.insertArrangedSubview(lineView, at: 2)//это тут норм выглядит? или убрать в  stack?
        buttonsStack.setCustomSpacing(0, after: buttonsStack.arrangedSubviews[1])
        buttonsStack.setCustomSpacing(0, after: buttonsStack.arrangedSubviews[2])
    }
    
    func makeButtonsStack() -> UIStackView {
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 0.4
        vStack.backgroundColor = .gray
        vStack.layer.cornerRadius = 15
        vStack.clipsToBounds = true
        vStack.translatesAutoresizingMaskIntoConstraints = false
        // вариант замены
        //        buttons.forEach { button in//куда вставить этот кусок кода? тут или в setupView
        //            vStack.addArrangedSubview(make(button: button))
        //        }
        
        //        let lineView = UIView()
        //        lineView.translatesAutoresizingMaskIntoConstraints = false //может убрать в отдельный UiView
        //        lineView.backgroundColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        //        lineView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        //        vStack.insertArrangedSubview(lineView, at: 2)//это убрать в setup
        //        vStack.setCustomSpacing(0, after: vStack.arrangedSubviews[1])
        //        vStack.setCustomSpacing(0, after: vStack.arrangedSubviews[2])
        return vStack
    }
    
    func make(button: AddButtons) -> UIButton {//порядок кода наладить. Может добавить UI ImageView и AddSubview на button
        let addButton = UIButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.contentHorizontalAlignment = .fill
        
        var configurtion = UIButton.Configuration.filled()
        configurtion.background.cornerRadius = 0
        configurtion.baseBackgroundColor = UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        configurtion.baseForegroundColor = .white
        configurtion.imagePlacement = .trailing
        configurtion.imagePadding = 15
        configurtion.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        configurtion.imageReservation = 27
        configurtion.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)
        
        switch button { //как сократить повторяющийся код
        case .attachFile(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .recordAudio(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .selectPhotoOrVideo(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .takePhotoOrVideo(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .scanDocument(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        case .scanText(let action):
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addAction(UIAction(handler: { _ in
                action?()
            }), for: .touchUpInside)
        }
        
        addButton.configuration = configurtion
        return addButton
    }
    
    func makeLineView() -> UIView { // Елси оформлять stack нужно в setup.  То пришлось отдельно view создать. Или не нужно?
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false //может убрать в отдельный UiView
        lineView.backgroundColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        lineView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return lineView
    }
    
}
