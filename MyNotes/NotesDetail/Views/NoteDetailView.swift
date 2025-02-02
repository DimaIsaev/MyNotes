//
//  NoteDetailView.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 18.08.2024.
//

import UIKit

protocol NoteDetailViewProtocol: UIView { // Почему тут UIView
    
    func update(for viewModel: NoteDetailViewModel)
    func toggleAddFileMenu()
    
    func startTextViewListening()
    func stopTextViewListening()
    
}

final class NoteDetailView: UIView {
    
    private lazy var textView: UITextView = makeTextView()
    private lazy var toolButtonsStack: NoteDetailToolbar = makeToolButtonsStack() //может makeToolbar?
    private lazy var addButtonsStack: NoteDetailAddFileMenu = makeAddButtonsStack() //может makeAddFileMenu?
    private lazy var imageCollectionView: UICollectionView = makeImageCollectionView()
    
    private var viewModel: NoteDetailViewModel
    //пробел убрать?
    private var controller: NotesDetailViewInteractionProtocol
    
    init(viewModel: NoteDetailViewModel, controller: NotesDetailViewInteractionProtocol) {
        self.viewModel = viewModel
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

// MARK: - СollectionView Methods

extension NoteDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayedImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ImageCell, let image = viewModel.displayedImages?[indexPath.row] {
            cell.setCell(with: image)
        }
        return cell
    }
    
}

// MARK: - Протокол View

extension NoteDetailView: NoteDetailViewProtocol {
    
    func update(for viewModel: NoteDetailViewModel) {
        self.viewModel = viewModel
        imageCollectionView.isHidden = viewModel.isCollectionViewHidden
        if !viewModel.isCollectionViewHidden { //тут у Cергея ! знак отсутствовал//опять логика
            imageCollectionView.reloadData()
        }
    }
    
    func toggleAddFileMenu() {
        addButtonsStack.isHidden = !addButtonsStack.isHidden
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
    
    func setupLoyaut() {
        addSubview(textView)
        addSubview(toolButtonsStack)
        addSubview(imageCollectionView)
        addSubview(addButtonsStack)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            textView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -35),
            textView.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -10),
            
            toolButtonsStack.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -20),
            toolButtonsStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            toolButtonsStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            addButtonsStack.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -15),
            addButtonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            addButtonsStack.widthAnchor.constraint(equalToConstant: 255),
            
            imageCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: toolButtonsStack.topAnchor, constant: -15),
            imageCollectionView.heightAnchor.constraint(equalToConstant: 115),
        ])
    }
    
    func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        textView.attributedText = viewModel.attributedText
        return textView
    }
    
    func makeToolButtonsStack() -> NoteDetailToolbar { //может убрать stack и назвать MakeToolbar?
        let toolbar = NoteDetailToolbar(//по переносам точно все норм?
            buttons: [//почему так скобки странно стоят везде.
                .checklist({
                    print("checklist не работает")
                }),
                .addFile({ [weak self] in//тут не понимаю зачем weak. почему данную строку ты перенес ниже? У меня стоят уже норм
                    self?.controller.didTapAddFileMenuButton()
                }),//тут скобки можно оставить на одной строке?
                .drawing({
                    print("drawing не работает")
                }),
                .addNewNote({
                    print("addNewNote не работает")
                })
            ]
        )
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }
    
    func makeAddButtonsStack() -> NoteDetailAddFileMenu { //может убрать stack и назвать MakeAddButtonMenu?
        let addFileMenu = NoteDetailAddFileMenu(buttons: [
            .attachFile({
                print("attachFile не работает")
            }),
            .recordAudio({
                print("recordAudio не работает")
            }),
            .selectPhotoOrVideo({ //self? Посмотреть обязательно
                self.controller.didTapAddPhotoOrVideoButton()
            }),
            .takePhotoOrVideo({
                print("takePhotoOrVideo не работает")
            }),
            .scanDocument({
                print("scanDocument не работает")
            }),
            .scanText({
                print("scanText не работает")
            })
        ])
        
        addFileMenu.translatesAutoresizingMaskIntoConstraints = false
        addFileMenu.isHidden = true //тут пришлось добавить
        return addFileMenu
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
        collectionView.isHidden = viewModel.isCollectionViewHidden
        return collectionView
    }
    
}
