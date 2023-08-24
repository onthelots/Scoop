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
    private let thumbnailImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let categoryButtonLabel: UIButton = {
        let button = UIButton()
        button.setTitle("맛집/카페", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.tintColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .blue

        contentView.addSubview(categoryButtonLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(locationLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            categoryButtonLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 5),
            categoryButtonLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 5),
            categoryButtonLabel.widthAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 0.3),
            categoryButtonLabel.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.2),

            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).withPriority(.defaultHigh),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).withPriority(.defaultHigh),

            descriptionLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),

            locationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5).withPriority(.defaultHigh),
            locationLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).withPriority(.defaultHigh)


        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        categoryButtonLabel.setTitle("", for: .normal)
        thumbnailImageView.image = nil
        descriptionLabel.text = nil
        locationLabel.text = nil
    }

    // MARK: - 목업
    func configure(item: EducationEventDTO) {
        self.categoryButtonLabel.titleLabel?.text = item.time
        self.thumbnailImageView.kf.setImage(
            with: URL(string: item.thumbNail ?? "")!,
            placeholder: UIImage(systemName: "hands.sparkles.fill")
        )
        self.descriptionLabel.text = item.title
        self.locationLabel.text = item.location
    }
}
