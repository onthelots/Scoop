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

    // MARK: - Components
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally // 내부 Components의 Intrinsic content size(높이, 너비)를 자동으로 설정함
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var nickNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var reviewLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
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

        labelStackView.addArrangedSubview(nickNameLabel)
        labelStackView.addArrangedSubview(reviewLabel)
        labelStackView.addArrangedSubview(locationLabel)

        contentView.addSubview(labelStackView)
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
            labelStackView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            labelStackView.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),
            labelStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nickNameLabel.text = ""
        reviewLabel.text = ""
        locationLabel.text = ""
        thumbnailImageView.image = UIImage(systemName: "hands.sparkles.fill")
    }

    func configure(items: Post) {
        self.nickNameLabel.text = items.nickname
        self.reviewLabel.text = items.review
        self.locationLabel.text = items.storeName
        self.thumbnailImageView.kf.setImage(
            with: URL(string: items.postImage ?? ""),
            placeholder: UIImage(systemName: "hands.sparkles.fill")
        )
    }
}
