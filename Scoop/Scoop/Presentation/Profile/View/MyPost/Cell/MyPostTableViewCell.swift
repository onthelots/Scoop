//
//  MyPostTableViewCell.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/13.
//


import UIKit

class MyPostTableViewCell: UITableViewCell {

    static let identifier = "MyPostTableViewCell"

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
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
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
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    private lazy var storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 2
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
        contentView.addSubview(reviewLabel)
        contentView.addSubview(storeNameLabel)
        contentView.addSubview(dateLabel)

        // AutoLayout 제약 조건 설정
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 20),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            nickNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),

            dateLabel.centerYAnchor.constraint(equalTo: nickNameLabel.centerYAnchor),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nickNameLabel.trailingAnchor, constant: 10).withPriority(.defaultLow),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).withPriority(.required),

            storeNameLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 10),
            storeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            reviewLabel.topAnchor.constraint(greaterThanOrEqualTo: storeNameLabel.bottomAnchor, constant: 10),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        storeNameLabel.text = ""
        reviewLabel.text = ""
    }

    func configure(with post: Post) {
        userImageView.image = UIImage(systemName: "person.circle.fill")
        nickNameLabel.text = post.nickname
        reviewLabel.text = post.review
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd" // 원하는 날짜 형식 설정
        dateLabel.text = dateFormatter.string(from: post.timestamp)
        storeNameLabel.text = post.storeName
    }
}
