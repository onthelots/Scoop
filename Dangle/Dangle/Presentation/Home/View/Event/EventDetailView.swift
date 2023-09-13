//
//  EventDetailView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit

class EventDetailView: UIView {

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

    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var useTargetCategoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var useTargetLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dotLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.text = "•"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoryLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "location.fill")
        imageAttachment.bounds = CGRect(x: 12, y: 0, width: 12, height: 12)

        let attributedString = NSMutableAttributedString(string: " ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))

        let labelText = NSMutableAttributedString(string: " " + (label.text ?? ""))
        attributedString.append(labelText)

        label.textColor = .black
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "calendar")
        imageAttachment.image = imageAttachment.image?.withTintColor(UIColor.systemRed)
        imageAttachment.bounds = CGRect(x: -1, y: -2, width: 8, height: 8)

        let attributedString = NSMutableAttributedString(string: " ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))

        let labelText = NSMutableAttributedString(string: " " + (label.text ?? ""))
        attributedString.append(labelText)

        label.textColor = .black
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var webButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("자세히 보러가기", for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.nextButton.isEnabled = true
        return buttonView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        useTargetCategoryStackView.addArrangedSubview(useTargetLabel)
        useTargetCategoryStackView.addArrangedSubview(dotLabel)
        useTargetCategoryStackView.addArrangedSubview(categoryLabel)
        detailStackView.addArrangedSubview(titleLabel)
        detailStackView.addArrangedSubview(useTargetCategoryStackView)
        detailStackView.addArrangedSubview(locationLabel)
        detailStackView.addArrangedSubview(dateLabel)
        addSubview(thumbnailImageView)
        addSubview(detailStackView)
        addSubview(webButtonView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnailImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.85),
            thumbnailImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6),
            thumbnailImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            detailStackView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 20),
            detailStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            detailStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            detailStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            webButtonView.topAnchor.constraint(greaterThanOrEqualTo: detailStackView.bottomAnchor, constant: 10).withPriority(.defaultLow),
            webButtonView.leadingAnchor.constraint(equalTo: detailStackView.leadingAnchor),
            webButtonView.trailingAnchor.constraint(equalTo: detailStackView.trailingAnchor),
            webButtonView.bottomAnchor.constraint(equalTo: self.bottomAnchor).withPriority(.required)
        ])
    }

    func configure(eventDetail: EventDetailDTO) {
        self.thumbnailImageView.kf.setImage(with: URL(string: eventDetail.thumbNail ?? ""), placeholder: UIImage(systemName: "hands.sparkles.fill"))
        self.titleLabel.text = eventDetail.title
        self.useTargetLabel.text = eventDetail.useTarget
        self.categoryLabel.text = eventDetail.category
        self.locationLabel.text = eventDetail.location
        self.dateLabel.text = eventDetail.date
    }
}
