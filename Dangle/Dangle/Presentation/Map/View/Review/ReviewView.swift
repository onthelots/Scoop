//
//  ReviewView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/02.
//

import UIKit
import Combine

class ReviewView: UIView {

    // MARK: - Components
    let textViewPlaceHolder = "해당 장소에 대한 이야기를 공유해주세요\n구체적으로 작성해주신 글은 이웃에게 큰 도움이 될거에요"

    private let subscription = Set<AnyCancellable>()

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
    private lazy var reviewTextView: UITextView = {
        // Create a TextView.
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.text = textViewPlaceHolder
        textView.textContainerInset = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
        textView.textColor = .lightGray
        textView.textAlignment = NSTextAlignment.left
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
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
        buttonConfig.baseBackgroundColor = .clear
        buttonConfig.image = UIImage(systemName: "location.square")
        buttonConfig.imagePlacement = .leading
        buttonConfig.imagePadding = 4
        let buttonView = UIButton(configuration: buttonConfig)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    // picture
    private lazy var pictureButtonView: UIButton = {
        var buttonConfig = UIButton.Configuration.tinted()
        buttonConfig.title = "사진등록"
        buttonConfig.baseBackgroundColor = .clear
        buttonConfig.image = UIImage(systemName: "photo")
        buttonConfig.imagePlacement = .leading
        buttonConfig.imagePadding = 4
        let buttonView = UIButton(configuration: buttonConfig)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(locationButtonView)
        stackView.addArrangedSubview(pictureButtonView)
        return stackView
    }()

    private func setupUI() {
        self.addSubview(warningView)
        self.addSubview(reviewTextView)
        self.addSubview(seperatedLineView)
        self.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            warningView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            warningView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            warningView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            warningView.heightAnchor.constraint(equalTo: warningView.widthAnchor, multiplier: 0.1),

            warningLabel.centerXAnchor.constraint(equalTo: warningView.centerXAnchor),
            warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),

            reviewTextView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 10),
            reviewTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            reviewTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            reviewTextView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -13),

            seperatedLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            seperatedLineView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -5),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 1),

            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStackView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))

        self.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapTextView(_ sender: Any) {
        self.endEditing(true)
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
