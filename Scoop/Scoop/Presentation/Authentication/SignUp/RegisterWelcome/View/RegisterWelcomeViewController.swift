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
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // appNameImageView
    lazy var appNameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "scoop")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // keywordLabel
    lazy var keywordLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
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
        label.textColor = .white
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
        buttonView.nextButton.setTitleColor(.tintColor, for: .normal)
        buttonView.nextButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        buttonView.nextButton.isEnabled = true
        buttonView.nextButton.backgroundColor = .white
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tintColor

        // 2. Viewmodel 초기화 (DefaultsAuthRepository를 사용함)
        let signUpUseCase = DefaultSignUpUseCase(authRepository: DefaultsAuthRepository())
        let signInUseCase = DefaultSignInUseCase(authRepository: DefaultsAuthRepository())
        viewModel = RegisterWelcomeViewModel(signUpUseCase: signUpUseCase, signInUseCase: signInUseCase)
        setTitle(nickname: nickname)
        setupUI()
        bind()
        nextButtonView.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }

    private func setupUI() {
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
        viewModel.$isLoggedIn
            .sink { [weak self] isLoggIn in
                if isLoggIn {
                    let loadingIndicator = UIActivityIndicatorView(style: .large)
                    loadingIndicator.center = self?.view.center ?? CGPoint.zero
                    loadingIndicator.startAnimating()
                    self?.view.addSubview(loadingIndicator)
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        if !(sceneDelegate.window?.rootViewController is UITabBarController) {
                            let tabBarController = TabBarViewController()
                            tabBarController.modalTransitionStyle = .crossDissolve // FadeOut, FadeIn 효과를 적용
                            sceneDelegate.window?.rootViewController = tabBarController
                            sceneDelegate.window?.makeKeyAndVisible()
                        }
                    }
                } else {
                    return
                }
            }.store(in: &subscription)
    }

    // ----> 4. 버튼이 눌렀을 때 동작
    @objc private func nextButtonTapped() {
        let location: String = UserDefaultStorage<LocationInfo>().getCached(key: "location")?.name ?? ""
        let longitude: String = UserDefaultStorage<LocationInfo>().getCached(key: "location")?.longitude ?? ""
        let latitude: String = UserDefaultStorage<LocationInfo>().getCached(key: "location")?.latitude ?? ""

        let userInfo = UserInfo(email: email, password: password, location: location, nickname: nickname, longitude: longitude, latitude: latitude)
        // 4. viewModel의 signUpButtonTapped 퍼블리셔에게 정보를 전달함
        viewModel.signUpButtonTapped.send(userInfo)
        print("signUpButtonTapped 퍼블리셔에게 userInfo를 전달합니다")
        print("userInfo : \(userInfo)")
    }
}
