//
//  RegPasswordViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import FirebaseAuth
import UIKit

class RegPasswordViewController: UIViewController {

    var email: String // 불러온 이메일값

    var viewModel: RegPasswordViewModel!
    private var subscription = Set<AnyCancellable>()

    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "회원가입에 필요한\n비밀번호를 입력해주세요"
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var firstTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .black
        textFieldView.textField.isSecureTextEntry = true

        textFieldView.textField.setPlaceholder(
            placeholder: "비밀번호 (8자 이상 20자 이내, 문자/숫자 포함)",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    // MARK: - View로 파일 나누기(너무 길어..)

    private lazy var passwordValidationLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var passwordContainsLetterLabel: UILabel = {
        let label = UILabel()
        label.text = "영문포함"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 숫자포함 라벨
    private lazy var passwordContainsNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "숫자포함"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 비밀번호 길이 라벨
    private lazy var passwordLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "8-20자 이내"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var secondTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .black
        textFieldView.textField.isSecureTextEntry = true

        textFieldView.textField.setPlaceholder(
            placeholder: "비밀번호 확인",
            color: .lightGray
        )
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    private lazy var eventLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호가 일치합니다"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // 다음 버튼 라벨
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("다음", for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()
    // users 객체
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(firstTextFieldView)
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsLetterLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordContainsNumberLabel)
        passwordValidationLabelsStackView.addArrangedSubview(passwordLengthLabel)
        view.addSubview(passwordValidationLabelsStackView)
        view.addSubview(secondTextFieldView)
        view.addSubview(eventLabel)
        view.addSubview(nextButtonView)

        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let passwordValidationService = DefaultPasswordValidationService()

        viewModel = RegPasswordViewModel(
            signUpUseCase: signUpUseCase,
            passwordValidationService: passwordValidationService)

        setupBinding()
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            firstTextFieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            firstTextFieldView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            firstTextFieldView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            passwordValidationLabelsStackView.topAnchor.constraint(equalTo: firstTextFieldView.bottomAnchor, constant: 10),
            passwordValidationLabelsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            secondTextFieldView.topAnchor.constraint(equalTo: passwordValidationLabelsStackView.bottomAnchor, constant: 20),
            secondTextFieldView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            secondTextFieldView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            eventLabel.topAnchor.constraint(equalTo: secondTextFieldView.bottomAnchor, constant: 10),
            eventLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            nextButtonView.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 50).withPriority(.defaultHigh),
            nextButtonView.leadingAnchor.constraint(equalTo: secondTextFieldView.leadingAnchor),
            nextButtonView.trailingAnchor.constraint(equalTo: secondTextFieldView.trailingAnchor)
        ])
    }

    private func setupBinding() {
        viewModel.$isPasswordContainsLetter
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.passwordContainsLetterLabel.textColor = isValid ? .tintColor : .lightGray
            }
            .store(in: &subscription)

        viewModel.$isPasswordContainsNumber
        //            .combineLatest(viewModel.$isPasswordContainsLetter) { $0 && $1 }
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.passwordContainsNumberLabel.textColor = isValid ? .tintColor : .lightGray
            }
            .store(in: &subscription)

        viewModel.$isPasswordLengthValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.passwordLengthLabel.textColor = isValid ? .tintColor : .lightGray
            }
            .store(in: &subscription)

        viewModel.$doPasswordsMatch
            .receive(on: RunLoop.main)
            .sink { [weak self] doMatch in
                self?.eventLabel.isHidden = doMatch ? false : true
                self?.eventLabel.textColor = doMatch ? .tintColor : .lightGray
            }
            .store(in: &subscription)

        viewModel.$isSignUpButtonEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnabled in
                self?.nextButtonView.nextButton.isEnabled = isEnabled
                self?.nextButtonView.nextButton.tintColor = isEnabled ? .tintColor : .gray
            }
            .store(in: &subscription)

        firstTextFieldView.textField.addTarget(self, action: #selector(passwordTextFieldEditingChanged), for: .editingChanged)
        secondTextFieldView.textField.addTarget(self, action: #selector(confirmPasswordTextFieldEditingChanged), for: .editingChanged)

        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

    }

    @objc private func passwordTextFieldEditingChanged(_ textField: UITextField) {
        if let password = textField.text {
            viewModel.passwordInput.send(password)
        }
    }

    @objc private func confirmPasswordTextFieldEditingChanged(_ textField: UITextField) {
        if let confirmPassword = textField.text {
            viewModel.confirmPasswordInput.send(confirmPassword)
        }
    }

    // MARK: - 여기서 부터 다시 진행
    @objc private func nextButtonTapped() {
        if let password = secondTextFieldView.textField.text {
            print("저장될 비밀번호 : \(password)")
            DispatchQueue.main.async {
                self.firstTextFieldView.textField.text = ""
                self.secondTextFieldView.textField.text = ""
                let viewController = RegNicknameViewController(email: self.email, password: password)
                viewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
