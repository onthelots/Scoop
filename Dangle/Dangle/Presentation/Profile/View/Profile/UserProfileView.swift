//
//  UserProfileView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import UIKit

protocol UserProfileViewDelegate: AnyObject {
    func editButtonTapped()
}

class UserProfileView: UIView {

    weak var delegate: UserProfileViewDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .tintColor
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    lazy var editProfileButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "pencil.circle.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 25)
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func editButtonTapped() {
        delegate.editButtonTapped()
    }

    private func setupUI() {
        self.verticalStackView.addArrangedSubview(emailLabel)
        self.verticalStackView.addArrangedSubview(nicknameLabel)
        self.addSubview(editProfileButton)
        self.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            verticalStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            editProfileButton.leadingAnchor.constraint(greaterThanOrEqualTo: verticalStackView.trailingAnchor, constant: 10),
            editProfileButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            editProfileButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            editProfileButton.widthAnchor.constraint(equalTo: editProfileButton.heightAnchor, multiplier: 1.0),
            editProfileButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)

        ])
    }

    func userProfileConfigure(_ userInfo: UserInfo) {
        emailLabel.text = userInfo.email
        nicknameLabel.text = userInfo.nickname
    }
}
