# dangle(댕글) ![30x30](https://github.com/onthelots/Dangle/assets/107039500/4e289239-10f5-40cf-8e2f-2fdefdb681f2)

> 다양한 우리 동네소식을 통해 이웃과 지역사회가 함께 소통하며 소식을 나누는 플랫폼을 구상합니다.

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
`Title`
- descripiton

### 1-2 주요목표
`Title`
- descripiton

### 1-3 개발환경
- 활용기술 외 키워드
  - iOS : 
  - Network: 
  - UI : 
  - Layout : 
- 라이브러리
  - 
 
### 1-4 구동방법
- 🗣️ 반드시 아래 절차에 따라 구동해주시길 바랍니다. 

순서  | 내용  | 비고
----- | ----- | -----
1 | descripiton | descripiton
2 | descripiton | descripiton
3 | descripiton | descripiton
4 | descripiton | descripiton

<br>

## 2-Architecture
### 2-1 구조도

`Title`
- descripiton

`Title`
- descripiton

### 2-2 파일 디렉토리
```
InSight
 ┣ 📂
 ┣ 📂
 ┣ 📂
```

<br>

## 3-프로젝트 특징
### SubTitle
- description
- App Image
|:-:|:-:|:-:|
|`scene`|`scene`|`scene`|

<br>

## 4-프로젝트 세부과정
### 4-1 [Feature 1] 어떤 앱을 만들 것인가? (+ UI Design, Prototype)

> 앱 컨셉 설정과 App Prototyping  
- 앱 컨셉 설정 사용자의 일상, 그리고 주변의 다양한 이슈와 이벤트를 제공하는 `하이퍼 로컬 뉴스 앱`을 목표로 설정
- 본격적인 앱을 구현하기에 앞서, `사용자 친화적인 UX`를 제공하기 위해 Figma를 통한 프로토타입 생성
- 디자인-개발-수정 단계를 반복적으로 수행함으로서 `애자일 개발방식` 실천

<br>

### 4-2 [Feature 2] 사용자 위치정보 업데이트 (CLLocation, Reverse Geocoding)
> 위치정보 인증부터 좌표를 활용한 행정동 단위로의 변환 실시, 위치 검색을 통한 위치 직접 설정 허용
- 사용자 위치정보 `허용/비허용` 과정에 대한 분기처리 실시(ToggleView)
- CLLocation을 통해 `Coordinate`를 1차로 받아오고, `Reverse Geocoding`을 2차로 수행함으로서 행정동 단위로 위치를 나타냄

🚫 Trouble Shooting

순서  | 내용  | 비고
----| ----- | -----
1| 디바이스 위치서비스 활성/비활성화 확인 메서드 실행에 따른 UI 불응성(unresponsiveness)문제 | https://github.com/onthelots/dangle/issues/8



<br>

## 5-업데이트 및 리팩토링 사항
### 5-1 우선 순위별 개선항목
1) Issue
- [] 
  
<br>
