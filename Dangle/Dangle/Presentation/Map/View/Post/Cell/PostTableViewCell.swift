//
//  PostTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/08.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    static let identifier = "PostTableViewCell"

    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.width / 2
        let mockupImage = UIImage(systemName: "person.circle.fill")
        imageView.image = mockupImage
        imageView.contentMode = .scaleAspectFill
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

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 셀에 서브뷰 추가
        contentView.addSubview(userImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(reviewLabel)
        contentView.addSubview(thumbnailImageView)

        // AutoLayout 제약 조건 설정
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),

            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 15),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            nickNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor),

            reviewLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            thumbnailImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        userImageView.image = nil
        nickNameLabel.text = ""
        reviewLabel.text = ""
        thumbnailImageView.image = nil
    }

    func configure(with post: Post) {
//        self.userImageView.kf.setImage(
//            with: URL(string: post.postImage ?? ""),
//            placeholder: UIImage(systemName: "person.circle.fill")
//        )
        nickNameLabel.text = post.nickname
        reviewLabel.text = post.review
        self.thumbnailImageView.kf.setImage(
            with: URL(string: post.postImage ?? ""),
            placeholder: UIImage(systemName: "hands.sparkles.fill")
        )
    }
}
