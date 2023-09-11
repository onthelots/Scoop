//
//  PostDetailTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/11.
//

import UIKit

class PostDetailTableViewCell: UITableViewCell {

    static let identifier = "PostDetailTableViewCell"

    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
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

    private lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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

    private lazy var reviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        textView.textAlignment = .left
        textView.sizeToFit()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 0 // 여러 줄 지원
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
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
        contentView.addSubview(imageScrollView)
        imageScrollView.addSubview(imageStackView)
        contentView.addSubview(reviewTextView)

        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor),

            nickNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            nickNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),

            dateLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            imageScrollView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            imageScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
            imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
            imageStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor),

            reviewTextView.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 5),
            reviewTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reviewTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            reviewTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
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
        reviewTextView.text = ""

        // 이미지 스크롤뷰와 스택뷰를 초기화합니다.
        for subview in imageStackView.arrangedSubviews {
            imageStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    func configure(with post: Post) {
        userImageView.image = UIImage(systemName: "person.circle.fill")
        nickNameLabel.text = post.nickname
        reviewTextView.text = post.review
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: post.timestamp)

        // 이미지 스크롤뷰에 이미지 뷰 추가
        if let postImages = post.postImage, postImages.count > 0 {
            for imageUrlString in postImages {
                if let imageUrl = URL(string: imageUrlString) {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
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

            // 이미지 스크롤뷰의 높이를 이미지 수에 맞게 동적으로 조정
            imageScrollView.heightAnchor.constraint(equalToConstant: 100).isActive = false
            let scrollViewHeight = CGFloat(postImages.count * 100) // 이미지 높이 * 이미지 수
            imageScrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight).isActive = true

            // 이미지가 하나일 때 reviewTextView와 너비를 같게 설정
            if postImages.count == 1 {
                NSLayoutConstraint.activate([
                    imageScrollView.leadingAnchor.constraint(equalTo: reviewTextView.leadingAnchor),
                    imageScrollView.trailingAnchor.constraint(equalTo: reviewTextView.trailingAnchor),
                    imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
                    imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
                    imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
                    imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
                    imageStackView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
                    imageStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
                ])
            }
        } else {
            // 이미지가 없는 경우 imageScrollView와 imageStackView를 숨깁니다.
            imageScrollView.isHidden = true
            imageStackView.isHidden = true

            NSLayoutConstraint.activate([
                reviewTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
                reviewTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                reviewTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                reviewTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                reviewTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
            ])
        }

    }
}
