//
//  ReviewView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/02.
//

import UIKit
import Combine

protocol ReviewViewDelegate: AnyObject {
    func didTappedLocationButton()
    func didTappedPictureButton()
}

class ReviewView: UIView {

    weak var reviewViewDelegate: ReviewViewDelegate?

    private let subscription = Set<AnyCancellable>()

    // 선택한 이미지 뷰 배열
    var imageViews: [UIImageView] = []

    // 이미지 뷰 배열에서 UIImage(알아서 저장될 것임)
    var selectedImages: [UIImage] {
        return imageViews.compactMap { $0.image }
    }

    let textViewPlaceHolder = "해당 장소에 대한 이야기를 공유해주세요\n구체적으로 작성해주신 글은 이웃에게 큰 도움이 될거에요"

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        textView.textContainerInset = UIEdgeInsets(top: 15.0, left: 0.0, bottom: 15.0, right: 0.0)
        textView.textColor = .lightGray
        textView.textAlignment = NSTextAlignment.left
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()

    // Picture Stack View
    lazy var pictureStackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    // seperated Line
    private let seperatedLineView: UIView = {
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

    // MARK: - 이미지 뷰 생성
    private func createImageView(image: UIImage) -> UIImageView {

        // imageView 반환
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        // 이미지 삭제 버튼 (ImageView의 오른쪽 상단모서리에 위치)
        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .tintColor
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteImageButtonTapped(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5), // 삭제 버튼 상단 정렬 (오른쪽 상단 모서리에 위치)
            deleteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -5), // 삭제 버튼 오른쪽 정렬 (오른쪽 상단 모서리에 위치)
            deleteButton.widthAnchor.constraint(equalToConstant: 30), // 삭제 버튼의 너비 설정
            deleteButton.heightAnchor.constraint(equalToConstant: 30) // 삭제 버튼의 높이 설정
        ])

        return imageView
    }

    private func setupUI() {
        self.addSubview(warningView)
        self.addSubview(reviewTextView)
        self.addSubview(pictureStackView)
        self.addSubview(seperatedLineView)
        self.containerView.addSubview(locationButtonView)
        self.containerView.addSubview(pictureButtonView)
        self.addSubview(containerView)

        NSLayoutConstraint.activate([
            warningView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            warningView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            warningView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            warningView.heightAnchor.constraint(equalTo: warningView.widthAnchor, multiplier: 0.15),

            warningLabel.centerXAnchor.constraint(equalTo: warningView.centerXAnchor),
            warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),

            reviewTextView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 10),
            reviewTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            reviewTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
//            reviewTextView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -13),
            reviewTextView.heightAnchor.constraint(equalToConstant: 200),

            pictureStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            pictureStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            pictureStackView.bottomAnchor.constraint(equalTo: seperatedLineView.topAnchor, constant: -5),
            pictureStackView.heightAnchor.constraint(equalToConstant: 100),

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

        // Button Add Target
        locationButtonView.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        pictureButtonView.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)

        // TextView TapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    // MARK: -> 이미지뷰 배열에 넣기 -> ViewController에서 사용자가 선택한 UIImage를 받아옴
    func addImageView(image: UIImage) {
        let imageView = createImageView(image: image)
        imageViews.append(imageView) // 이미지 뷰 생성하고 할당
        updateImageViewLayout() // 업데이트 실시
    }

    // 이미지+Stack View 업데이트
    private func updateImageViewLayout() {
        // pictureStackView의 모든 subView를 삭제 (초기화)
        pictureStackView.subviews.forEach { $0.removeFromSuperview() }
        
        // 첫번째 선택되는 ImageView
        var previousImageView: UIImageView?
        
        // pictureStackView에 Imageview 할당
        for imageView in imageViews {
            pictureStackView.addSubview(imageView) // Stack View에 imageView 할당
            pictureStackView.isHidden = false // View Hidden Toggle(false)로
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // 1. 첫번째 이미지 뷰가 존재할 경우
            if let previousImageView = previousImageView {
                // 1. 첫번째 이미지 뷰 옆으로 정렬되도록 함
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: previousImageView.trailingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: pictureStackView.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 100),
                    imageView.widthAnchor.constraint(equalToConstant: 100)
                ])
            } else {
                // 2. 이미지 뷰가 아무것도 없을 때 -> imageView를 Stack View 하단에 위치하도록
                NSLayoutConstraint.activate([
                    imageView.heightAnchor.constraint(equalToConstant: 100),
                    imageView.widthAnchor.constraint(equalToConstant: 100),
                    imageView.leadingAnchor.constraint(equalTo: pictureStackView.leadingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: pictureStackView.centerYAnchor)
                ])
            }
            
            // 첫번째 PreviousImageView를 imageView로 할당
            previousImageView = imageView
            print("이미지가 할당되었습니다.")
        }
    }

    // MARK: - Objc addTarget Action

    // TextView Tapped
    @objc private func didTapTextView(_ sender: Any) {
        self.endEditing(true)
    }

    // deleteImageButton Tapped
    @objc private func deleteImageButtonTapped(_ sender: UIButton) {
        if let imageView = sender.superview as? UIImageView, let index = imageViews.firstIndex(of: imageView) {
               imageViews.remove(at: index)
               imageView.removeFromSuperview()
               updateImageViewLayout()
           }
    }

    @objc private func didTapLocationButton() {
        // delegate
        reviewViewDelegate?.didTappedLocationButton()
    }

    @objc private func didTapPictureButton() {
        // delegate
        reviewViewDelegate?.didTappedPictureButton()
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
}
