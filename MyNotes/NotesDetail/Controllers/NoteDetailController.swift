//
//  NoteViewController.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 17.08.2024.
//

import UIKit
import Photos

protocol NoteDetailControllerProtocol: AnyObject { // Почему тут AnyObject. Вроде не влияет.
    
    func didUpdate()
    
}

protocol NotesDetailViewInteractionProtocol: AnyObject {// Почему тут AnyObject. Вроде не влияет.
    
    func didChange(text: String)
    func didBeginEditing()
    func didTapAddFileMenuButton()
    func didTapAddPhotoOrVideoButton()
    
}

protocol NoteDetailControllerDelegate: AnyObject { // Почему тут AnyObject.
    
    func didEditTextNote(with id: String, newText: String)
    func didAddToNote(imageName: String, note id: String)
    
}

final class NoteDetailController: UIViewController {
    
    private lazy var contentView: NoteDetailViewProtocol = makeContentView()
    
    weak var delegate: NoteDetailControllerDelegate?//может убрать опционал?
    
    private var model: NoteDetailModelProtocol
    
    init(model: NoteDetailModelProtocol) {
        self.model = model
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
    
    func didTapAddPhotoOrVideoButton() { //посмотреть порядок кода и в целом глянуть
        contentView.toggleAddFileMenu()
        showImagePickerController()
        requestPhotoLibraryAccess() //может вложить проверку в ImagePickerController
    }
    
}

//MARK: - UIImagePickerController methods

extension NoteDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage, let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            guard let fileName = assetResources.first?.originalFilename else { return }
            
            do {
                try saveInNoteDirectory(image: selectedImage, with: fileName)
            } catch {
                print("Картинка не сохранена в каталог")
            }
            
            delegate?.didAddToNote(imageName: fileName, note: model.note.id)
            model.addFile(name: fileName)
        }
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
    
    @objc func dismissKeyboard() {//где его место?
        view.endEditing(true)
    }
    
}

//MARK: - Private methods

private extension NoteDetailController {
    
    func showImagePickerController() { // Как вариант убрать в extention UI Elements, Является UIElement?
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true)
    }
    
    func requestPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { newStatus in
                if newStatus == .authorized {
                    print("Доступ предоставлен.")
                } else {
                    print("Доступ запрещен.")
                }
            }
        case .restricted:
            print("Доступ ограничен.")
        case .denied:
            print("Досуп запрещен.")
        case .authorized:
            print("Доступ уже предоставлен.")
        case .limited:
            print("Доступ ограничен.")
        default:
            print("Неизвестный статус авторизации.")
        }
    }
    
    func saveInNoteDirectory(image: UIImage, with name: String) throws {
        let noteURL = URL.noteDirectory(for: model.note.id)
        try FileManager.default.createDirectory(at: noteURL, withIntermediateDirectories: true)
        
        let imageURL = noteURL.appending(path: name)
        guard let data = image.pngData() else { return }
        try data.write(to: imageURL)
    }
    
}
