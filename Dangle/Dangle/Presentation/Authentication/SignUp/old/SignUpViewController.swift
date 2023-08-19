//
//  SignUpView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/18.
//

//import UIKit
//import Combine
//import Firebase
//import FirebaseAuth
//
//class SignUpViewController: UIViewController {
//    
//    private lazy var signUpView: SignUpView = {
//        let view = SignUpView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private var viewModel: SignUpViewModel!
//    private var subscription = Set<AnyCancellable>()
//
//    var users: [UserInfo] = []
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(signUpView)
//        view.backgroundColor = .systemBackground
//        setupBackButton()
//
//        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
//        let emailValidationService = DefaultEmailValidationService()
//        let passwordValidationService = DefaultPasswordValidationService()
//
//        viewModel = SignUpViewModel(
//            signUpUseCase: signUpUseCase,
//            emailValidationService: emailValidationService,
//            passwordValidationService: passwordValidationService
//        )
//
//        setupBindings()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        NSLayoutConstraint.activate([
//            signUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            signUpView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//            signUpView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
//            signUpView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//        ])
//    }
//
//    // ViewModel Binding
//    private func setupBindings() {
//
//        viewModel.$users
//            .receive(on: RunLoop.main)
//            .sink { [weak self] items in
//                self?.users = items
//            }.store(in: &subscription)
//
//        // 아웃풋! (유저가 인터렉션 할 때, 값이 또 다시 방출됨)
//        // 4. 유효성 검사의 값(ViewModel 3번에 따라 받은)
//        viewModel.$isEmailValid
//            .receive(on: RunLoop.main)
//        // 여기는, 유효성 부분이며, isValid는 bool값이야
//            .sink { [weak signUpView] isValid in
//                // 해당 뷰의 버튼 색상을 바꿔
//                signUpView?.emailValidationButton.tintColor = isValid ? .black : .lightGray
//            }
//            .store(in: &subscription)
//
//        viewModel.$isPasswordContainsLetter
//            .receive(on: RunLoop.main)
//            .sink { [weak signUpView] isValid in
//                signUpView?.passwordContainsLetterLabel.textColor = isValid ? .tintColor : .lightGray
//            }
//            .store(in: &subscription)
//
//        viewModel.$isPasswordContainsNumber
//        //            .combineLatest(viewModel.$isPasswordContainsLetter) { $0 && $1 }
//            .receive(on: RunLoop.main)
//            .sink { [weak signUpView] isValid in
//                signUpView?.passwordContainsNumberLabel.textColor = isValid ? .tintColor : .lightGray
//            }
//            .store(in: &subscription)
//
//        viewModel.$isPasswordLengthValid
//            .receive(on: RunLoop.main)
//            .sink { [weak signUpView] isValid in
//                signUpView?.passwordLengthLabel.textColor = isValid ? .tintColor : .lightGray
//            }
//            .store(in: &subscription)
//
//        // MARK: - 3개 조건이 만족했을 때, 해당 퍼블리셔에도 값을 할당해야 하나?
//        //        viewModel.$isPasswordValid
//        //            .receive(on: RunLoop.main)
//        //            .sink { [weak signUpView] isValid in
//        //                signUpView?.confirmPasswordLabel.textColor = isValid ? .green : .lightGray
//        //            }
//        //            .store(in: &cancellables)
//
//        viewModel.$doPasswordsMatch
//            .receive(on: RunLoop.main)
//            .sink { [weak signUpView] doMatch in
//                signUpView?.passwordMatchLabel.textColor = doMatch ? .green : .lightGray
//            }
//            .store(in: &subscription)
//
//        viewModel.$isSignUpButtonEnabled
//            .receive(on: RunLoop.main)
//            .sink { [weak signUpView] isEnabled in
//                signUpView?.nextButton.isEnabled = isEnabled
//                signUpView?.nextButton.tintColor = isEnabled ? .tintColor : .gray
//            }
//            .store(in: &subscription)
//
//        signUpView.emailTextField.addTarget(self, action: #selector(emailTextFieldEditingChanged), for: .editingChanged)
//        signUpView.passwordTextField.addTarget(self, action: #selector(passwordTextFieldEditingChanged), for: .editingChanged)
//        signUpView.confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldEditingChanged), for: .editingChanged)
//
//        signUpView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
//    }
//
//
//    // MARK: - 1. 이메일 텍스트가 변경될 때 -> viewModel의 emailInpt에 값을 전달할거야!
//    @objc private func emailTextFieldEditingChanged(_ textField: UITextField) {
//        if let email = textField.text {
//            viewModel.emailInput.send(email)
//        }
//    }
//
//    @objc private func passwordTextFieldEditingChanged(_ textField: UITextField) {
//        if let password = textField.text {
//            viewModel.passwordInput.send(password)
//        }
//    }
//
//    @objc private func confirmPasswordTextFieldEditingChanged(_ textField: UITextField) {
//        if let confirmPassword = textField.text {
//            viewModel.confirmPasswordInput.send(confirmPassword)
//        }
//    }
//
//    private func handleSignUpFailure(error: Error) {
//        // 실패 처리와 관련된 UI 로직을 여기에 구현합니다.
//        // 예를 들어, 에러 메시지를 표시하거나 얼럿을 띄울 수 있습니다.
//        let errorMessage = "Sign-up failed: \(error.localizedDescription)"
//        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//
//    // 다음 버튼이 눌리게 되면, 실행할 메서드
//    @objc private func nextButtonTapped() {
//        let location: String = UserDefaultStorage<Regcode>().getCached(key: "location")?.name ?? ""
//        if let email = signUpView.emailTextField.text,
//           let password = signUpView.passwordTextField.text {
//            print("이메일 : \(email), 패스워드 \(password), 위치 : \(location)")
//            viewModel.checkEmailExistsAndSignUp(email: email, password: password, location: location)
//        }
//    }
//}
