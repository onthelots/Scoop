//
//  SignInViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import UIKit
import Combine

/*
[ ] 유효한 이메일, 비밀번호를 눌렀을 시, 다음 화면으로 넘어가는 동시에 해당 유저의 데이터가 유지될 수 있도록 함
[ ] 앱을 종료할 경우 -> 유저 데이터가 유지되어 있다면 자동 로그인될 수 있도록
[ ] 앱을 삭제한 경우 -> 기존 디바이스에 저장되어 있던 유저 데이터를 날리자
[ ] 로그아웃을 할 경우 -> 정상적으로 로그인이 비 활성화 되고, 로그인 뷰로 이동할 수 있도록 함
 */

class SignInViewController: UIViewController {

    private var viewModel: SignInViewModel!
    private var cancellables: Set<AnyCancellable> = []

    private var errorAlert: UIAlertController? // alert

    lazy var appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dangle_font")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // 이메일 입력 -> 이메일 중복여부 확인 불필요 X 유효한 이메일 형태인지만 확인하기 (버튼 비 활성화)
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

    // 비밀번호 입력 -> 비밀번호 양식 체크 X 단순히 입력만 (버튼 비 활성화)
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

    // 다음 버튼 라벨 -> 이메일, 그리고 비밀번호가 1자리 이상 입력되었을 때 활성화 하기
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("가입완료 및 로그인하기", for: .normal)
        buttonView.nextButton.isEnabled = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let authRepository = DefaultsAuthRepository()
        let signInUseCase = DefaultSignInUseCase(authRepository: authRepository)
        viewModel = SignInViewModel(signInUseCase: signInUseCase)

        setupUI()

        bind()

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
        viewModel.$isLoggedIn
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.saveUserCredentialsToKeychain() // 키체인에 정보를 저장함
                    // TabbarViewController로 이동, 그런데 이미 viewController가 왜 겹쳐있는거야?
                    self?.navigateToTabBar() // 로그인 상태일 때 TabBarViewController로 이동

                } else {
                    self?.removeUserCredentialsFromKeychain() // isLoggedIn 값이 false일때는 키체인 삭제, 초기화해줌 
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .sink { [weak self] errorMessage in
                if let message = errorMessage {
                    self?.showErrorAlert(message: message)
                } else {
                    self?.hideErrorAlert()
                }
            }
            .store(in: &cancellables)
    }

    private func navigateToTabBar() {
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }

    @objc private func nextButtonTapped() {
        self.viewModel.login(
            email: self.emailTextFieldView.textField.text ?? "",
            password: self.passwordTextFieldView.textField.text ?? ""
        )
    }

    // 유저정보 키체인 저장
    private func saveUserCredentialsToKeychain() {
        guard let email = self.emailTextFieldView.textField.text,
              let password = self.passwordTextFieldView.textField.text else {
            return
        }
        SensitiveInfoManager.create(key: "userEmail", password: email)
        SensitiveInfoManager.create(key: "userPassword", password: password)
    }

    // MARK: - 유저정보 키체인 삭제 : 로그아웃 기능에서도 활용할 것
    private func removeUserCredentialsFromKeychain() {
        SensitiveInfoManager.delete(key: "userEmail")
        SensitiveInfoManager.delete(key: "userPassword")
    }

    // 불 일치 시, Alert
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

//    private func navigateToTabBar() {
//        let tabBarController = TabBarViewController() // TabBarViewController를 초기화
//        navigationController?.setViewControllers([tabBarController], animated: true) // 탭바 뷰컨트롤러로 이동
//    }
}
