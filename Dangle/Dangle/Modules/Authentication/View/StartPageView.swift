//
//  StartPageView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit

protocol StartPageViewDelegate: AnyObject {
    func signUpButtonDidTapped()
    func signInButtonDidTapped()
}

// MARK: - StartPageView
class StartPageView: UIView {
    weak var delegate: StartPageViewDelegate?

    // MARK: - Components (UIImage, Labels, Buttons)

    // appNameImageView
    private let appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dangle_font")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // keywordLabel
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        label.text = "daily, discover, deliver"
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // descriptionLabel
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.sizeToFit()
        label.text = """
우리 동네 이웃의 다양한 일상소식
댕글을 통해 쉽고 빠르게 만나보세요
"""
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // verticalStackView
    private let verticalButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // signInButton
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 동네 설정하고 소식 만나보기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // signInButton
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인하기", for: .normal)
        button.setTitleColor(UIColor.tintColor, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()

        // MARK: - button Action
        // signUp
        signUpButton.addTarget(
            delegate,
            action: #selector(signUpButtonDidTapped),
            for: .touchUpInside
        )

        // signIn
        signInButton.addTarget(
            delegate,
            action: #selector(signInButtonDidTapped),
            for: .touchUpInside
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupUI
    func setupUI() {
        // image, Labels
        keywordLabel.sizeToFit()
        addSubview(appNameImageView)
        addSubview(keywordLabel)
        addSubview(descriptionLabel)

        // add subview (button stack)
        self.verticalButtonStackView.addArrangedSubview(signUpButton)
        self.verticalButtonStackView.addArrangedSubview(signInButton)
        addSubview(verticalButtonStackView)

        NSLayoutConstraint.activate([
            // imageView
            appNameImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            appNameImageView.widthAnchor.constraint(equalToConstant: 201),
            appNameImageView.heightAnchor.constraint(equalToConstant: 83),
            appNameImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 200),

            // keywordLabel
            keywordLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            keywordLabel.topAnchor.constraint(equalTo: self.appNameImageView.bottomAnchor, constant: 10),

            // descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: self.keywordLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            // button Stack View
            verticalButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            verticalButtonStackView.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 250).withPriority(.defaultLow),
            verticalButtonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50),
            verticalButtonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
            verticalButtonStackView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -50)
        ])
    }

    // MARK: - Button Action
    @objc func signUpButtonDidTapped() {
        delegate?.signUpButtonDidTapped()
    }

    @objc func signInButtonDidTapped() {
        delegate?.signInButtonDidTapped()
    }
}
