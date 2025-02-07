//
//  NoteViewController.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 17.08.2024.
//

import UIKit

protocol NoteDetailControllerProtocol: AnyObject { // Почему тут AnyObject. Вроде не влияет.
    
    func didUpdate()
    
}

protocol NotesDetailViewInteractionProtocol: AnyObject {// Почему тут AnyObject. Вроде не влияет.
    
    func didChange(text: String)
    func didBeginEditing()
    func didTapAddFileMenuButton()
    func didTapAddPhotoOrVideoButton()
    func didTapTakePhotoOrVideoButton()
    
}

protocol NoteDetailControllerDelegate: AnyObject { // Почему тут AnyObject.
    
    func didEditTextNote(with id: String, newText: String)
    func didAddToNote(imageName: String, note id: String)
    
}

final class NoteDetailController: UIViewController {
    
    private lazy var contentView: NoteDetailViewProtocol = makeContentView()
    private lazy var imagePickerManager: ImagePickerManager = {
        return ImagePickerManager(viewController: self)
    }()//manager?//Или можно через метод showImagePickerController. Но стоит создавать метод с одной строкой?
    
    private weak var delegate: NoteDetailControllerDelegate?//может убрать опционал? сделал private и добавил в init
    
    private var model: NoteDetailModelProtocol
    
    init(model: NoteDetailModelProtocol, delegate: NoteDetailControllerDelegate?) {//тут у делегата что по опционалу
        self.model = model
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.startTextViewListening()
        
        if model.note.text.isEmpty {
            contentView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.stopTextViewListening()
    }
    
}

// MARK: - Протокол контроллера cвязанный с событиями в модели

extension NoteDetailController: NoteDetailControllerProtocol {
    
    func didUpdate() {
        contentView.update(for: NoteDetailViewModel(note: model.note))
        //        delegate?.didAddToNote(imageName: model.note.fileNames!.last!, note: model.note.id) vне кажется нуно передавать в основную модель изменения данной модели
    }
    
}

//MARK: - Протокол контроллера связаный с взаимодействием пользователя во View

extension NoteDetailController: NotesDetailViewInteractionProtocol {
    
    func didChange(text: String) {
        delegate?.didEditTextNote(with: model.note.id, newText: text)
    }
    
    func didBeginEditing() {
        setupNavigationBarItem()
    }
    
    func didTapAddFileMenuButton() {
        contentView.toggleAddFileMenu()
    }
    
    func didTapAddPhotoOrVideoButton() {
        contentView.toggleAddFileMenu()
        imagePickerManager.openGallery()//Сделал отдельные методы. Можно через sourcetype. Но подумал зачем знать об этом контроллеру
    }
    
    func didTapTakePhotoOrVideoButton() {
        contentView.toggleAddFileMenu()
        imagePickerManager.openCamera()//Сделал отдельные методы. Можно через sourcetype. Но подумал зачем знать об этом контроллеру
    }
    
}

//MARK: - UIImagePickerController methods

extension NoteDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,//объедеил в один if. оба зафисят друг от друга
           let name = imagePickerManager.fetchImageName(info: info) {
            
            do {
                try saveInNoteDirectory(image, with: name)
            } catch {
                print("Картинка не сохранена в каталог")
                return //добавил если сохранение не получилось. код дальше не имеет смысла
            }
            
            delegate?.didAddToNote(imageName: name, note: model.note.id)//их место тут?или думать?
            model.addFile(name)//их место тут?или думать?
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

// MARK: - UI Elements

private extension NoteDetailController {
    
    func setupView() {
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func makeContentView() -> NoteDetailViewProtocol {
        let view = NoteDetailView(viewModel: NoteDetailViewModel(note: model.note), controller: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setupNavigationBarItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        navigationItem.titleView?.tintColor = .systemOrange
    }
    
    @objc func dismissKeyboard() {//где его место? название точно норм? может TapDoneButton
        view.endEditing(true)
    }
    
}

//MARK: - Private methods

private extension NoteDetailController {
    
    func saveInNoteDirectory(_ image: UIImage, with name: String) throws {// Аргумент _ норм? Ушел от повторений image: image
        guard let data = image.pngData() else { return } //почему не jpeg,перенес в начало. Если не конвектируется, смысла нет.
        //глянуть порядок кода. Вроде разделил по смыслу
        let noteURL = URL.noteDirectory(for: model.note.id)
        let imageURL = noteURL.appending(path: name)
        
        try FileManager.default.createDirectory(at: noteURL, withIntermediateDirectories: true)
        try data.write(to: imageURL)
    }
    
}
