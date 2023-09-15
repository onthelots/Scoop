//
//  NewIssueCollectionViewCell.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import UIKit

class NewIssueCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewIssueCollectionViewCell"

    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.distribution = .fillProportionally // 내부 Components의 Intrinsic content size(높이, 너비)를 자동으로 설정함
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var numberLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        labelStackView.addArrangedSubview(numberLabel)
        labelStackView.addArrangedSubview(descriptionLabel)
        addSubview(labelStackView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0).withPriority(.required),
            labelStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            labelStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            labelStackView.topAnchor.constraint(equalTo: self.topAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        descriptionLabel.text = nil
    }

    func configure(items: NewIssueDTO, atIndex index: Int) {
        numberLabel.text = "\(index + 1)."
        descriptionLabel.text = items.title
    }
}
