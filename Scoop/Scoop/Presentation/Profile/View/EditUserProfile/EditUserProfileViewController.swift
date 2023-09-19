//
//  EditUserProfileViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Combine
import UIKit
import Firebase
import FirebaseAuth


class EditUserProfileViewController: UIViewController {

    private var viewModel: EditUserProfileViewModel!
    private var subscription = Set<AnyCancellable>()

    // MARK: - Components
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "닉네임 변경(한글, 영문 포함 6자리 이내)"
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .tintColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()

        textFieldView.textField.tintColor = .tintColor
        textFieldView.textField.textColor = .label

        textFieldView.textField.setPlaceholder(
            placeholder: "변경할 닉네임 입력",
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

    // 회원탈퇴 버튼
    private lazy var unregisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("탈퇴하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 수정완료 라벨
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("수정완료 및 저장", for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBackButton()
        initalizerViewModel()
        bind()
        viewModel.checkNicknameValidAndSave()
        setupUI()
        textFieldView.textField.addTarget(self, action: #selector(nicknameTextFieldEditingChanged), for: .editingChanged)
        unregisterButton.addTarget(self, action: #selector(unregisterButtonTapped), for: .touchUpInside)
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting
    private func setupUI() {
        view.addSubview(nicknameLabel)
        view.addSubview(textFieldView)
        view.addSubview(eventLabel)
        view.addSubview(unregisterButton)
        view.addSubview(nextButtonView)

        NSLayoutConstraint.activate([
            nicknameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            textFieldView.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 10),
            textFieldView.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            textFieldView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            eventLabel.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 10),
            eventLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),

            unregisterButton.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 20),
            unregisterButton.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),

            nextButtonView.topAnchor.constraint(greaterThanOrEqualTo: unregisterButton.bottomAnchor, constant: 150).withPriority(.defaultLow),
            nextButtonView.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            nextButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButtonView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10).withPriority(.defaultHigh)
        ])
    }


    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let nicknameValidationService = DefaultNicknameValidationService()

        viewModel = EditUserProfileViewModel(userInfoUseCase: userInfoUseCase, signUpUseCase: signUpUseCase, nicknameValidationService: nicknameValidationService)
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

    // TextFied Value Changed
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

    @objc private func unregisterButtonTapped() {
        let alert = UIAlertController(title: "회원 탈퇴하기",
                                      message: "기존 회원님의 데이터는 복구가 불가능합니다. 동의하십니까?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "아니오",
                                      style: .cancel))
        alert.addAction(UIAlertAction(title: "네",
                                      style: .destructive, handler: { _ in

            if let user = Auth.auth().currentUser {
                user.delete()
                UserDefaultStorage<String>().deleteCache(key: "email")
                UserDefaultStorage<String>().deleteCache(key: "password")

                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let startPageViewController = UINavigationController(rootViewController: StartPageViewController())
                    let transitionOptions: UIView.AnimationOptions = [.transitionCrossDissolve, .curveEaseInOut]
                    UIView.transition(with: sceneDelegate.window!, duration: 0.5, options: transitionOptions, animations: {
                        sceneDelegate.window?.rootViewController = startPageViewController
                        sceneDelegate.window?.makeKeyAndVisible()
                    }, completion: nil)
                }
            }
        }))
        present(alert, animated: true)
    }

    // NextButton
    @objc private func nextButtonTapped() {
        if let nickname = textFieldView.textField.text {
            viewModel.checkNicknameDuplication(nickname: nickname) { [weak self] isDuplicated in
                if isDuplicated {
                    self?.viewModel.isNicknameValid = false
                    DispatchQueue.main.async {
                        self?.textFieldView.textField.text = ""
                        self?.textFieldView.textField.setError()
                        self?.eventLabel.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.viewModel.newNicknameInput.send(nickname)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
