//
//  binder
//
//  Created by 하유림 on 2021/11/26.
//

/// Delegate는 진행되는 과정이 잘 마무리 되었는지 확인
protocol AddStudentDelegate: AnyObject {
    func onSuccess()
}
