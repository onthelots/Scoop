//
//  ReviewView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/02.
//

import UIKit
import Combine

protocol ReviewViewDelegate: AnyObject {
    func didTappedLocationButton()
    func didTappedPictureButton()
    func textViewDidChange(_ textView: UITextView)
}

class ReviewView: UIView {

    weak var delegate: ReviewViewDelegate?

    private let subscription = Set<AnyCancellable>()

    // 이미지 뷰 배열
    var imageViews: [UIImageView] = []
    let textViewPlaceHolder = "해당 장소에 대한 이야기를 공유해주세요.\n구체적으로 작성해주신 글은 이웃에게 큰 도움이 될거에요\n(최소 10자이상, 리뷰를 작성할 주소등록은 필수입니다)"

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .systemBackground
        setupUI()
        updateCharacterCountLabel()
        initializerReviewTextLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Components

    // Warning View
    private lazy var warningView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tintColor
        view.addSubview(warningLabel)
        return view
    }()

    // Warning label
    private lazy var warningLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "홍보/광고, 명예훼손, 악의적인 목적의 글은 작성할 수 없습니다"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Title TextField
    lazy var reviewTextView: UITextView = {
        // Create a TextView.
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.text = textViewPlaceHolder
        textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        textView.textColor = .lightGray
        textView.textAlignment = NSTextAlignment.left
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.tertiaryLabel.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()

    // text Count Label
    private lazy var reviewTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // location View
    lazy var locationView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Picture Stack View
    lazy var imageStackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // seperated Line
    private lazy var seperatedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // place
    private lazy var locationButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.tinted()
        buttonConfig.title = "장소검색"
        buttonConfig.baseForegroundColor = .darkGray
        buttonConfig.baseBackgroundColor = .clear
        buttonConfig.image = UIImage(systemName: "location.square")
        buttonConfig.imagePlacement = .leading
        buttonConfig.imagePadding = 4
        buttonConfig.buttonSize = .small
        let buttonView = UIButton(configuration: buttonConfig)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    // picture
    private lazy var pictureButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.tinted()
        buttonConfig.title = "사진등록"
        buttonConfig.baseForegroundColor = .darkGray
        buttonConfig.baseBackgroundColor = .clear
        buttonConfig.image = UIImage(systemName: "photo")
        buttonConfig.imagePlacement = .leading
        buttonConfig.imagePadding = 4
        buttonConfig.buttonSize = .small
        let buttonView = UIButton(configuration: buttonConfig)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    // button View Container
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func initializerReviewTextLabel() {
        reviewTextCountLabel.text = "0 / 최소 20자"
        reviewTextCountLabel.textColor = .secondaryLabel
    }

    // MARK: - UI Setting
    private func setupUI() {
        self.addSubview(warningView)
        self.addSubview(reviewTextView)
        self.addSubview(reviewTextCountLabel)
        self.addSubview(locationView)
        self.addSubview(imageStackView)
        self.addSubview(seperatedLineView)
        self.addSubview(containerView)

        self.containerView.addSubview(locationButtonView)
        self.containerView.addSubview(pictureButtonView)

        NSLayoutConstraint.activate([
            warningView.topAnchor.constraint(equalTo: self.topAnchor),
            warningView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            warningView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            warningView.heightAnchor.constraint(equalTo: warningView.widthAnchor, multiplier: 0.15),

            warningLabel.centerXAnchor.constraint(equalTo: warningView.centerXAnchor),
            warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),

            reviewTextView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 10),
            reviewTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            reviewTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            reviewTextView.heightAnchor.constraint(equalToConstant: 250),

            reviewTextCountLabel.topAnchor.constraint(equalTo: reviewTextView.bottomAnchor, constant: 10),
            reviewTextCountLabel.trailingAnchor.constraint(equalTo: reviewTextView.trailingAnchor),
            reviewTextCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: reviewTextView.trailingAnchor, constant: 10).withPriority(.defaultLow),

            locationView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            locationView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            locationView.bottomAnchor.constraint(equalTo: imageStackView.topAnchor, constant: -5),
            locationView.heightAnchor.constraint(equalToConstant: 30),

            imageStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            imageStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            imageStackView.bottomAnchor.constraint(equalTo: seperatedLineView.topAnchor, constant: -5),
            imageStackView.heightAnchor.constraint(equalToConstant: 100),

            seperatedLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            seperatedLineView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -5),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 1),

            containerView.heightAnchor.constraint(equalToConstant: 30),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor, constant: -10),

            locationButtonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            locationButtonView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pictureButtonView.leadingAnchor.constraint(equalTo: locationButtonView.trailingAnchor, constant: 10).withPriority(.defaultHigh),
            pictureButtonView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pictureButtonView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10).withPriority(.defaultLow)
        ])

        locationButtonView.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        pictureButtonView.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)

        // TextView TapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    // Update the character count label based on the text in the TextView
     private func updateCharacterCountLabel() {
         let currentTextCount = reviewTextView.text.count
         let minimumTextCount = 20 // 최소 글자 수 (원하는 값으로 변경 가능)
         // 현재 글자 수에 따라 적절한 색상 설정
         if currentTextCount >= minimumTextCount {
             reviewTextCountLabel.textColor = .label
         } else {
             reviewTextCountLabel.textColor = .secondaryLabel
         }

         // 현재 글자 수 표시
         reviewTextCountLabel.text = "\(currentTextCount) / 최소 20자"
     }

    private func createImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        return imageView
    }

    // 이미지 저장
    func addImageView(image: UIImage) {
        let imageView = createImageView(image: image)
        imageViews.append(imageView)
        updateImageViewLayout()
    }

    // 이미지 저장 시, 레이아웃 업데이트
    private func updateImageViewLayout() {
        self.imageStackView.subviews.forEach { $0.removeFromSuperview() }
        // 첫번째 선택되는 ImageView
        var previousImageView: UIImageView?
        for imageView in imageViews {
            imageStackView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            if let previousImageView = previousImageView {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: previousImageView.trailingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: imageStackView.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 70),
                    imageView.widthAnchor.constraint(equalToConstant: 70)
                ])
            } else {
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: 70),
                    imageView.widthAnchor.constraint(equalToConstant: 70),
                    imageView.leadingAnchor.constraint(equalTo: imageStackView.leadingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: imageStackView.centerYAnchor)
                ])
            }
            previousImageView = imageView
        }
    }

    // MARK: - 주소 라벨 뷰 생성
    private func createLabelView(location: SearchResult) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.text = "\(location.placeName) • \(location.addressName)"
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // 주소라벨 추가
    func addLocationLabel(location: SearchResult) {
        self.locationView.subviews.forEach { $0.removeFromSuperview() }
        let label = createLabelView(location: location)
        // locationLabel 속성에 새로 추가된 라벨 할당
        self.locationView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: self.locationView.centerYAnchor)
        ])
    }

    // MARK: - Objc addTarget Action

    // TextView Tapped
    @objc private func didTapTextView(_ sender: Any) {
        self.endEditing(true)
    }

    @objc private func didTapLocationButton() {
        delegate?.didTappedLocationButton()
    }

    @objc private func didTapPictureButton() {
        delegate?.didTappedPictureButton()
    }
}

extension ReviewView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        updateCharacterCountLabel()
        self.delegate?.textViewDidChange(textView)
    }
}
