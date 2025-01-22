//
//  ViewController.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 13.08.2024.
//

import UIKit

protocol NotesListControllerProtocol: AnyObject {
    
    func didUpdate()
    
}

protocol NotesListViewInteractionProtocol: AnyObject {
    
    func didSelectNote(with id: String)
    func didTapOnDeleteNote(with id: String)
    func didTapAddBtn()
    
}

final class NotesListController: UIViewController {
    
    private lazy var contentView: NotesListViewProtocol = makeContentView()
    
    private let model: NoteListModelProtocol // private?
    
    init(model: NoteListModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
        
        contentView.update(for: NotesListView.ViewModel(notes: sortNotes()))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeNoteIfEmpty()
    }
    
}

// MARK: - Протокол контроллера cвязанный с событиями в модели

extension NotesListController: NotesListControllerProtocol {
    
    func didUpdate() {
        let sortedNotes = sortNotes()
        contentView.update(for: NotesListView.ViewModel(notes: sortedNotes))
    }
    
}

//MARK: - Протокол контроллера связаный с взаимодействием пользователя во View

extension NotesListController: NotesListViewInteractionProtocol {
    
    func didSelectNote(with id: String) {
        guard let note = model.notes.first(where: { $0.id == id }) else { return }
        let model = NoteDetailModel(storedNote: note)
        let detailController = NoteDetailController(model: model)
        model.controller = detailController
        detailController.delegate = self
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func didTapOnDeleteNote(with id: String) {
        model.deleteNote(with: id)
    }
    
    func didTapAddBtn() {
        let note = model.createNote() //может не возвращать note. а взять заметку по model.notes.last?
        let model = NoteDetailModel(storedNote: note)
        let detailController = NoteDetailController(model: model)
        model.controller = detailController
        detailController.delegate = self
        navigationController?.pushViewController(detailController, animated: true)
    }
    
}

// MARK: - Delegated methods

extension NotesListController: NoteDetailControllerDelegate {
    
    func didEditTextNote(with id: String, newText: String)  {
        model.editTextNote(with: id, newText: newText)
    }
    
    func didAddToNote(imageName: String, note id: String) -> Note? { // может не нужно возвращать. подумать!
        let note = model.addToNote(imageName: imageName, note: id)// повтрение?
        return note // может не нужно возвращать. подумать!
    }
    
}

// MARK: - UI Elements

private extension NotesListController {
    
    func setupView() {
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func makeContentView() -> NotesListViewProtocol {
        let view = NotesListView(controller: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setupNavigationController() {
        title = "Заметки"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .systemOrange
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(buttonAction))
    }
    
    @objc func buttonAction() {
        
    }
    
}

// MARK: - Private methods

private extension NotesListController {
    
    private func sortNotes() -> [Note] {
        let notes = model.notes
        let sortedNotes = notes.sorted { $0.date > $1.date }
        return sortedNotes
    }
    
    private func removeNoteIfEmpty () {
        let sortedNotes = sortNotes()
        guard let firstNote = sortedNotes.first else {
            return
        }
        
        if firstNote.text.isEmpty {
            model.deleteNote(with: firstNote.id)
        }
    }
    
}



