//
//  SettingViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {

    // MARK: - Components

    // tableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()

    // section
    private var sections = [Section]()

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Setting"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Layout Settings
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    // MARK: - Setting Section
    private func configureModels() {
        sections.append(Section(title: "Profile", option: [Option(title: "View Your Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
        })]))

        // Section 2
        sections.append(Section(title: "Account", option: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
        })]))
    }

    // MARK: - Actions

    // viewProfile
    private func viewProfile() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    // signOut
    private func signOutTapped() {
        let alert = UIAlertController(title: "로그아웃",
                                      message: "정말 로그아웃 하시겠습니까?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "아니오",
                                      style: .cancel))

        alert.addAction(UIAlertAction(title: "네",
                                      style: .destructive, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut() // 파베에서 로그아웃
                self.removeUserCredentialsFromKeychain() // 키체인에서도 삭제하기 -> keychain이 비어있으니까, rootView가 startPage로 바뀌지 않나?
                DispatchQueue.main.async {
                    let navVC = UINavigationController(rootViewController: StartPageViewController())
                    navVC.modalPresentationStyle = .fullScreen

                    self.present(navVC, animated: true) {
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            } catch let signOutError as NSError {
                print("로그아웃이 잘 되질 않았네요 : \(signOutError)")
            }
        }))
        present(alert, animated: true)
    }

    private func removeUserCredentialsFromKeychain() {
        SensitiveInfoManager.delete(key: "userEmail")
        SensitiveInfoManager.delete(key: "userPassword")
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {

    // num of tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    // number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].option.count
    }

    // cell Return
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let model = sections[indexPath.section].option[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }

    // selected Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)

        let model = sections[indexPath.section].option[indexPath.row]
        model.handler()
    }

    // header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
}


import Foundation

// default form of the section
struct Section {
    let title: String
    let option: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
