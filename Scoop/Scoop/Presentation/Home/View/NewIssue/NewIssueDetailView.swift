//
//  NewIssueDetailView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Kingfisher
import WebKit

class NewIssueDetailView: UIView, WKNavigationDelegate {

    // MARK: - Components
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .label
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var manageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var manageDept: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dotLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "•"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var manageName: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var publishDate: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var modifyDate: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let seperatedLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.navigationDelegate = self // WKNavigationDelegate 설정
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        manageStackView.addArrangedSubview(manageDept)
        manageStackView.addArrangedSubview(dotLabel)
        manageStackView.addArrangedSubview(manageName)
        dateStackView.addArrangedSubview(publishDate)
        dateStackView.addArrangedSubview(modifyDate)
        addSubview(titleLabel)
        addSubview(manageStackView)
        addSubview(dateStackView)
        addSubview(seperatedLineView)
        addSubview(webView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            manageStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            manageStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            dateStackView.topAnchor.constraint(equalTo: manageStackView.bottomAnchor, constant: 10),
            dateStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            seperatedLineView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 15),
            seperatedLineView.heightAnchor.constraint(equalToConstant: 3),
            seperatedLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            seperatedLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: seperatedLineView.bottomAnchor, constant: 15),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10)
        ])
    }

    func configure(newIssueDTO: NewIssueDTO) {
        self.titleLabel.text = newIssueDTO.title
        self.manageDept.text = newIssueDTO.managerDept
        self.manageName.text = newIssueDTO.managerName
        self.publishDate.text = "입력 \(newIssueDTO.publishDate)"
        self.modifyDate.text = "수정 \(newIssueDTO.modifyDate)"
        let resizedHTML = resizeImagesToFitScreenWidth(in: newIssueDTO.postContent)
        let styledHTML = applyCustomCSS(to: resizedHTML)

         self.webView.loadHTMLString(styledHTML, baseURL: nil)
    }

    private func resizeImagesToFitScreenWidth(in htmlString: String) -> String {
        var updatedHTML = htmlString
        let screenWidth = UIScreen.main.bounds.width
        let imageRegex = "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>"
        let regex = try? NSRegularExpression(pattern: imageRegex, options: .caseInsensitive)

        if let matches = regex?.matches(in: htmlString, options: [], range: NSRange(htmlString.startIndex..., in: htmlString)) {
            for match in matches {
                let imgTag = String(htmlString[Range(match.range, in: htmlString)!])
                if let imageURLRange = imgTag.range(of: "src=\"([^\"]+)", options: .regularExpression) {
                    let imageURLString = String(imgTag[imageURLRange])
                    let resizedImageTag = imgTag.replacingOccurrences(of: "src=\"\(imageURLString)",
                                                                      with: "style=\"max-width: \(Int(screenWidth - 20))px; height: auto;\" src=\"\(imageURLString)\"")
                    updatedHTML = updatedHTML.replacingOccurrences(of: imgTag, with: resizedImageTag)
                }
            }
        }

        return updatedHTML
        }

        private func applyCustomCSS(to htmlString: String) -> String {
            let cssStyle = """
            <style>
                body {
                    font-size: 30px; /* 전체 텍스트 폰트 크기를 조절합니다. */
                }
                table {
                    font-size: 20px; /* 표의 폰트 크기를 조절합니다. */
                    width: 100%; /* 표의 너비를 화면 너비에 맞게 조정합니다. */
                    border-collapse: collapse; /* 표 내의 테두리를 합칩니다. */
                }
                th, td {
                    border: 1px solid #000; /* 표의 테두리 스타일을 설정합니다. */
                    padding: 8px; /* 셀의 여백을 조절합니다. */
                }
                /* 다른 원하는 스타일을 추가할 수 있습니다. */
            </style>
            """
            return cssStyle + htmlString
        }

}
