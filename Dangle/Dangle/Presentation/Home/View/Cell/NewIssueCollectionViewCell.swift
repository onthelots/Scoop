//
//  NewIssueCollectionViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import UIKit
import Kingfisher

class NewIssueCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewIssueCollectionViewCell"

    // MARK: - Components
    private lazy var thumbnailImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var categoryButtonLabel: UIButton = {
        let button = UIButton()
        button.setTitle("맛집/카페", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.backgroundColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()


    private lazy var descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        contentView.insertSubview(categoryButtonLabel, aboveSubview: thumbnailImageView)

        labelStackView.addArrangedSubview(descriptionLabel)
        labelStackView.addArrangedSubview(locationLabel)
        contentView.addSubview(labelStackView)

        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.6),

            categoryButtonLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 5),
            categoryButtonLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 5),
            categoryButtonLabel.widthAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.35),
            categoryButtonLabel.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.25),

            labelStackView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            labelStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 10),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        categoryButtonLabel.setTitle("", for: .normal)
        thumbnailImageView.image = nil
        descriptionLabel.text = nil
        locationLabel.text = nil
    }
}
