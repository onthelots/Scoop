//
//  PostCollectionViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import UIKit
import Kingfisher

class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"

    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var nickNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var reviewLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    private lazy var locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(userImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(reviewLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(thumbnailImageView)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([

            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            userImageView.widthAnchor.constraint(equalToConstant: 15),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            nickNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 5),

            reviewLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            reviewLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),

            locationLabel.topAnchor.constraint(greaterThanOrEqualTo: reviewLabel.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            locationLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),

            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
        nickNameLabel.text = ""
        reviewLabel.text = ""
        locationLabel.text = ""
        thumbnailImageView.image = nil
    }

    func configure(items: Post) {
        userImageView.image = UIImage(systemName: "person.circle.fill")
        self.nickNameLabel.text = items.nickname
        self.reviewLabel.text = items.review
        self.locationLabel.text = items.storeName
        self.thumbnailImageView.kf.setImage(
            with: URL(string: items.postImage?.first ?? "")
        )
    }
}
