//
//  MyClassDetailViewController.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/15.
//

import UIKit
import RxGesture
import RxSwift
import RxCocoa
import Firebase
import FSCalendar
import Charts
import BLTNBoard

public class MyClassDetailViewController: UIViewController {
    
    var userEmail: String!
    var userSubject: String!
    var userName: String!
    var userType: String!
    var currentCnt: Int!
    var days: [String]!
    var scores: [Double]!
    var floatValue: [CGFloat]!
    var barColors = [UIColor]()
    var count: Int!
    var todos = Array<String>()
    var todoCheck = Array<Bool>()
    var todoDoc = Array<String>()
    var bRec: Bool!
    var date: String!
    var selectedMonth: String!
    var userIndex: Int!
    var keyHeight: CGFloat?
    var checkTime: Bool!
    var dateStrWithoutDays: String!
    var teacherUid: String!
    var studentName: String!
    var studentEmail: String!
    var studentSubject: String!
    var payType: String!
    var viewDesign = ViewDesign()
    var calenderDesign = CalendarDesign()
    var chartDesign = ChartDesign()
    var btnDesign = ButtonDesign()
    var detailClassDB = DetailClassDBFunctions()
    
    func _init(){
        userEmail = ""
        userSubject = ""
        userName = ""
        userType = ""
        currentCnt = 0
        days = []
        scores = []
        floatValue = [5,5]
        barColors = []
        count = 0
        todos = []
        todoCheck = []
        todoDoc = []
        bRec = false
        date = ""
        selectedMonth = ""
        userIndex = 0
        keyHeight = 0.0
        checkTime = false
        dateStrWithoutDays = ""
        teacherUid = ""
        studentName = ""
        studentEmail = ""
        payType = ""
    }
    
    @IBOutlet weak var collectionViewBG: UIView!
    @IBOutlet weak var classNavigationBar: UINavigationBar!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBAction func goBack(_ sender: Any) {
        if let preVC = self.presentingViewController {
            preVC.dismiss(animated: true, completion: nil)
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            bind(oldValue: oldValue, newValue: currentPage)
        }
    }

    var dataSource: [MyCollectionViewModel] = []
    var dataSourceVC: [UIViewController] = []

    lazy var collectionView: UICollectionView = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal

        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .white

        return view
    }()

    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        return vc
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.userType == "student" {
            navigationBarItem.rightBarButtonItems?.removeAll()
        } 
        
        // 빈 배열 형성
        days = []
        scores = []
        
        // 받은 이메일이 nil이 아니라면
        if let email = self.userEmail {
            var studentEmail = ""
            if (self.userType == "student") { // 현재 로그인한 사용자가 학생이라면 현재 사용자의 이메일 받아오기
                studentEmail = (Auth.auth().currentUser?.email)!
            } else { // 아니라면 전 view controller에서 받아온 이메일로 설정
                studentEmail = email
            }
        }
        
        detailClassDB.GetUserInfoInDetailClassVC(self: self, detailClassVC: nil, graphVC: nil, todolistVC: nil)
        
        setupDataSource()

        setupViewControllers()

        addSubviews()

        configure()

        setupDelegate()

        registerCell()

        setViewControllersInPageVC()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        currentPage = 0
    }

    private func setupDataSource() {
        var titles = Array<String>()
        titles = []
        titles = ["진도 및 평가", "성적 그래프", "숙제 리스트"]
        
        for i in 0...2 {
            let model = MyCollectionViewModel(title: titles[i])
            dataSource += [model]
        }
    }

    private func setupViewControllers() {
        let viewController1 = storyboard!.instantiateViewController(identifier: "DetailClassViewController")
        let viewController2 = storyboard!.instantiateViewController(identifier: "GraphViewController")
        let viewController3 = storyboard!.instantiateViewController(identifier: "ToDoListViewController")
        
        detailClassDB.GetUserInfoInDetailClassVC(self: self, detailClassVC: viewController1 as! DetailClassViewController, graphVC: viewController2 as! GraphViewController, todolistVC: viewController3 as! ToDoListViewController)
    }

    private func addSubviews() {
        collectionViewBG.addSubview(collectionView)
        addChild(pageViewController)
        collectionViewBG.addSubview(pageViewController.view)
    }

    private func configure() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(collectionViewBG.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        pageViewController.didMove(toParent: self)
    }

    private func setupDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self

        pageViewController.delegate = self
        pageViewController.dataSource = self
    }

    private func registerCell() {
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.id)
    }

    private func setViewControllersInPageVC() {
        if let firstVC = dataSourceVC.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }

    private func bind(oldValue: Int, newValue: Int) {
        // collectionView 에서 선택한 경우
        let direction: UIPageViewController.NavigationDirection = oldValue < newValue ? .forward : .reverse
        pageViewController.setViewControllers([dataSourceVC[currentPage]], direction: direction, animated: true, completion: nil)

        // pageViewController에서 paging한 경우
        collectionView.selectItem(at: IndexPath(item: currentPage, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }

    func didTapCell(at indexPath: IndexPath) {
        currentPage = indexPath.item
    }
    
    /// more button (edit or delete class info) clicked
    @IBAction func editBtnAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: "수정 및 삭제", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default, handler: { action in
            guard let editClassVC = self.storyboard?.instantiateViewController(withIdentifier: "EditClassViewController") as? EditClassVC else { return }
            
            editClassVC.modalTransitionStyle = .crossDissolve
            editClassVC.modalPresentationStyle = .fullScreen
            
            // 값 보내주는 역할
            editClassVC.userName = self.userName
            editClassVC.userEmail = self.userEmail
            editClassVC.userSubject = self.userSubject
            
            self.present(editClassVC, animated: true, completion: nil)
        })
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { action in
            self.detailClassDB.DeleteClass(self: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension MyClassDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.id, for: indexPath)
        if let cell = cell as? MyCollectionViewCell {
            cell.model = dataSource[indexPath.item]

            cell.contentsView.rx.tapGesture(configuration: .none)
                .when(.recognized)
                .asDriver { _ in .never() }
                .drive(onNext: { [weak self] _ in
                    self?.didTapCell(at: indexPath)
                }).disposed(by: cell.bag)

        }
        return cell
    }
}

extension MyClassDetailViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3 , height: collectionView.frame.height)
    }
}

extension MyClassDetailViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = dataSourceVC.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return dataSourceVC[previousIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = dataSourceVC.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == dataSourceVC.count {
            return nil
        }
        return dataSourceVC[nextIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentVC = pageViewController.viewControllers?.first,
              let currentIndex = dataSourceVC.firstIndex(of: currentVC) else { return }
        currentPage = currentIndex
    }
}
