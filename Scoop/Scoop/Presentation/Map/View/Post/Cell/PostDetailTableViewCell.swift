//
//  PostDetailTableViewCell.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/11.
//

import UIKit

class PostDetailTableViewCell: UITableViewCell {

    static let identifier = "PostDetailTableViewCell"

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
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    private lazy var imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 셀에 서브뷰 추가
        contentView.addSubview(userImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(imageStackView)
        contentView.addSubview(reviewLabel)

        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 20),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            nickNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),

            dateLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),

            imageStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            imageStackView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            reviewLabel.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 10),
            reviewLabel.leadingAnchor.constraint(equalTo: imageStackView.leadingAnchor),
            reviewLabel.trailingAnchor.constraint(equalTo: imageStackView.trailingAnchor),
            reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
        nickNameLabel.text = ""
        dateLabel.text = ""
        reviewLabel.text = ""

        // 이미지 스크롤뷰와 스택뷰를 초기화합니다.
        for subview in imageStackView.arrangedSubviews {
            imageStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    func configure(with post: Post) {
        userImageView.image = UIImage(systemName: "person.circle.fill")
        nickNameLabel.text = post.nickname
        reviewLabel.text = post.review
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: post.timestamp)

        if let postImages = post.postImage,
           postImages.count > 0 {
            for imageUrlString in postImages {
                if let imageUrl = URL(string: imageUrlString) {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    imageView.clipsToBounds = true
                    imageView.kf.setImage(
                        with: imageUrl,
                        placeholder: UIImage(systemName: "photo"),
                        options: [.transition(.fade(0.2))]
                    )
                    imageStackView.addArrangedSubview(imageView)
                }
            }
            if postImages.count == 1 {
                // 이미지가 2개 또는 3개인 경우
                NSLayoutConstraint.activate([
                    imageStackView.heightAnchor.constraint(equalToConstant: 150),
                    imageStackView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
                    imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
                ])
            } else {
                NSLayoutConstraint.activate([
                    imageStackView.heightAnchor.constraint(equalToConstant: 100),
                    imageStackView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
                    imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
                ])
            }
        } else {
            self.imageStackView.isHidden = true
            NSLayoutConstraint.activate([
                reviewLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
                reviewLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
                reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }

    }
}
