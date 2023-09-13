//
//  TermsViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//

import Foundation
import Combine

class TermsViewModel: ObservableObject {

    // MARK: - 퍼블리셔 : 변화를 감지고, UI를 업데이트 함
    @Published var terms: [TermsType] = TermsType.allCases

    // Output : Push VC
    let itemTapped = PassthroughSubject<TermsType, Never>()

    // MARK: - isAllSelected (bool) : 모두 선택되었을 때만 true를 반환하며, 하나라도 false일 경우엔 false를 반환함
    var isAllSelected: Bool {
        // 여기서, terms 배열의 isChecked요소가 모두 true인지 확인하는 과정임
        return terms.allSatisfy { $0.isChecked }
    }

    // MARK: - 모든 약관의 선택 상태를 한번에 번경하는 역할
    // 즉, 해당 함수가 실행되는 곳에서 매개변수(isSelected)가 false 혹은 true일 경우, terms의 isChecked의 속성을 모두 변경함 -> set 블록이 호출되어, UserDefaults의 값이 변경됨
    func toggleAllTerms(isSelected: Bool) {
        terms.indices.forEach { index in
            terms[index].isChecked = isSelected
        }
    }

    // MARK: - 해당 체크박스 index를 확인하고, isChecked 상태를 토글함
    func toggleTerm(for termType: TermsType) {
        if let index = terms.firstIndex(of: termType) {
            terms[index].isChecked.toggle()
        }
    }

    // MARK: - isAllSelected의 상태를 확인하고, NextButton의 bool 값을 반환함
    // 만약, 모두 선택되지 않았을 땐 false이므로, 활성화 되지 않고, true일때만 활성화 되도록 함
    func updateNextButtonState() -> Bool {
        return isAllSelected
    }

    // MARK: - 디버깅 (해당 약관의 isChecked 상태 확인)
    func printDebugInfo() {
        terms.forEach { term in
            print("약관 : \(term)의 상태는? : \(term.isChecked)")
        }
    }
}
