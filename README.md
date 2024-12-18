# 프로젝트 계획서

### 프로젝트 명:

- Book위키

## 제안 배경

현대 사회에서 독서는 지식 습득과 자기 계발의 중요한 수단으로 자리 잡고 있습니다. 그러나 바쁜 일상 속에서 적합한 도서를 찾거나, 독서 후 기록을 남기는 활동이 번거롭다고 느끼는 사용자들이 많습니다. 특히, 도서를 검색하고 관리하는 플랫폼들이 분산되어 있어 사용자들이 일관된 경험을 누리기 어렵다는 점이 문제로 지적되고 있습니다.

또한, 디지털 콘텐츠 소비가 증가함에 따라 유튜브 등의 플랫폼에서 책과 관련된 영상 리뷰를 참고하는 사용자들이 늘어나고 있습니다. 하지만 이를 도서 관리 앱과 통합적으로 제공하는 서비스는 드물어 사용자들이 일일이 플랫폼을 오가는 불편함을 겪고 있습니다.

## 유사제품 현황 및 비교

**1. 북트리(Booktree)**

- **도서 관리 및 통계 제공**: 북트리는 사용자가 읽은 책, 읽고자 하는 책을 손쉽게 관리할 수 있는 기능을 제공합니다. 독서 통계를 통해 월별, 연도별 목표 달성 현황을 확인할 수 있어 독서 습관 형성에 도움을 줍니다.
- **독서 기록 및 공유**: 독서 달력을 통해 읽은 책을 시각적으로 확인할 수 있으며, 독서 노트를 작성하고 이를 소셜 미디어에 공유할 수 있어 다른 사용자와의 소통이 가능합니다.
- **플랫폼 제한 및 비용**: 북트리는 iOS에서 유료로 제공되어 안드로이드 사용자에게는 접근이 어렵다는 제한점이 있지만, 체계적인 독서 관리를 원하는 사용자들에게 유용합니다.

**2. 북플립(BookFlib)**

- **간편한 도서 추가 및 관리**: 바코드 스캔과 검색 기능을 통해 도서를 추가할 수 있으며, "읽기 전", "읽는 중", "다 읽음" 상태로 분류하여 독서 활동을 체계적으로 관리할 수 있습니다.
- **독서 통계 및 메모 작성**: 독서 패턴을 분석할 수 있는 통계 기능과 도서별 서평 작성 기능을 제공하며, 이를 통해 독서 경험을 기록하고 관리할 수 있습니다.
- **무료 제공 및 광고 포함**: 북플립은 안드로이드에서 무료로 제공되지만, 광고가 포함되어 있어 사용자 경험에 다소 영향을 줄 수 있습니다.

## 주요 기능

1. **도서 검색 및 추천**
    - Kakao API를 활용하여 사용자가 원하는 도서를 검색할 수 있으며, 검색된 도서와 관련된 추천 도서를 제공.
    - 도서 정보 페이지에는 좋아요 버튼을 추가하여 다른 사용자들에게 추천할 수 있는 기능 제공.
    - 검색 결과는 리스트뷰를 통해 책 표지, 제목, 저자 등의 정보를 직관적으로 표시.
2. **사용자 계정별 프로필 및 도서 관리**
    - Firebase Authentication을 통해 이메일과 비밀번호 기반의 회원가입, 로그인, 로그아웃 기능을 구현하여 사용자 계정을 안전하게 관리.
    - 사용자별로 선호 도서를 북마크로 추가하거나 삭제할 수 있는 기능 제공.
    - 북마크된 도서에는 "읽기 전", "읽는 중", "다 읽음" 상태를 설정할 수 있는 버튼 추가.
    - Firebase Storage를 활용하여 사용자 프로필 사진을 등록하고 변경할 수 있는 기능 제공.
3. **독후감 게시판 기능**
    - 사용자가 "다 읽음" 상태로 설정한 도서에 대해 독후감을 작성하고 게시할 수 있는 게시판 기능 구현.
    - 독후감 게시물에는 다른 사용자가 "추천" 버튼을 눌러 공감을 표현할 수 있는 기능 제공.
    - 독후감 목록은 리스트뷰로 표시하며, 개별 게시물을 클릭하면 상세 내용을 확인할 수 있음.
4. **책 리뷰 동영상 보기**
    - Youtube API를 활용하여 특정 도서와 관련된 영상 리뷰를 검색하고 제공.
    - 검색 결과는 리스트뷰로 표시하며, 사용자가 선택한 동영상을 앱 내에서 바로 재생할 수 있도록 구현.
5. **탭뷰를 통한 기능 전환**
    - 앱의 주요 기능(도서 검색, 독후감 게시판, 책 리뷰 동영상, 사용자 프로필)을 탭뷰로 구성하여 사용자가 직관적이고 유연하게 기능을 전환할 수 있도록 설계.
    - 각 탭에서 상태 관리 위젯을 활용하여 동적이고 안정적인 화면 전환 제공.

## 기대효과

- **사용자 중심의 도서 관리**: 사용자가 선호하는 도서를 검색하고 관리하는 과정을 효율적으로 지원할 필요가 있습니다. 북마크, 상태 관리, 독후감 작성 등 사용자 맞춤형 기능은 개인의 독서 경험을 풍부하게 만듭니다.
- **플랫폼 통합의 필요성**: 도서 검색, 유튜브 리뷰, 독후감 작성 등의 기능을 한 곳에서 제공함으로써 사용자 경험을 향상시킬 수 있습니다.
- **교육적/사회적 가치 창출**: 책을 읽고 독후감을 공유하며 다른 사용자들과 교류할 수 있는 공간을 제공함으로써 독서 문화를 활성화하고 지식 공유를 촉진할 수 있습니다.
- **실질적인 기술 학습 기회**: Firebase, Kakao API, Youtube API 등 다양한 기술을 활용하여 실제 구현 가능한 프로젝트를 통해 학습 성과를 강화할 수 있습니다. 이는 개발자 포트폴리오로서도 높은 가치를 가질 것입니다.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   b o o k - w i k i _ 2 0 2 4 0 0 1 7 6 1 
 
 