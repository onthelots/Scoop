//
//  NewIssueCollectionViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import UIKit

class NewIssueCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewIssueCollectionViewCell"

    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "1"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(descriptionLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel.text = nil
    }

    func configure(items: NewIssueDTO) {
        self.descriptionLabel.text = items.title
    }
}
