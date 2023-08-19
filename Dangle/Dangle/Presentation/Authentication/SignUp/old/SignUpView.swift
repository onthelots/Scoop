//
//  SignUpView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

import UIKit
import Combine

class SignUpView: UIView {

    // 타이틀
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 이메일 라벨
    let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 이메일 텍스트필드
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 메일 체크 버튼
    let emailValidationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightGray
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 비밀번호 라벨
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "비밀번호"
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 텍스트필드
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 입력"
        textField.borderStyle = .line
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 비밀번호 유효성 검사 StackView
    let passwordValidationLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // 비밀번호 문자포함 라벨
    let passwordContainsLetterLabel: UILabel = {
        let label = UILabel()
        label.text = "영문포함"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 숫자포함 라벨
    let passwordContainsNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자포함"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 길이 라벨
    let passwordLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "8-20자 이내"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 확인 라벨
    let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "비밀번호 확인"
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 확인 텍스트필드
    let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 한번 더 입력해주세요"
        textField.borderStyle = .line
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 비밀번호 확인 일치 여부
    let passwordMatchLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 일치"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 다음 버튼 라벨
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.backgroundColor = .tintColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // 초기 값은, 비 활성화 상태
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
        addSubview(emailValidationButton)
        addSubview(passwordLabel)
        addSubview(passwordTextField)

        // Set up password validation labels
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsLetterLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsNumberLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordLengthLabel)
        addSubview(passwordValidationLabelsStackView)
        addSubview(confirmPasswordLabel)
        addSubview(confirmPasswordTextField)
        addSubview(passwordMatchLabel)
        addSubview(nextButton)

        // titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        // Email
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emailValidationButton.centerYAnchor.constraint(equalTo: emailTextField.centerYAnchor),
            emailValidationButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: -20)
        ])

        // Password
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
            passwordLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            passwordValidationLabelsStackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            passwordValidationLabelsStackView.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor)
        ])

        // Password confirm
        NSLayoutConstraint.activate([
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordValidationLabelsStackView.bottomAnchor, constant: 40),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 5),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordLabel.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            passwordMatchLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 8),
            passwordMatchLabel.leadingAnchor.constraint(equalTo: confirmPasswordTextField.leadingAnchor)
        ])

        // Next Button
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(greaterThanOrEqualTo: passwordMatchLabel.bottomAnchor, constant: 50).withPriority(.defaultLow),
            nextButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).withPriority(.required)
        ])
    }
}
