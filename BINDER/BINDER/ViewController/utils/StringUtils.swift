//
//  StringUtils.swift
//  BINDER
//
//  Created by 김가은 on 2022/04/05.
//

enum StringUtils: String {
    case emailValidationAlert = "유효하지 않은 이메일입니다."
    case emailExistAlert = "이미 존재하는 이메일입니다."
    case nameValidationAlert = "유효하지 않은 이름입니다."
    case nameBlankAlert = "이름을 입력하지 않았습니다."
    case passwordValidationAlert = "유효하지 않은 비밀번호입니다."
    case wrongPassword = "비밀번호가 올바르지 않습니다."
    case wrongpPasswrod = "학부모 비밀번호가 올바르지 않습니다."
    case passwordBlankAlert = "비밀번호를 입력하지 않았습니다."
    case phoneNumAlert = "올바른 전화번호가 아닙니다."
    case tEmailNotMatch = "선생님 이메일과 비밀번호가 일치하지 않습니다."
    case tEmailNotExist = "존재하지 않는 선생님 이메일입니다."
    case ageValidationAlert = "유효하지 않은 나이입니다."
    case contentNotExist = "등록된 내용이 없습니다."
    case loginFail = "로그인에 실패하였습니다. 다시 시도해주세요."
    case galleryAccessFail = "어플리케이션이 갤러리에 접근 불가능합니다."
    case progressText = "입력한 진도사항은 학생과 학부모에게 공유됩니다! (150자 이내로 작성해주세요.)"
    case monthlyEvaluation = "한달에 한번 있는 월말 평가를 등록해주세요!"
    case eduHistoryPlaceHolder = "OO대학교 OO학과 OO학번 (졸업 / 재학)" // 학력 사항
    case classMethodPlaceHolder = "어떻게 수업하시나요?" // 수업 방식
    case extraExperiencePlaceHolder = "베테랑이든 초보든 바인더와 함께하면 프로 과외쌤!" // 과외 경력
    case timePlaceHolder = "주로 수업하는 시간대가 언제인가요?" // 수업 시간
    case contactPlaceHolder = "이메일이나 전화번호 등 연락 수단 정보를 입력해주세요! 필수는 아니에요!" // 연락 수단
    case managePlaceHolder = "학생들을 관리하시는 선생님만의 방법은 무엇이 있나요?" // 학생 관리 방법
    case memoPlaceHolder = "학부모님과 학생을 위한 한마디를 적어주세요!" // 학생 관리 방법
}
