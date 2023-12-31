//
//  StartPageView.swift
//  Scoop
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
    lazy var appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scoop")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // keywordLabel
    lazy var keywordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        label.text = "서울, 그리고 우리 동네 소식 맛보기"
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // descriptionLabel
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        label.text = """
다양한 이벤트와 일상의 소식들
스쿱을 통해 쉽고 빠르게 만나보세요
"""
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // signInButton
    lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("내 동네 설정하고 소식 만나보기", for: .normal)
        button.setTitleColor(UIColor.tintColor, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // signInButton
    lazy var signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("이미 스쿱 계정이 있으신가요? >", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
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
        addSubview(signUpButton)
        addSubview(signInButton)


        NSLayoutConstraint.activate([
            // imageView
            appNameImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            appNameImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            appNameImageView.heightAnchor.constraint(equalTo: appNameImageView.widthAnchor, multiplier: 1.0),
            appNameImageView.topAnchor.constraint(equalTo: self.topAnchor),

            // keywordLabel
            keywordLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            keywordLabel.topAnchor.constraint(equalTo: self.appNameImageView.bottomAnchor, constant: 10),

            // descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: self.keywordLabel.bottomAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            // button
            signUpButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40).withPriority(.defaultLow),
            signUpButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            signUpButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),

            signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 5),
            signInButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            signInButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            signInButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).withPriority(.required)
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
