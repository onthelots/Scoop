//
//  SignInViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit
import Combine

class SignInViewController: UIViewController {

    private var viewModel: SignInViewModel!
    private var subscription: Set<AnyCancellable> = []
    private var errorAlert: UIAlertController? // alert

    lazy var appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dangle_font")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var emailTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .black

        textFieldView.textField.setPlaceholder(
            placeholder: "이메일",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    private lazy var passwordTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .black
        textFieldView.textField.isSecureTextEntry = true

        textFieldView.textField.setPlaceholder(
            placeholder: "비밀번호 입력",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("가입완료 및 로그인하기", for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let signInUseCase = DefaultSignInUseCase(authRepository: DefaultsAuthRepository())
        let emailValidationService = DefaultEmailValidationService()
        viewModel = SignInViewModel(signInUseCase: signInUseCase, emailValidationService: emailValidationService)

        viewModel.checkEmailValidAndSave()
        setupUI()
        bind()
        emailTextFieldView.textField.addTarget(self, action: #selector(emailTextFieldEditingChanged), for: .editingChanged)
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(appNameImageView)
        view.addSubview(emailTextFieldView)
        view.addSubview(passwordTextFieldView)
        view.addSubview(nextButtonView)

        NSLayoutConstraint.activate([

            appNameImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appNameImageView.widthAnchor.constraint(equalToConstant: 150),
            appNameImageView.heightAnchor.constraint(equalToConstant: 83),
            appNameImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),

            emailTextFieldView.topAnchor.constraint(equalTo: appNameImageView.bottomAnchor, constant: 30),
            emailTextFieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextFieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            passwordTextFieldView.topAnchor.constraint(equalTo: emailTextFieldView.bottomAnchor, constant: 10),
            passwordTextFieldView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordTextFieldView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            nextButtonView.topAnchor.constraint(equalTo: passwordTextFieldView.bottomAnchor, constant: 30).withPriority(.defaultHigh),
            nextButtonView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nextButtonView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nextButtonView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).withPriority(.defaultLow)
        ])
    }

    private func bind() {
        viewModel.$isEmailValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButtonView.nextButton.isEnabled = isValid
                self?.nextButtonView.nextButton.tintColor = isValid ? .tintColor : .gray
            }.store(in: &subscription)

        viewModel.$isLoggedIn
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    let loadingIndicator = UIActivityIndicatorView(style: .large)
                    loadingIndicator.center = self?.view.center ?? CGPoint.zero
                    loadingIndicator.startAnimating()
                    self?.view.addSubview(loadingIndicator)


                    self?.saveUserCredentialsToKeychain() // 키체인에 정보를 저장함
                    let tabBarViewController = TabBarViewController()

                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        if !(sceneDelegate.window?.rootViewController is UITabBarController) {
                            let tabBarController = tabBarViewController
                            tabBarController.modalTransitionStyle = .crossDissolve // FadeOut, FadeIn 효과를 적용
                            sceneDelegate.window?.rootViewController = tabBarController
                            sceneDelegate.window?.makeKeyAndVisible()
                        }
                    }
                } else {
                    self?.removeUserCredentialsFromKeychain()
                }
            }
            .store(in: &subscription)

        viewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let message = errorMessage {
                    self?.showErrorAlert(message: message)
                    self?.passwordTextFieldView.textField.text = ""
                } else {
                    self?.hideErrorAlert()
                }
            }
            .store(in: &subscription)
    }

    @objc private func nextButtonTapped() {
        self.viewModel.login(
            email: self.emailTextFieldView.textField.text ?? "",
            password: self.passwordTextFieldView.textField.text ?? ""
        )
    }

    @objc private func emailTextFieldEditingChanged(_ textField: UITextField) {
        if let email = textField.text {
            DispatchQueue.main.async {
                self.emailTextFieldView.textField.setPlaceholder()
            }
            viewModel.emailInput.send(email)
        }
    }

    private func saveUserCredentialsToKeychain() {
        guard let email = self.emailTextFieldView.textField.text,
              let password = self.passwordTextFieldView.textField.text else {
            return
        }
        SensitiveInfoManager.create(key: "userEmail", password: email)
        SensitiveInfoManager.create(key: "userPassword", password: password)
    }

    private func removeUserCredentialsFromKeychain() {
        SensitiveInfoManager.delete(key: "userEmail")
        SensitiveInfoManager.delete(key: "userPassword")
    }

    private func showErrorAlert(message: String) {
         errorAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
         errorAlert?.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
             self?.errorAlert = nil
         }))
         if let errorAlert = errorAlert {
             present(errorAlert, animated: true, completion: nil)
         }
     }

    private func hideErrorAlert() {
         if let errorAlert = errorAlert {
             errorAlert.dismiss(animated: true, completion: nil)
             self.errorAlert = nil
         }
     }
}
