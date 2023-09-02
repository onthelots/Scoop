//
//  WriteReviewViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Firebase
import UIKit

class WriteReviewViewController: UIViewController {

    let category: String
    let textViewPlaceHolder = "텍스트를 입력하세요"
    private varvar viewModel: WriteReviewViewModel!

    // Warning View
    private lazy var warningView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tintColor
        return view
    }()

    // Label
    // 운영정책 확인 + 경고뷰

    // Title TextField
    private lazy var reviewTextView: UITextView = {
        // Create a TextView.
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.text = textViewPlaceHolder
        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        textView.textColor = .lightGray
        textView.textAlignment = NSTextAlignment.left
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
    }()

    // 사진, 장소 -> 아래 StackView (키보드에 붙어있지 않음 -> 아래애 엤다가, 키보드를 올리면 같이 올라감)
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(locationButtonView)
        stackView.addArrangedSubview(pictureButtonView)
        return stackView
    }()

    // place
    private lazy var locationButtonView: UIButton = {
        let buttonView = UIButton()
        buttonView.setTitle("장소", for: .normal)
        buttonView.setImage(UIImage(systemName: "location.square"), for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.tintColor = .black
        return buttonView
    }()

    // picture
    private lazy var pictureButtonView: UIButton = {
        let buttonView = UIButton()
        buttonView.setTitle("사진", for: .normal)
        buttonView.setImage(UIImage(systemName: "photo"), for: .normal)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.tintColor = .black
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
//        initalizerViewModel()
        setupUI()
    }

//    private func initalizerViewModel() {
//        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository())
//        viewModel = WriteReviewViewModel(postUseCase: postUseCase)
//    }

    // Bind를 통해, 저장된 데이터 전달하기
//    private func bind() {
//        viewModel.postButtonTapped
//    }

    private func setupUI() {
        view.addSubview(warningView)
        view.addSubview(reviewTextView)
        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            warningView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            warningView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            warningView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            warningView.heightAnchor.constraint(equalTo: warningView.widthAnchor, multiplier: 0.3),

            reviewTextView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: 10),
            reviewTextView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            reviewTextView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            reviewTextView.heightAnchor.constraint(equalToConstant: 300),

            buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: reviewTextView.bottomAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            buttonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).withPriority(.defaultLow)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func didTapTextView(_ sender: Any) {
        view.endEditing(true)
    }

    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WriteReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // text의 띄어쓰기를 제외하고 나서도 비어있다면?
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // placeHolder로 설정
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}
