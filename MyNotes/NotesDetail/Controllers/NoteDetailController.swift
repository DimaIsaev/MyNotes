//
//  NoteViewController.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 17.08.2024.
//

import UIKit
import Photos

protocol NoteDetailControllerProtocol: AnyObject {
    
    func didChange(text: String)
    func didBeginEditing()
    func didTapAddFileMenuButton(hidden: Bool) //название?
    func didTapAddPhotoOrVideoButton()
    
}

protocol NoteDetailControllerDelegate: AnyObject {
    
    func didEditTextNote(with id: String, newText: String)
    func didAddToNote(imageName: String, note id: String) -> Note?
    
}

final class NoteDetailController: UIViewController {
    
    private lazy var contentView: NoteDetailViewProtocol = makeContentView()
    
    weak var delegate: NoteDetailControllerDelegate?
    
    private var model: NoteDetailModelProtocol // private?
    
    init(model: NoteDetailModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {// тут не ставил ставить updateViewModel. Model передается в view через makeContentVie->setupView
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

// MARK: - Протокол контроллера

extension NoteDetailController: NoteDetailControllerProtocol {
    
    func didChange(text: String) {
        delegate?.didEditTextNote(with: model.note.id, newText: text)
    }
    
    func didBeginEditing() {
        setupNavigationBarItem()
    }
    
    func didTapAddFileMenuButton(hidden: Bool) {//название?. и аргумент hidden?
        if hidden {
            contentView.hideAddFileMenu(value: false)
        } else {
            contentView.hideAddFileMenu(value: true)
        }
    }
    
    func didTapAddPhotoOrVideoButton() { //посмотреть порядок кода и в целом глянуть
        contentView.hideAddFileMenu(value: true)
        showImagePickerController()
        requestPhotoLibraryAccess()
    }
    
}

//MARK: - UIImagePickerController methods

extension NoteDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {//тут посмотреть asset, assetResources
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) //убрал выше что бы закрыть picker если сработает return
        
        if let selectedImage = info[.originalImage] as? UIImage, let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            guard let fileName = assetResources.first?.originalFilename else { return } // Модет лучше вложенный if сделать без return
            
            do {
                try saveInNoteDirectory(image: selectedImage, with: fileName)//try??
            } catch {
                print("Картинка не сохранена в каталог") //тут как обрабатваем?
            }
            //наеврно можно не возвращать note. Пришлось обновлять model. update всех картинок, а добавляю одну. Если одну то много кода. Можно убрать в отдельную функцию. Не нравиться, что обновляем всю viewModel
            guard let note = delegate?.didAddToNote(imageName: fileName, note: model.note.id) else { return }
            model.update(note: note)
            contentView.update(for: NoteDetailView.ViewModel(note: note, displayedImages: giveImageArray()))//model.note
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
    
    func makeContentView() -> NoteDetailViewProtocol {//viewModel не опционал и его пришлось добавить в аргумент. Норм?
        let view = NoteDetailView(viewModel: NoteDetailView.ViewModel(note: model.note, displayedImages: giveImageArray()),controller: self) //пришлось сюда тоже картинки добавлять
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setupNavigationBarItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(dismissKeyboard))
        navigationItem.titleView?.tintColor = .systemOrange
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

//MARK: - Private methods

private extension NoteDetailController {
    
    func showImagePickerController() { // 1)можно не вызывать отдельной функцией. 2) Как вариант убрать в extention UI Elements
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true)
    }
    
    func requestPhotoLibraryAccess() { //возможно просто оставить пустые {} requestAuthorization если не надо обрабатывать или break
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { newStatus in
                if newStatus == .authorized {// можно вообще убрать
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
            print("Доступ уже предоставлен.")//тут можно везде break поставить
        case .limited:
            print("Доступ ограничен.")
        default:
            print("Неизвестный статус авторизации.")
        }
    }
    
    func saveInNoteDirectory(image: UIImage, with name: String) throws {//посмотреть порядок кода и пробелы // посмотреть throws
        let noteURL = URL.noteDirectory(for: model.note.id)
        try FileManager.default.createDirectory(at: noteURL, withIntermediateDirectories: true)// обработать catch?do?
        
        let imageURL = noteURL.appending(path: name)
        guard let data = image.pngData() else { return }
        try data.write(to: imageURL) // обработать catch?do?
    }
    
    func giveImageArray() -> [UIImage]? { //ну и тут сам массив картинок получаю
        if let fileNames = model.note.fileNames {
            var imageArray = [UIImage]()
            for imageName in fileNames {
                let noteId = model.note.id
                let noteURL = URL.noteDirectory(for: noteId)
                let picURL = noteURL.appending(path: imageName)
                
                if let fileData = FileManager.default.contents(atPath: picURL.path), let fileContent = UIImage(data: fileData) {
                    imageArray.append(fileContent)
                }
            }
            if !imageArray.isEmpty { // Что бы не вернул пустой массив, если будут проблемы с путём или картинкой.
                return imageArray
            }
        }
        return nil
    }
    
}
