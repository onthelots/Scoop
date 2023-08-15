//
//  SignUpViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/14.
//

/*
 [ ] View 다시 구성하기
 [ ] 이메일, 비밀번호 유효성 검사 실시하기
 [ ]
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

        // UserDefaults Location
        let userLocation: String = CoreLocationManager().getCachedUserLocation(key: "deselectedUserLocation")?.name ?? ""
        Auth.auth().createUser(withEmail: email, password: pw) { [weak self] result, error in


            guard let result = result else {
                return
            }

            // firebase 스토어에 데이터 추가
            let database = Firestore.firestore()
            database.collection("users").document(email).setData(["email" : email, "name" : email, "location" : userLocation])
        }
    }
}
