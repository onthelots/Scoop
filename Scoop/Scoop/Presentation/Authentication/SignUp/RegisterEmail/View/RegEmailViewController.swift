//
//  RegEmailViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/19.
//

import Combine
import Firebase
import FirebaseAuth
import UIKit

class RegEmailViewController: UIViewController {

    private var viewModel: RegEmailViewModel!
    private var subscription = Set<AnyCancellable>()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "회원가입에 필요한\n사용자 이메일 입력해주세요"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .label

        textFieldView.textField.setPlaceholder(
            placeholder: "이메일 주소 입력 (필수)",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    // 토글뷰 (에러시, 나타나는 뷰)
    private lazy var eventLabel: UILabel = {
        let label = UILabel()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "exclamationmark.circle")
        imageAttachment.image = imageAttachment.image?.withTintColor(UIColor.systemRed)
        imageAttachment.bounds = CGRect(x: -1, y: -2, width: 12, height: 12)
        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "이미 존재하는 이메일입니다. 다시 확인해주세요"))
        label.textColor = .systemRed
        label.attributedText = attributedString
        label.sizeToFit()
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true // 일단 숨겨놓음
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 다음 버튼 라벨
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("다음", for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(textFieldView)
        view.addSubview(eventLabel)
        view.addSubview(nextButtonView)

        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let emailValidationService = DefaultEmailValidationService()

        viewModel = RegEmailViewModel(signUpUseCase: signUpUseCase, emailValidationService: emailValidationService)

        bind()
        viewModel.checkEmailValidAndSave()

        textFieldView.textField.addTarget(self, action: #selector(emailTextFieldEditingChanged), for: .editingChanged)
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        eventLabel.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            textFieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            textFieldView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textFieldView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            eventLabel.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 10),
            eventLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            nextButtonView.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 50).withPriority(.defaultHigh),
            nextButtonView.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor),
            nextButtonView.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor)
        ])
    }

    // MARK: - ViewModel Binding
    private func bind() {
        viewModel.$isEmailValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButtonView.nextButton.isEnabled = isValid
                self?.nextButtonView.nextButton.tintColor = isValid ? .tintColor : .gray
            }.store(in: &subscription)
    }

    @objc private func emailTextFieldEditingChanged(_ textField: UITextField) {
        if let email = textField.text {
            DispatchQueue.main.async {
                self.eventLabel.isHidden = true
                self.textFieldView.textField.setPlaceholder()
            }
            viewModel.emailInput.send(email)
        }
    }

    // NextButton
    @objc private func nextButtonTapped() {
        if let email = textFieldView.textField.text {
            viewModel.checkEmailDuplication(email: email) { [weak self] isDuplicated in
                // 1. 만약, 중복되었다면?
                if isDuplicated {
                    // isEmailValide도 false로 변경시킴
                    self?.viewModel.isEmailValid = false
                    DispatchQueue.main.async {
                        self?.textFieldView.textField.text = ""
                        self?.textFieldView.textField.setError()
                        self?.eventLabel.isHidden = false
                    }
                } else {
                    self?.viewModel.setUserEmail(email: email) // 사용자 이메일 설정
                    print("사용자의 저장된 이메일 : \(email)")
                    DispatchQueue.main.async {
                        self?.textFieldView.textField.text = ""
                        self?.viewModel.isEmailValid = false
                        let viewController = RegPasswordViewController(email: email)
                        viewController.navigationItem.largeTitleDisplayMode = .never
                        self?.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            }
        }
    }
}
