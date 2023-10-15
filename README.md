# Scoop ![29](https://github.com/onthelots/Scoop/assets/107039500/7d014abd-8c50-4a64-90ec-8e068ba7a5f6)
> 내가 살고 있는 서울, 그리고 동네를 더욱 풍부하게 경험할 수 있도록, [Scoop]을 통해 다양한 맛을 즐겨보세요.

#### <a href="https://www.notion.so/onthelots/32eb5fa184c14426a4f32b654f76ec0e?v=96817719164f49e398abae2bc4c8565c&pvs=4"><img src="https://img.shields.io/badge/Notion-000000?style=flat&logo=Notion&logoColor=white"/></a> <a href="https://apps.apple.com/kr/app/scoop/id6466811453"><img src="https://img.shields.io/badge/AppStore-000000?style=flat&logo=AppStore&logoColor=white"/></a>

![sss](https://github.com/onthelots/Scoop/assets/107039500/9e584b46-9a18-401c-bf93-244501be0115)


<br> 

# 목차

[1-프로젝트 소개](#1-프로젝트-소개)

- [1-1 개요](#1-1-개요)
- [1-2 주요목표](#1-2-주요목표)
- [1-3 개발환경](#1-3-개발환경)
- [1-4 구동방법](#1-4-구동방법)

[2-Architecture](#2-architecture)
- [2-1 구조도](#2-1-구조도)
- [2-2 파일 디렉토리](#2-2-파일-디렉토리)

[3-프로젝트 특징](#3-프로젝트-특징)

[4-프로젝트 세부과정](#4-프로젝트-세부과정)

[5-업데이트 및 리팩토링 사항](#5-업데이트-및-리팩토링-사항)


--- 

## 1-프로젝트 소개

### 1-1 개요
`서울, 그리고 우리동네 소식 맛보기`
- **개발기간** : 2023.08.01 ~ 2023.09.15 (약 6주)
- **참여인원** : 1인 (개인 프로젝트)
- **주요내용**
  - 서울 시민들에게 유용한 교통, 안전, 주택, 경제 등 분야별 정보 제공. 현재 살고있는 지역구에서 진행하는 공공 행사나 교육 등 이벤트 참여
  - 사용자의 동네를 기반으로 이웃이 작성한 음식점, 카페, 병원 등 카테고리 별 리뷰를 확인하고, 작성하고 관리

<br>

### 1-2 주요목표
`클린 아키텍쳐 및 MVVM 패턴 활용`
- 서버 파싱과 UITable, UICollection, MKMap 등 다양한 컴포넌트와 기능 구현에 따라 유연하고 가독성 있는 앱 플로우를 위한 MVVM 패턴 적용
- UseCase를 기능별로 구분하여 구성, Massive ViewModel의 문제를 해결하고 유지보수 하기 좋은 코드를 작성하고자 함
- Combine 프레임워크를 활용한 동시성 프로그래밍 구현

`서울시 API, Kakao 개발자 API 활용`
- 서울시 OPEN API를 파싱하여 관련된 데이터를 실시간(혹은 주기별)로 제공, RESTFul API 구현
- 주소 관련 로직 구현을 위하여 Geocoding, Reverse Geocoding API 활용 (SDK 미 활용)

`사용자 계정관리를 위한 이메일 형식의 Firebase 로그인/회원가입`
- 회원가입을 통한 유저 위치정보, 닉네임 등 개인정보 저장 및 활용
- 특정 장소에 대한 리뷰 작성을 위한 카테고리 별 데이터 구조 구현

<br>

### 1-3 개발환경
- **활용기술 외 키워드**
  - iOS : swift 5.8, xcode 14.3.1, UIKit
  - Network: URLSession
  - UI : UIScrollView, UITableView, UICollectionView(Diffable DataSource), UITabbar, MKMapView 등
  - Layout : AutoLayout(Code-base), Compositional Layout

- **라이브러리**
   - KingFisher (7.0.0)
   - SwiftSoup (2.0.0)
   - Firebase (10.0.0)
   - Swiftlint

<br>
 
### 1-4 구동방법
- 앱의 특성상, 반드시 [서울특별시] 내 주소(법정동)로 위치를 설정해야 합니다.
- 서울 이외 지역에 거주하실 경우, 위치서비스 권한 설정 시 `비 허용`으로 설정한 후 주소 검색을 통해 임의 지역(법정동)을 선택해주세요.
- 아래 2가지 과정이 모두 필요합니다. 도움이 필요하실 경우 아래 남긴 이메일로 연락바랍니다.
- 1️⃣ ScoopInfo.plist API-KEY 작성 (Value)
  - **KAKAO_API_KEY** : [Kakao Developers](https://developers.kakao.com/console/app/954109) 가입 후, 어플리케이션 등록(임의)후 REST API를 발급, 기입하기
  - **SEOUL_API_KEY** : [서울시 열린 데이터 광장](https://data.seoul.go.kr/index.do) 회원가입 후, 인증키를 발급받아서 기입하기

- 2️⃣ GoogleService-plist 파일
  - 아래 이메일을 통해 파일을 요청해주세요.
  - jhyim1992@gmail.com

<br>

## 2-Architecture
### 2-1 구조도

`Clean Architecture을 통해 보다 체계적이고 규칙적인 개발 도모`
- 사전 앱 아이디어 구상 및 프로토타입 과정에 따라 **최소 10개 이상의 API 파싱 및 클라우딩** 로직이 필요하다고 판단함
- 또한, 다양한 UI 형태와 지도 활용, 사용자 프로필 구현 등 비교적 다수의 기능과 계층이 포함될 것으로 예상함
- 따라서, [클린 아키텍쳐] 패턴을 최대한 적용함으로서 **계층 간 독립과 유지보수**가 용이하도록 유도
<img width="4768" alt="Scoop Architecture" src="https://github.com/onthelots/Scoop/assets/107039500/2d43a2e9-3f2d-43b0-9dc9-5d48c50d89c2">


### 2-2 파일 디렉토리
```
📦Scoop
 ┣ 📂App
 ┣ 📂Data
 ┃ ┣ 📂PersistentStorages
 ┃ ┗ 📂Repositories
 ┣ 📂Domain
 ┃ ┣ 📂Entities
 ┃ ┣ 📂Interface
 ┃ ┃ ┗ 📂Repositories
 ┃ ┃ ┃ ┣ 📂AuthRepository
 ┃ ┃ ┃ ┣ 📂LocalEventRepository
 ┃ ┃ ┃ ┣ 📂PostRepository
 ┃ ┃ ┃ ┣ 📂UserInfoRepository
 ┃ ┃ ┃ ┗ 📂UserLocationRepository
 ┃ ┣ 📂Services
 ┃ ┃ ┣ 📂API
 ┃ ┃ ┗ 📂Validation
 ┃ ┗ 📂UseCases
 ┃ ┃ ┣ 📜GeoLocationUseCase.swift
 ┃ ┃ ┣ 📜LocalEventUseCase.swift
 ┃ ┃ ┣ 📜PostUseCase.swift
 ┃ ┃ ┣ 📜SignInUseCase.swift
 ┃ ┃ ┣ 📜SignUpUseCase.swift
 ┃ ┃ ┗ 📜UserUseCase.swift
 ┣ 📂Infrastructure
 ┃ ┣ 📂CoreLocation
 ┃ ┗ 📂Network
 ┣ 📂Presentation
 ┃ ┣ 📂Authentication
 ┃ ┃ ┣ 📂SignIn
 ┃ ┃ ┣ 📂SignUp
 ┃ ┃ ┃ ┣ 📂RegisterEmail
 ┃ ┃ ┃ ┣ 📂RegisterNickname
 ┃ ┃ ┃ ┣ 📂RegisterPassword
 ┃ ┃ ┃ ┗ 📂RegisterWelcome
 ┃ ┃ ┣ 📂StartPage
 ┃ ┃ ┣ 📂Terms
 ┃ ┃ ┗ 📂UserLocation
 ┃ ┣ 📂Home
 ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┣ 📂Event
 ┃ ┃ ┃ ┣ 📂NewIssue
 ┃ ┃ ┃ ┗ 📜HomeViewController.swift
 ┃ ┃ ┗ 📂ViewModel
 ┃ ┣ 📂Map
 ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┣ 📂Map
 ┃ ┃ ┃ ┃ ┗ 📜MapViewController.swift
 ┃ ┃ ┃ ┣ 📂MapDetail
 ┃ ┃ ┃ ┣ 📂Post
 ┃ ┃ ┃ ┗ 📂Review
 ┃ ┣ 📂Profile
 ┃ ┃ ┣ 📂View
 ┃ ┃ ┃ ┣ 📂EditUserProfile
 ┃ ┃ ┃ ┃ ┗ 📜EditUserProfileViewController.swift
 ┃ ┃ ┃ ┣ 📂MyPost
 ┃ ┃ ┃ ┗ 📂Profile
 ┃ ┃ ┗ 📂ViewModel
 ┃ ┣ 📂TabBar
 ┃ ┃ ┗ 📜TabBarViewController.swift
 ┃ ┗ 📂Utils
 ┃ ┃ ┣ 📂Extensions
 ┃ ┃ ┗ 📂UI
 ┣ 📂Resource
```

<br>

## 3-프로젝트 특징
### 3-1 클라우딩 서비스를 활용한 이메일 로그인 기능 제공 (Auth)
- Firebase Authentication, FireStore Database를 통한 회원가입 및 로그인 기능 구현
- 기존 클라우딩 서버에 있는 유저 데이터 유효성 검사를 통해 이메일, 닉네임 등 중복여부 검사 로직 구축
- 사용자 위치권한(CoreLocation)을 통한 현재 위치(법정동 필터링) 확인, 저장

|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 12](https://github.com/onthelots/Scoop/assets/107039500/09b1e640-61ce-4fcd-af95-8cac824096eb)|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 13](https://github.com/onthelots/Scoop/assets/107039500/4dcb5e9f-672d-4061-b191-9a96738de397)|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 15](https://github.com/onthelots/Scoop/assets/107039500/d20786b3-5a75-4e48-967f-2c439b55902e)|
|:-:|:-:|:-:|
|`시작뷰`|`약관동의`|`비밀번호 입력`|

<br>

### 3-2 서울시 공공데이터 및 자치구 데이터를 활용한 정보전달 (Home Tab)
- 주기적으로 업데이트 되는 분야별(교통, 안전, 주택, 경제, 환경) 서울 소식을 나타냄으로서 서울 시민(사용자)에게 유용한 정보를 전달함
- 현재 사용자의 위치(법정동)를 기반으로 현재 개최되고 있거나, 예정된 문화행사(이벤트)와 교육강좌를 알리고 상세페이지(URL)로 이동할 수 있도록 함

|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 10](https://github.com/onthelots/Scoop/assets/107039500/ccc28967-84f8-4283-a3ab-fcf03c10ca27)|![image](https://github.com/onthelots/Scoop/assets/107039500/011db5a7-f7ae-44d9-b9a0-d8866846790b)|![image](https://github.com/onthelots/Scoop/assets/107039500/7dde1cf4-52d1-4cb9-9856-15a281ddb172)|
|:-:|:-:|:-:|
|`홈뷰`|`분야별 서울소식`|`자치구 행사`|

### 3-3 클라우딩을 통한 Scoop 앱 사용자들이 이용할 수 있는 전용지도 생성, 리뷰기능 구현(Map Tab)
- 설정된 사용자의 위치를 기반으로, 인근 1km내 반경에 있는 리뷰글을 나타내고, 해당 지도의 Annotation을 클릭 시 다른 사용자들이 남긴 이야기(리뷰)를 확인할 수 있음
- 리뷰 작성의 경우, PHPicker를 통해 최대 3개의 사진을 업로드 할 수 있으며, 특정 장소를 직접 검색함으로서 클라우딩 서버를 거쳐 지도에 마커를 생성하여 더욱 직관적으로 확인할 수 있음

|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 56](https://github.com/onthelots/Scoop/assets/107039500/ccfbb815-f481-4a52-99af-1621d2fe3439)|![IMG_400E456601E0-1](https://github.com/onthelots/Scoop/assets/107039500/96b315b0-9dfb-4d0c-a23e-a878b5bd06f0)|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 15 06 49](https://github.com/onthelots/Scoop/assets/107039500/8f17b7fe-69fe-4d79-a10b-a863d7881d61)|
|:-:|:-:|:-:|
|`지도뷰`|`리뷰작성`|`리뷰 확인`|

### 3-4 사용자의 프로필(닉네임 외)과 작성한 리뷰글을 확인하고, 앱 관련된 지원 페이지를 확인 (Profile Tab)
- 회원가입 시 설정한 닉네임을 변경할 수 있으며, 카테고리별로 남긴 리뷰를 확인하고 삭제할 수 있음
- 이용약관 확인, 고객센터, 앱 정보 등 전반적인 앱 이용과 관련된 지원과 로그아웃을 실시할 수 있음

|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 56](https://github.com/onthelots/Scoop/assets/107039500/74324d84-7867-4a59-9b54-765dab4d7735)|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 57](https://github.com/onthelots/Scoop/assets/107039500/3764ef18-0b86-4cfe-8b3c-e68f73d19c78)|![Simulator Screenshot - iPhone 14 Pro - 2023-09-15 at 14 57](https://github.com/onthelots/Scoop/assets/107039500/451b2a48-b78d-4d37-82ba-9eb0e6b534c4)|
|:-:|:-:|:-:|
|`프로필뷰`|`내가 쓴 글`|`앱 페이지`|


<br>

## 4-프로젝트 세부과정
### 4-1 [Feature 1] 어떤 앱을 만들 것인가? (+ UI Design, Prototype)
[프로토타입 링크(Figma)](https://www.figma.com/file/kZjgckc8czM4CzLhEZpibK/Dangle-Design?type=design&node-id=1%3A115&mode=design&t=jfIsB0Y4aNJl82xV-1)
> 앱 컨셉 설정과 App Prototyping  
- 앱 컨셉 설정 사용자의 일상, 그리고 주변의 다양한 이슈와 이벤트를 제공하는 `하이퍼 로컬 뉴스 앱`을 목표로 설정
- 본격적인 앱을 구현하기에 앞서, `사용자 친화적인 UX`를 제공하기 위해 Figma를 통한 프로토타입 생성
- 디자인-개발-수정 단계를 반복적으로 수행함으로서 `애자일 개발방식` 실천
<img width="648" alt="image" src="https://github.com/onthelots/Scoop/assets/107039500/108fbf36-bb04-4c3a-a5c9-2a333884c175">

<br>

--- 

<br>

### 4-2 [Feature 2] 사용자 위치정보 업데이트 (CLLocation, Reverse Geocoding) 및 계정 관리
#### 4-2-1 위치정보 인증부터 좌표를 활용한 행정동 단위로의 변환 실시, 위치 검색을 통한 위치 직접 설정 허용
> [UseCase] : GeoLocation (좌표 » 코드 » 동 단위)
- 사용자 위치서비스 권한을 바탕으로 `Coordinate`를 1차로 받아오고, `Reverse Geocoding`을 2차로 수행함으로서 법정동 단위로 위치를 나타냄
- 또한, 권한 비 허용시 직접 검색을 통해 위치를 설정할 수 있도록 `KAKAO Geocoding API`를 통해 검색 쿼리(주소값)를 저장함

#### 4-2-2 Keychain, UserDefaults, Fiebase를 통한 계정관리 시스템 구축
> [UseCase] : SignUp, SignIn, UserInfo
- `Firebase`를 통하여 계정관리(회원가입, 로그인, 로그아웃) 외 추가 유저정보(위치 등)를 저장하고 활용할 수 있도록 구성함
- 자동 로그인 기능을 구현하기 위해 `UserDefaults`을 통해 email과 password를 안전하게 저장, 활용함 (Scene 분기처리 담당)

<br>

🚫 Trouble Shooting

순서  | 내용  | 비고
----| ----- | -----
1| 디바이스 위치서비스 활성/비활성화 확인 메서드 실행에 따른 UI 불응성(unresponsiveness)문제 | https://github.com/onthelots/dangle/issues/8
2| UITabBarViewController 중첩 문제 | https://github.com/onthelots/dangle/issues/22

<br>

--- 

<br>

### 4-3 [Feature 3] Home, Map, Profile 탭 별 UI 구현 및 데이터 나타내기

#### 4-3-1 Home Tab
> [UseCase] : LocalEvent
- 로그인 한 사용자의 `UID`를 기반으로 서버(FireStore)에서 위치값을 활용, 서울시 공공 API 데이터를 필터링하여 화면에 나타냄
- Paging 기능을 비롯하여 Section 별 상이한 레이아웃을 구성하기 위해, `Compositional Layout`을 활용함
- 각각의 이벤트를 선택 » 세부 정보 뷰를 확인 » 예약 혹은 더욱 자세한 정보를 앱웹으로 확인하기 위해 `SFSafariViewController`를 활용

<br>

#### 4-3-2 Dangle Map Tab
> [UseCase] : Post(+User)
- **사용자의 현재위치와 점포의 위치데이터(CLLocation2D)를 바탕으로 `인근 1km이내 데이터`를 필터링하여 실시간으로 데이터를 파싱함**
    - 위 내용을 토대로, 첫 화면에 진입할 시 보고있는 '카메라(사용자 위치)'를 기준으로 리뷰 데이터를 Cell로 나타냄
    - 지도 위치를 이동할 경우, 중심 위치와 가까운 리뷰가 상위에 나타나고, 멀어질 경우 사라지는 로직을 구현함
 
- **앱 사용자들이 고유하게 활용할 수 있는 지도를 만들고자 의도, 이를 위해 클라우딩 서버 내 위치데이터를 저장**
    - 리뷰를 작성할 시, 직접 사용자가 해당 위치(점포)의 주소를 검색하도록 유도함으로서 `위치데이터를 저장`하고 `Pin을 생성`함
 

🚫 Trouble Shooting

순서  | 내용  | 비고
----| ----- | -----
1| 특정 API를 JSON으로 파싱 시, HTML 형식으로 내려오는 문제 | https://github.com/onthelots/dangle/issues/31
2| 사용자의 현재 위치를 기반으로 인근에 있는 카테고리 별 데이터를 받아오지 못하는 문제 | https://github.com/onthelots/dangle/issues/39

<br>

#### 4-3-3 Profile Tab 
> [UseCase] : User, Post
- 유저의 정보를 받아온 후, updateData 메서드를 활용하여 닉네임을 수정할 수 있도록 함
- 내가 작성한 리뷰 글의 경우, 유저의 고유한 UID를 활용, 클라우드 서버 내 `필드(Field)`검색을 토대로 카테고리 별 유저의 모든 리뷰글을 받아옴 

<br>

## 5-업데이트 및 리팩토링 사항
### 5-1 우선 순위별 개선항목
1) Issue
- [x] 리뷰 글 작성 내 PHPicker를 열어 선택한 후, 재 선택할 시 사진 데이터는 정상적으로 초기화, 저장되지만 View에 나타나지 않는 이슈 발생
- [x] 유저 닉네임 변경 시, 즉각적으로 반영되지 않는 이슈 발생(Publisher 로직 변경 필요)
- [x] 회원 탈퇴시, UserInfo 컬렉션(Firestore) 내 해당 유저의 문서가 삭제되지 않는 이슈
- [ ] Map의 경도, 위도값이 상이하여 비 규칙적인 데이터 파싱문제 발생 

2) UI
- [x] Floatingbutton 로직 및 형태 수정
- [ ] CollectionView Cell의 FooterView로 UIPageControl 할당하기
- [ ] 우리동네 날씨 외 HomeView에서 지역기반 컨텐츠 추가하기

<br>


<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fonthelots%2FScoop&count_bg=%230CC0DF&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>
