//
//  SettingViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/21.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {

    private let userdefaultStorage = UserDefaultStorage<UserInfo>()

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
        let viewController = ProfileViewController()
        viewController.title = "Profile"
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
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
                try firebaseAuth.signOut()
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
            } catch let signOutError as NSError {
                print("로그아웃이 잘 되질 않았네요 : \(signOutError)")
            }
        }))
        present(alert, animated: true)
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
