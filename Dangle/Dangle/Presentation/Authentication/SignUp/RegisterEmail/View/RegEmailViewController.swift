//
//  RegEmailViewController.swift
//  Dangle
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

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "이메일 입력해주세요"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .black

        textFieldView.textField.setPlaceholder(
            placeholder: "이메일을 입력해주세요",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    // 다음 버튼 라벨
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.titleLabel?.text = "다음"
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(textFieldView)
        view.addSubview(nextButtonView)

        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let emailValidationService = DefaultEmailValidationService()

        viewModel = RegEmailViewModel(signUpUseCase: signUpUseCase, emailValidationService: emailValidationService)

        setupBinding()

        textFieldView.textField.addTarget(self, action: #selector(emailTextFieldEditingChanged), for: .editingChanged)
        textFieldView.textField.addTarget(self, action: #selector(emailTextFieldEditingDidBegin), for: .editingDidBegin)

        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
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

            nextButtonView.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 50).withPriority(.defaultHigh),
            nextButtonView.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor),
            nextButtonView.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor)
        ])
    }

    private func setupBinding() {

        // MARK: - 6. isEmailValid값을 바인딩 받아옴 -> nextButton의 상태를 변환시킴
        viewModel.$isEmailValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButtonView.nextButton.isEnabled = isValid
                self?.nextButtonView.nextButton.tintColor = isValid ? .tintColor : .gray
            }.store(in: &subscription)
    }

    // MARK: - 1. 이메일 텍스트가 변경될 때 -> viewModel의 emailInpt에 값을 전달할거야!
    @objc private func emailTextFieldEditingChanged(_ textField: UITextField) {
        if let email = textField.text {
            viewModel.emailInput.send(email) // 텍스트 필드 값을, emailInput으로 전달
        }
    }

    @objc private func emailTextFieldEditingDidBegin(_ textField: UITextField) {
        textFieldView.eventLabel.isHidden = true
        textFieldView.textField.setPlaceholder() // 에러 표시 해제
    }

    // 다음 버튼이 눌리게 되면, 실행할 메서드 -> 데이터 전달
    // RegEmailViewController.swift

    // ... (이전 코드)
    @objc private func nextButtonTapped() {
        if let email = textFieldView.textField.text {
            viewModel.executeEmailDuplicationCheck(email: email) { [weak self] isDuplicated in
                if isDuplicated {
                    print("이메일 중복")
                    DispatchQueue.main.async {
                        self?.textFieldView.textField.text = ""
                        self?.textFieldView.eventLabel.isHidden = false
                        self?.textFieldView.textField.setError()
                    }
                } else {
                    print("이메일이 유효함")
                    let viewController = RegPasswordViewController()
                    viewController.navigationItem.largeTitleDisplayMode = .never
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}
