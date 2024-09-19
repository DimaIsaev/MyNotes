//
//  ViewController.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 13.08.2024.
//

import UIKit

protocol NotesListControllerProtocol: AnyObject {
    func didSelect(noteIndex: Int)
    func didDelete(noteIndex: Int)
    func didTapAddBtn()
}

final class NotesListController: UIViewController, NotesListControllerProtocol {
    
    private lazy var contentView: NotesListViewProtocol = makeContentView()
    
    private let model: NoteListModelProtocol
    
    private var noteIndex: Int?
    
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
        self.contentView.update(for: NotesListView.ViewModel(notes: model.notes))
    }
    
    func setupView() {
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func didSelect(noteIndex: Int) {
        let note = model.notes[noteIndex]
        self.noteIndex = noteIndex
        let model = NoteDetailModel(storedTitle: note.title, storedDetailText: note.detailText)
        let detailController = NoteDetailController(model: model)
        detailController.delegate = self
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func didDelete(noteIndex: Int) {
        model.deleteNote(noteIndex: noteIndex)
        self.contentView.update(for: NotesListView.ViewModel(notes: model.notes))
    }
    
    func editNote(note: Note) {
        if let noteIndex = noteIndex {
            model.deleteNote(noteIndex: noteIndex)
        }
        model.saveNote(note: note)
        self.contentView.update(for: NotesListView.ViewModel(notes: model.notes))
    }
    
    func didTapAddBtn() {
        let model = NoteDetailModel(storedTitle: nil, storedDetailText: nil)
        let detailController = NoteDetailController(model: model)
        detailController.delegate = self
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    private func makeContentView() -> NotesListViewProtocol {
        let view = NotesListView(controller: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupNavigationController() {
        title = "Заметки"
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .systemOrange
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(didTapAddButton))
    }
    
    @objc func didTapAddButton() {
        
    }
}

extension NotesListController: NoteDetailControllerDelegate {
    func didCreate(note: Note) {
        model.saveNote(note: note)
        self.contentView.update(for: NotesListView.ViewModel(notes: model.notes))
    }
    
    func didEdit(note: Note) {
        editNote(note: note)
        self.contentView.update(for: NotesListView.ViewModel(notes: model.notes))
    }
}



