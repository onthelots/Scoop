//
//  SignUpViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

/*
 [ ] 전반적인 View 다시 구성하기
 [ ] 이메일 중복검사 버튼 생성하기 (메서드는 이미 구현되어 있음) + 이벤트로 나타내기
 [ ] 이메일, 비밀번호 유효성 검사 부분을 이벤트로 나타내기 (유효하지 않는 비밀번호입니다 등)
 */

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    lazy var baseView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = 12
        return view
    }()

    lazy var titleLb: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원가입"
        label.textAlignment = .center
        return label
    }()

    lazy var emailTf: UITextField = {
        var view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "이메일을 입력해주세요"
        view.borderStyle = .roundedRect
        return view
    }()

    lazy var pwTf: UITextField = {
        var view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "비밀번호를 입력해주세요"
        view.borderStyle = .roundedRect
        return view
    }()

    lazy var joinBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        return button
    }()

    let emailPattern = "^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\\.[a-zA-Z]{2,3}$"
    let pwPattern = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
    var emailValid = false
    var pwValid = false
    var allValid = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
        view.backgroundColor = .white
        addViews()
        applyConstraints()
        addTarget()
    }

    fileprivate func addViews() {
        view.addSubview(baseView)
        baseView.addSubview(stackView)
        stackView.addArrangedSubview(titleLb)
        stackView.addArrangedSubview(emailTf)
        stackView.addArrangedSubview(pwTf)
        stackView.addArrangedSubview(joinBtn)
    }

    fileprivate func applyConstraints() {
        let baseViewConstraints = [
            baseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -30)
        ]

        let emailTfConstraints = [
            emailTf.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(baseViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate(emailTfConstraints)
    }

    fileprivate func addTarget() {
        joinBtn.addTarget(self, action: #selector(didTapJoinButton(_:)), for: .touchUpInside)

        emailTf.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        pwTf.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }

    fileprivate func isValid(text: String, pattern: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: text)
    }

    fileprivate func checkEmail() {
        if isValid(text: emailTf.text!, pattern: emailPattern) {
            emailValid = true
        } else {
            emailValid = false
        }
    }

    fileprivate func checkPw() {
        if isValid(text: pwTf.text!, pattern: pwPattern) {
            pwValid = true
        } else {
            pwValid = false
        }
    }

    fileprivate func checkAll() {
        if emailValid && pwValid {
            print("email, pw Valid Success")
            allValid = true
        } else {
            print("email, pw Valid Fail")
            allValid = false
        }
    }

    @objc func textFieldDidChange(_ sender: UITextField) -> Bool {
        switch sender {
        case emailTf:
            checkEmail()
        case pwTf:
            checkPw()
        default:
            break
        }
        checkAll()
        return true
    }

    @objc func didTapJoinButton(_ sender: UIButton) {
        print("회원가입 버튼 클릭")

        if let email = emailTf.text {
            print("Email : ", email)
        }

        if let pw = pwTf.text {
            print("Password : ", pw)
        }

        if allValid {
            createUser()
        }
    }

    fileprivate func createUser() {
        guard let email = emailTf.text else { return }
        guard let pw = pwTf.text else { return }

        // 별도의 이메일 중복 검사를 실시
        checkEmailExists(email: email) { [weak self] exists in
            guard let self = self else { return }

            if exists {
                print("Email already exists")
                // 중복된 이메일 처리 코드를 작성
                // 예: 중복된 이메일을 사용자에게 알려주거나 다른 처리 수행
            } else {
                // UserDefaults Location
                let userLocation: String = CoreLocationManager().getCachedUserLocation(key: "deselectedUserLocation")?.name ?? ""
                Auth.auth().createUser(withEmail: email, password: pw) { [weak self] result, error in
                    guard let self = self else { return }

                    if let error = error {
                        print("Error creating user: \(error)")
                        return
                    }

                    guard let uid = result?.user.uid else {
                        print("User UID not found")
                        return
                    }

                    // Firestore에 사용자 정보 저장
                    let database = Firestore.firestore()
                    database.collection("users").document(uid).setData([
                        "email": email,
                        "name": email,
                        "location": userLocation
                    ]) { error in
                        if let error = error {
                            print("Error saving user info to Firestore: \(error)")
                        } else {
                            print("User info saved successfully")
                            // 여기서 다음 화면으로 이동하거나 다른 작업 수행
                        }
                    }
                }
            }
        }
    }

    fileprivate func checkEmailExists(email: String, completion: @escaping (Bool) -> Void) {
        let database = Firestore.firestore()
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking email exists: \(error)")
                completion(false)
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                // 이미 해당 이메일이 존재함
                completion(true)
            } else {
                // 해당 이메일이 존재하지 않음
                completion(false)
            }
        }
    }
}
