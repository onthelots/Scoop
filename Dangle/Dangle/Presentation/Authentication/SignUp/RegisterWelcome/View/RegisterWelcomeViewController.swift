//
//  RegisterWelcomeViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import Combine
import UIKit
import Firebase
import FirebaseAuth

class RegisterWelcomeViewController: UIViewController {

    var email: String // 불러온 이메일값
    var password: String // 불러온 패스워드
    var nickname: String // 불러온 닉네임

    private var viewModel: RegisterWelcomeViewModel!
    private var subscription = Set<AnyCancellable>()

    init(email: String, password: String, nickname: String) {
        self.email = email
        self.password = password
        self.nickname = nickname
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
        label.text = ""
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // appNameImageView
    lazy var appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Dangle_1024")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // keywordLabel
    lazy var keywordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.sizeToFit()
        label.text = "회원가입이 완료되었습니다"
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // descriptionLabel
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.sizeToFit()
        label.text = "로그인 후, 다양한 이슈와 소식을 확인해보세요!"
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 다음 버튼 라벨
    private lazy var nextButtonView: CommonButtonView = {
        let buttonView = CommonButtonView()
        buttonView.nextButton.setTitle("가입완료 및 로그인하기", for: .normal)
        buttonView.nextButton.isEnabled = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // 2. Viewmodel 초기화 (DefaultsAuthRepository를 사용함)
        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        viewModel = RegisterWelcomeViewModel(signUpUseCase: signUpUseCase)
        setTitle(nickname: nickname)
        setupUI()
        bind()
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(appNameImageView)
        view.addSubview(keywordLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButtonView)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),


            appNameImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 120),
            appNameImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            appNameImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            appNameImageView.heightAnchor.constraint(equalToConstant: 150),

            keywordLabel.topAnchor.constraint(equalTo: appNameImageView.bottomAnchor, constant: 10),
            keywordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            keywordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: keywordLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            nextButtonView.topAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.bottomAnchor, constant: 150).withPriority(.defaultLow),
            nextButtonView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            nextButtonView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            nextButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).withPriority(.defaultHigh)
        ])
    }

    private func setTitle(nickname: String) {
        self.titleLabel.text = "\(nickname)님\n환영합니다!"
    }

    private func bind() {
        viewModel.signUpButtonTapped
        // 3. 버튼이 눌렀을 때 실행될 클로저를 정의함
            .sink { _ in 
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    if !(sceneDelegate.window?.rootViewController is UITabBarController) {
                        sceneDelegate.window?.rootViewController = TabBarViewController()
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            }.store(in: &subscription)
    }

    // ----> 4. 버튼이 눌렀을 때 동작
    @objc private func nextButtonTapped() {
        let location: String = UserDefaultStorage<Regcode>().getCached(key: "location")?.name ?? ""
        let userInfo = UserInfo(email: email, password: password, location: location, nickname: nickname)
        // 4. viewModel의 signUpButtonTapped 퍼블리셔에게 정보를 전달함
        viewModel.signUpButtonTapped.send(userInfo)
        print("signUpButtonTapped 퍼블리셔에게 userInfo를 전달합니다")
    }
}
