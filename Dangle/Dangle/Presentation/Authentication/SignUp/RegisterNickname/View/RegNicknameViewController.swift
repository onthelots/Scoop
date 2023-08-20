//
//  RegNicknameViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import Firebase
import FirebaseAuth
import UIKit

class RegNicknameViewController: UIViewController {

    var email: String // 불러온 이메일값
    var password: String // 불러온 패스워드

    private var viewModel: RegNicknameViewModel!
    private var subscription = Set<AnyCancellable>()


    init(email: String, password: String) {
        self.email = email
        self.password = password
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
        label.text = "사용하실\n닉네임을 입력해주세요"
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
            placeholder: "닉네임 (2-8자의 한글, 영문, 숫자만 사용 가능)",
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
        attributedString.append(NSAttributedString(string: "이미 존재하는 닉네임입니다. 다시 확인해주세요"))
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
        buttonView.nextButton.setTitle("가입완료 및 로그인하기", for: .normal)
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
        let nicknameValidationService = DefaultNicknameValidationService()

        viewModel = RegNicknameViewModel(signUpUseCase: signUpUseCase, nicknameValidationService: nicknameValidationService)

        bind()
        viewModel.checkNicknameValidAndSave()

        textFieldView.textField.addTarget(self, action: #selector(nicknameTextFieldEditingChanged), for: .editingChanged)
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

            eventLabel.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 10),
            eventLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            nextButtonView.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 50).withPriority(.defaultHigh),
            nextButtonView.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor),
            nextButtonView.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor)
        ])
    }

    // -----> 값을 바인딩  -----> 3. isEmailValid 유효값에 따라, 컴포넌트를 변경시킴
    private func bind() {
        viewModel.$isNicknameValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButtonView.nextButton.isEnabled = isValid
                self?.nextButtonView.nextButton.tintColor = isValid ? .tintColor : .gray
            }.store(in: &subscription)
    }

    // <---- 값을 전달함 <--- 1. 텍스트 필드에서 입력하는 값을 전달함 (emailInput)
    @objc private func nicknameTextFieldEditingChanged(_ textField: UITextField) {
        if let nickname = textField.text {
            DispatchQueue.main.async {
                self.eventLabel.isHidden = true
                self.textFieldView.textField.setPlaceholder()
            }
            if nickname.count >= 2 && nickname.count <= 8 {
                viewModel.isNicknameValid = true

            } else {
                viewModel.isNicknameValid = false
                
            }
        }
    }
    // NextButton
    @objc private func nextButtonTapped() {
        if let nickname = textFieldView.textField.text {
            viewModel.executeNicknameDuplicationCheck(nickname: nickname) { [weak self] isDuplicated in
                if isDuplicated {
                    self?.viewModel.isNicknameValid = false
                    DispatchQueue.main.async {
                        self?.textFieldView.textField.text = ""
                        self?.textFieldView.textField.setError()
                        self?.eventLabel.isHidden = false
                    }
                } else {
                    self?.viewModel.setUserNickname(nickname: nickname) // 사용자 닉네임 설정

                    // Firebase 계정 등록
                    if let email = self?.email, let password = self?.password {
                        let location: String = UserDefaultStorage<Regcode>().getCached(key: "location")?.name ?? ""
                        self?.viewModel.signUpUseCase.execute(
                            email: email,
                            password: password,
                            location: location, // 사용자의 위치 정보
                            nickname: nickname
                        ) { [weak self] result in
                            switch result {
                            case .success:
                                // Firebase 계정 등록 성공
                                DispatchQueue.main.async {
                                    self?.textFieldView.textField.text = ""
                                    let signInViewController = SignInViewController()
                                    signInViewController.navigationItem.largeTitleDisplayMode = .never
                                    self?.navigationController?.setViewControllers([signInViewController], animated: true)
                                }
                            case .failure(let error):
                                print("Firebase signUp failed: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}
