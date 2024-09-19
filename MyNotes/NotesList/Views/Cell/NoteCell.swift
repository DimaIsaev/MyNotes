//
//  NoteCell.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 15.08.2024.
//

import UIKit

final class NoteCell: UITableViewCell {
    
    private lazy var cellTitle = makeCellLabel()
    private lazy var cellDateLabel = makeDateLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .black
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }  
    
    func configureLabels(with note: Note) {
        cellTitle.text = note.title
        cellDateLabel.text = note.detailText
    }
}

private extension NoteCell {
    
    func setupLayout() {
        contentView.addSubview(cellTitle)
        contentView.addSubview(cellDateLabel)
        
        NSLayoutConstraint.activate([
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            cellDateLabel.topAnchor.constraint(equalTo: cellTitle.bottomAnchor, constant: 2),
            cellDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cellDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func makeCellLabel() -> UILabel {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }
    
    func makeDateLabel() -> UILabel {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }
}
