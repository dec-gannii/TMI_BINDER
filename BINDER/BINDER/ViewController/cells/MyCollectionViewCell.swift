//
//  MyCollectionViewCell.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/15.
//

import UIKit
import SnapKit
import RxSwift

class MyCollectionViewCell: UICollectionViewCell {
    
    static var id: String { NSStringFromClass(Self.self).components(separatedBy: ".").last ?? "" }
    var bag = DisposeBag()
    
    var model: MyCollectionViewModel? { didSet { bind() } }
    
    lazy var contentsView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "tabBarWhite")
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .gray4
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configure()
    }
    
    override var isSelected: Bool {
        didSet {
            contentsView.image = isSelected ? UIImage(named: "tabBarColor") : UIImage(named: "tabBarWhite")
            titleLabel.textColor = isSelected ? .blue : .gray4
            titleLabel.font = isSelected ? UIFont.systemFont(ofSize: 14.0, weight: .bold) : UIFont.systemFont(ofSize: 14.0, weight: .medium)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addSubviews() {
        addSubview(contentsView)
        contentsView.addSubview(titleLabel)
    }
    
    private func configure() {
        backgroundColor = .white
        
        contentsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(30)
            make.right.equalToSuperview().inset(27)
        }
    }
    
    private func bind() {
        titleLabel.text = model?.title ?? ""
    }
}
