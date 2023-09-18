//
//  EventDetailViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import Foundation
import SafariServices

class EventDetailViewModel {

    let eventDetailItem: EventDetailDTO

    // MARK: - Input
    @Published var eventDetailDTO: EventDetailDTO?

    init(eventDetailItem: EventDetailDTO) {
        self.eventDetailItem = eventDetailItem
    }

    func fetch() {
        self.eventDetailDTO = eventDetailItem
    }

    // Safariview 열기
    func openWebPage(from viewController: UIViewController) {
        guard let urlString = eventDetailItem.url,
              let url = URL(string: urlString) else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        viewController.present(safariViewController, animated: true, completion: nil)
    }
}
