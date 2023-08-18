//
//  SignUpView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import UIKit
import Combine

class SignUpView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입을 위해\n이메일과 비밀번호를 작성해주세요"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 주소"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일 입력"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let emailValidationLabel: UILabel = {
        let label = UILabel()
        label.text = "V"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 (영문, 숫자 포함 8자리 이상)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 입력"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let passwordValidationLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let passwordContainsLetterLabel: UILabel = {
        let label = UILabel()
        label.text = "영문포함"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let passwordContainsNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자포함"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let passwordLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "8-20자 이내"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 확인"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    let passwordMatchLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 일치"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.tintColor = .gray
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(emailLabel)
        addSubview(emailTextField)
        addSubview(emailValidationLabel)
        addSubview(passwordLabel)
        addSubview(passwordTextField)
        addSubview(passwordValidationLabelsStackView)
        addSubview(confirmPasswordLabel)
        addSubview(confirmPasswordTextField)
        addSubview(passwordMatchLabel)
        addSubview(nextButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            emailValidationLabel.centerYAnchor.constraint(equalTo: emailTextField.centerYAnchor),
            emailValidationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            passwordValidationLabelsStackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            passwordValidationLabelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordValidationLabelsStackView.bottomAnchor, constant: 20),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            passwordMatchLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 8),
            passwordMatchLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        // Set up password validation labels
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsLetterLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsNumberLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordLengthLabel)
    }
}
