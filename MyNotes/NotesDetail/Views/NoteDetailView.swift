//
//  NoteDetailView.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 18.08.2024.
//

import UIKit

protocol NoteDetailViewProtocol: UIView {
    
    func setText(text: String?)
    func hideAddFileMenu(value: Bool) //имя? Аргумент может на status поменять?
    
    func startTextViewListening()
    func stopTextViewListening()
    
}

final class NoteDetailView: UIView {
    
    enum ToolButtons: CaseIterable { //Добавлено перечисление кнопок ToolButton (посмотреть нейминги), перенести в отдельный файл?
        case checklist
        case addFile
        case drawing
        case addNewNote
    }
    
    enum AddButtons: CaseIterable { //Добавлено перечисление кнопок AddButton (посмотреть нейминги), перенести в отдельный файл?
        case attachFile
        case recordAudio
        case selectPhotoOrVideo
        case takePhotoOrVideo
        case scanDocument
        case scanText
        
        var label: String { //тут глянуть норм?
            switch self {
            case .attachFile:
                return "Вложить файл"
            case .recordAudio:
                return "Записать аудио"
            case .selectPhotoOrVideo:
                return "Выбрать фото или видео" //криво переносит эту фразу
            case .takePhotoOrVideo:
                return "Снять фото или видео"
            case .scanDocument:
                return "Отсканировать документы"
            case .scanText:
                return "Сканировать текст"
            }
        }
        
        var image: UIImage? { //тут глянуть норм?
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
    
    struct ViewModel { //норм выход? Я так понимаю для коллекции только через viewModel?
        let note: Note
    }
    
    private lazy var textView: UITextView = makeTextView()
    private lazy var toolButtonsStack: UIStackView = makeToolButtonsStack() //Добавлен стек Tool кнопок (посмотреть нейминги)
    private lazy var addButtonsStack: UIStackView = makeAddButtonsStack() //Добавлен стек Add кнопок (посмотреть нейминги)
    private lazy var imageCollectionView: UICollectionView = makeImageCollectionView()
    
    private var viewModel: ViewModel//опционал убрал
    //пробел убрать?
    private var controller: NoteDetailControllerProtocol // private?
    
    init(viewModel: ViewModel, controller: NoteDetailControllerProtocol) {//viewModel не опционал и его пришлось добавить в аргумент
        self.viewModel = viewModel //viewModel не опционал и его пришлось добавить в аргумент
        self.controller = controller
        super.init(frame: .zero)
        setupLoyaut()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
}

// MARK: - TextView Methods

extension NoteDetailView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let index = textView.text.firstIndex(of: "\n")
        let attributeForTitle = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold),
                                  NSAttributedString.Key.foregroundColor: UIColor.white ]
        
        let titleRange = NSRange(
            location: textView.text.distance(from: textView.text.startIndex, to: textView.text.startIndex),
            length: textView.text.distance(from: textView.text.startIndex, to: index ?? textView.text.endIndex)
        )
        
        textView.textStorage.addAttributes(attributeForTitle, range: titleRange)
        
        if let index {
            let startIndex = textView.text.index(after: index)
            let attributeForDetailText = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                                           NSAttributedString.Key.foregroundColor: UIColor.white ]
            let detailTextRange = NSRange(
                location: textView.text.distance(from: textView.text.startIndex, to: startIndex),
                length: textView.text.distance(from: startIndex, to: textView.text.endIndex)
            )
            textView.textStorage.addAttributes(attributeForDetailText, range: detailTextRange)
        }
        
        controller.didChange(text: textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        controller.didBeginEditing()
    }
    
}

extension NoteDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.note.fileNames?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ImageCell {
            cell.setCell(image: <#T##UIImage#>)
        }
        return cell
    }
    
}

// MARK: - Протокол View

extension NoteDetailView: NoteDetailViewProtocol {
    
    func setText(text: String?) {
        let textCombination = NSMutableAttributedString()
        
        if let text = text {
            let title = makeTitle(with: text)
            
            if let detailText = makeDetailText(with: text) {
                textCombination.append(title)
                textCombination.append(NSAttributedString(string: "\n"))
                textCombination.append(detailText)
            } else {
                textCombination.append(title)
            }
        }
        textView.attributedText = textCombination
    }
    
    func hideAddFileMenu(value: Bool) { //тоже глянь в целом
        addButtonsStack.isHidden = value
    }
    
    func startTextViewListening() {
        textView.delegate = self
    }
    
    func stopTextViewListening() {
        textView.delegate = nil
    }
    
}

// MARK: - UI Elements

private extension NoteDetailView {
    
