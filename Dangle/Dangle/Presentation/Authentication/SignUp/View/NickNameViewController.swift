//
//  NickNameViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//

import UIKit

class NickNameViewController: UIViewController {

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

    lazy var nickNameTf: UITextField = {
        var view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "이메일을 입력해주세요"
        view.borderStyle = .roundedRect
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
}
