//
//  NewIssueDetailView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit
import Kingfisher
import WebKit

protocol NewIssueDetailViewDelegate: AnyObject {
    func didTapExternalLink(url: URL)
    func didTapFileLink(url: URL)
}

class NewIssueDetailView: UIView, WKNavigationDelegate {

    weak var delegate: NewIssueDetailViewDelegate?

    private var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark
    }

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
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = isDarkMode ? .black : .white
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                // 화면 스타일이 변경되었으므로 WebView 리로드
                updateWebViewStyle()
            }
        }
    }

    // WKWebView 스타일 업데이트
    func updateWebViewStyle() {
        // 현재 스타일을 확인하여 isDarkMode를 설정
        let isDarkMode = traitCollection.userInterfaceStyle == .dark

        // WKWebView의 스타일을 업데이트하고 다시 로드
        webView.backgroundColor = isDarkMode ? .black : .white
        webView.reload()
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
                                                                      with: "style=\"width: \(Int(screenWidth - 20))px; height: auto;\" src=\"\(imageURLString)\"")
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
                    color: \(isDarkMode ? "white" : "black"); /* 텍스트 색상을 반전시킵니다. */
                    background-color: \(isDarkMode ? "black" : "white"); /* 배경 색상을 반전시킵니다. */
                }
                table {
                    font-size: 30px; /* 표의 폰트 크기를 조절합니다. */
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let jsCode = """
        var images = document.getElementsByTagName('img');
        var deviceWidth = \(UIScreen.main.bounds.width);
        for (var i = 0; i < images.length; i++) {
          images[i].style.display = 'block';
          images[i].style.margin = '0 auto';
        }
        """
        webView.evaluateJavaScript(jsCode, completionHandler: { _, _ in
            let darkModeCSS = """
            <style>
                body {
                    background-color: black; /* 다크 모드 배경색 */
                    color: white; /* 다크 모드 텍스트 색상 */
                }
            </style>
            """
            webView.evaluateJavaScript(darkModeCSS, completionHandler: nil)
        })
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        print("링크 URL: \(url)")
        if navigationAction.navigationType == .linkActivated, !url.isFileURL {
            delegate?.didTapExternalLink(url: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