    func setupLoyaut() { // добавление toolButtonsStack и addButtonsStack на view. И их NSLayoutConstraint
        addSubview(textView)
        addSubview(toolButtonsStack)
        addSubview(imageCollectionView)
        addSubview(addButtonsStack)// тут сделал меню над collectionView по другому можно очередность сделать?
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            textView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -35),
            textView.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -10),
            
            toolButtonsStack.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20), //тут наверно нужно растянуть на весь экран, и настроить внутр. отступы у стека через (layoutMargins, isLayoutMarginsRelativeArrangement)
            toolButtonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            toolButtonsStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            addButtonsStack.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -15),
            addButtonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            addButtonsStack.widthAnchor.constraint(equalToConstant: 255),// ширину на глаз фиксировал
            
            imageCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -15),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 115),//изменить по контенту?
        ])
    }
    
    //MARK: Text Elements
    func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        
        return textView
    }
    
    func makeTitle(with text: String) -> NSAttributedString {
        
        let start = text.startIndex
        let end = text.firstIndex(of: "\n") ?? text.endIndex
        let titleSubstring = text[start..<end]
        
        let attributeForTitle = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold),
                                  NSAttributedString.Key.foregroundColor: UIColor.white ]
        
        return NSAttributedString(string: String(titleSubstring), attributes: attributeForTitle)
    }
    
    func makeDetailText(with text: String) -> NSAttributedString? {
        
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
    
    //MARK: Tool Buttons
    func makeTool(button: ToolButtons) -> UIButton { // добавлена функция создания кнопки
        let toolButton = UIButton(type: .system)
        toolButton.tintColor = .systemOrange
        toolButton.translatesAutoresizingMaskIntoConstraints = false
        
        switch button {// посмотреть может есть варианты лучше?
        case .checklist:
            toolButton.setImage(UIImage(systemName: "checklist"), for: .normal)
        case .addFile:
            toolButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
            toolButton.addTarget(self, action: #selector(addFileMenuBottonAction), for: .touchUpInside) //действия добавлять тут норм?
        case .drawing:
            toolButton.setImage(UIImage(systemName: "pencil.tip.crop.circle"), for: .normal)
        case .addNewNote:
            toolButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        }
        
        return toolButton
    }
    
    @objc func addFileMenuBottonAction() { //нейминг?
        let value = addButtonsStack.isHidden //нейм?
        controller.didTapAddFileMenuButton(hidden: value) //Вроде норм звучит?
    }
    
    func makeToolButtonsStack() -> UIStackView { //Создание стека кнопок код норм?  (нейминг норм?)
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        ToolButtons.allCases.forEach { button in // норм добавление кнопок?
            hStack.addArrangedSubview(makeTool(button: button))
        }
        
        return hStack
    }
    
    //MARK: Add Buttons
    func makeAdd(button: AddButtons) -> UIButton { //нейминг? Порядок написания кода: Вроде настраиваю кнопку, а речь про Button только в середине функции.
        var configurtion = UIButton.Configuration.filled()
        configurtion.background.cornerRadius = 0
        configurtion.baseBackgroundColor = UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1.0)//так цвет норм задавать? Может добавит в Assets через колориметр Xcode(а)
        configurtion.baseForegroundColor = .white
        configurtion.imagePlacement = .trailing
        configurtion.imagePadding = 15
        configurtion.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
        configurtion.imageReservation = 27
        configurtion.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)
        
        let addButton = UIButton() //translatesAutoresizingMaskIntoConstraints нужно? Вроде не влияет на результат
        addButton.contentHorizontalAlignment = .fill
        
        switch button {
        case .attachFile:
            configurtion.title = button.label
            configurtion.image = button.image
        case .recordAudio:
            configurtion.title = button.label
            configurtion.image = button.image
        case .selectPhotoOrVideo:
            configurtion.title = button.label
            configurtion.image = button.image
            addButton.addTarget(self, action: #selector(addPhotoOrVideoButtonAction), for: .touchUpInside)
        case .takePhotoOrVideo:
            configurtion.title = button.label
            configurtion.image = button.image
        case .scanDocument:
            configurtion.title = button.label
            configurtion.image = button.image
        case .scanText:
            configurtion.title = button.label
            configurtion.image = button.image
        }
        
        
        addButton.configuration = configurtion
        
        return addButton
    }
    
    @objc func addPhotoOrVideoButtonAction() { //писать после создания кнопки?до?
        controller.didTapAddPhotoOrVideoButton()
    }
    
    func makeAddButtonsStack() -> UIStackView {//название норм?
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.spacing = 0.4
        vStack.backgroundColor = .gray
        vStack.layer.cornerRadius = 15
        vStack.clipsToBounds = true
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.isHidden = true
        
        AddButtons.allCases.forEach { button in
            vStack.addArrangedSubview(makeAdd(button: button))
        }
        
        let lineView = UIView()//задаю темную толстую полоску
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        lineView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        vStack.insertArrangedSubview(lineView, at: 2) // вставляю по index темную полоску
        vStack.setCustomSpacing(0, after: vStack.arrangedSubviews[1]) //убрать тонкий разделитель получилось только так
        vStack.setCustomSpacing(0, after: vStack.arrangedSubviews[2]) //убрать тонкий разделитель получилось только так
        
        return vStack
    }
    
    func makeImageCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)// может лучше можно?
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }
    
}
