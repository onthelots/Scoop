//
//  RegPasswordViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/20.
//

import Combine
import Firebase
import FirebaseAuth
import UIKit

class RegPasswordViewController: UIViewController {

    var viewModel: RegEmailViewModel!
    private var subscription = Set<AnyCancellable>()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    private lazy var titleView: CommonTitleView = {
        let view = CommonTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var firstTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
    }()

    private lazy var secondTextFieldView: CommonTextFieldView = {
        let textFieldView = CommonTextFieldView()
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        return textFieldView
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

    // users 객체
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        view.addSubview(titleView)
        view.addSubview(firstTextFieldView)
        view.addSubview(secondTextFieldView)
        view.addSubview(nextButton)

        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let emailValidationService = DefaultEmailValidationService()

        viewModel = RegEmailViewModel(
            signUpUseCase: signUpUseCase,
            emailValidationService: emailValidationService
        )

        setupBinding()
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            firstTextFieldView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 50),
            firstTextFieldView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            firstTextFieldView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),

            secondTextFieldView.topAnchor.constraint(equalTo: firstTextFieldView.bottomAnchor, constant: 20),
            secondTextFieldView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            secondTextFieldView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),

            nextButton.topAnchor.constraint(equalTo: secondTextFieldView.bottomAnchor, constant: 50).withPriority(.defaultHigh),
            nextButton.leadingAnchor.constraint(equalTo: secondTextFieldView.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: secondTextFieldView.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 100).withPriority(.defaultLow)
        ])
    }

    private func setupBinding() {
        //
    }

    @objc private func nextButtonTapped() {
        //
    }
}
