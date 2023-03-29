//
//  AddTodoViewController.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/03/28.
//

import UIKit
import RxSwift

class VC: UIViewController {
    lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("이걸 눌러", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(action), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(100)
        }
        self.view.backgroundColor = .white

    }
    
    @objc func action(_ sender: UIButton) {
        let bottomSheetVC = AddTodoViewController()
        // 1
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        // 2
        self.present(bottomSheetVC, animated: false, completion: nil)
        
    }
}

class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "category-cell"
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.sizeToFit()
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = .black
        return label
    }()
    
    lazy var colorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(colorView)
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
    }
    
    func configureLayout() {
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        colorView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(6)
            $0.width.height.equalTo(12)
        }
    }
    
    func fill(name: String, color: UIColor) {
        nameLabel.text = name
        colorView.backgroundColor = color
    }
}

class CategorySelectView: UIView {
    
    var addNewItemButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "addBtn"), for: .normal)
        button.setTitle("새 카테고리 추가", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        button.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 5)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    var headerBarView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var backButton: UIButton = {
        let image = UIImage(named: "pickerLeft") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(UIImage(named: "pickerLeft"), for: .normal)
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 선택"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = UIColor(hex: 0xF5F5FB)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.separatorInset.left = 16
        tableView.separatorInset.right = 16
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)

        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(backButton)
        headerBarView.addSubview(titleLabel)
        self.addSubview(addNewItemButton)
        self.addSubview(tableView)
    }
    
    func configureLayout() {
        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addNewItemButton.snp.remakeConstraints {
            $0.top.equalTo(self.headerBarView.snp.bottom)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(140)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(addNewItemButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    var selectMode = false
    
}

class CategoryCreateViewCell: UICollectionViewCell {
    static let reuseIdentifier = "category-create-view-cell"
    
    let checkImageView: UIImageView = {
        let image = UIImage(named: "categoryCheck")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.checkImageView.isHidden = false
            } else {
                self.checkImageView.isHidden = true
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.checkImageView.isHidden = true
    }
    
    func configureView() {
        self.layer.cornerRadius = 5
        self.layer.cornerCurve = .continuous
        
        self.addSubview(checkImageView)
        
        checkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.checkImageView.isHidden = true
    }
    
    func fill(color: UIColor) {
        self.backgroundColor = color
    }
}

class CategoryCreateView: UIView, UICollectionViewDataSource {
    
    var headerBarView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var backButton: UIButton = {
        let image = UIImage(named: "pickerLeft") ?? UIImage()
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        button.setImage(UIImage(named: "pickerLeft"), for: .normal)
        return button
    }()
    
    var saveButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(UIColor(hex: 0x6495F4), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 선택"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    var nameField: UITextField = {
        let field = UITextField(frame: .zero)
        field.textAlignment = .center
        field.placeholder = "카테고리를 입력하세요"
        field.font = UIFont(name: "Pretendard-Medium", size: 18)
        return field
    }()
    
    var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "카테고리 색상을 선택택하세요"
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(red: 0.749, green: 0.78, blue: 0.843, alpha: 1)
        return label
    }()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCreateViewCell.reuseIdentifier, for: indexPath) as? CategoryCreateViewCell else { return UICollectionViewCell() }
        cell.fill(color: source[indexPath.item].todoLeadingColor)
        return cell
    }
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.register(CategoryCreateViewCell.self, forCellWithReuseIdentifier: CategoryCreateViewCell.reuseIdentifier)
        cv.dataSource = self
        cv.backgroundColor = UIColor(hex: 0xF5F5FB)

        return cv
    }()
    
    var source: [TodoCategoryColor] = Array(TodoCategoryColor.allCases[0..<TodoCategoryColor.allCases.count-1])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(backButton)
        headerBarView.addSubview(titleLabel)
        headerBarView.addSubview(saveButton)
        self.addSubview(nameField)
        self.addSubview(collectionView)
        self.addSubview(descLabel)
    }
    
    func configureLayout() {
        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        nameField.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(264)
            $0.top.equalTo(headerBarView.snp.bottom).offset(30)
        }
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .gray
        self.addSubview(view)
        view.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalTo(nameField)
            $0.top.equalTo(nameField.snp.bottom).offset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(304)
            $0.height.equalTo(150)
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(76),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(66)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 4)
        group.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}



class AddTodoView: UIView {
    
    var smallCalendarView = SmallCalendarView(frame: .zero)

    lazy var titleField: UITextField = {
        let titleField = UITextField(frame: .zero)
        titleField.placeholder = "일정을 입력하세요"
        titleField.font = UIFont(name: "Pretendard-Medium", size: 20)
        return titleField
    }()
    
    lazy var memoTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.text = "메모를 입력하세요"
        textView.textColor = .lightGray
        textView.backgroundColor = UIColor(hex: 0xF5F5FB)
        textView.font = UIFont(name: "Pretendard-Light", size: 16)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
        
    lazy var categoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("카테고리", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var categoryColorView: UIView = {
        let view = UIView(frame: .zero)
        view.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .gray
        return view
    }()
    
    lazy var categoryStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.addArrangedSubview(categoryButton)
        stack.addArrangedSubview(categoryColorView)
        return stack
    }()
    
    
    
    var headerBarView: UIView = {
        let view = UIView(frame: .zero)
        return view
    }()
    
    var saveButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
        button.setTitleColor(UIColor(hex: 0x6495F4), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "일정/투두 관리"
        label.font = UIFont(name: "Pretendard-Light", size: 16)
        label.sizeToFit()
        return label
    }()
    
    lazy var startDateButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2000.00.00", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var endDateButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("2000.00.00", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()

        return button
    }()
    
    lazy var dateArrowView: UIImageView = {
        let image = UIImage(named: "arrow_white") ?? UIImage()
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        view.image = image
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.addArrangedSubview(startDateButton)
        stackView.addArrangedSubview(dateArrowView)
        stackView.addArrangedSubview(endDateButton)
        return stackView
    }()
    
    lazy var groupSelectionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("그룹 선택", for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Light", size: 16)
        button.setTitleColor(UIColor(hex: 0xBFC7D7), for: .normal)
        button.sizeToFit()

        return button
    }()
    
    var contentStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        return stack
    }()
    
    var separatorView: [UIView] = {
        return (0..<5).map { _ in
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor(hex: 0xBFC7D7)
            return view
        }
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        
        self.addSubview(headerBarView)
        headerBarView.addSubview(titleLabel)
        headerBarView.addSubview(saveButton)

        [titleField,
         separatorView[0],
         categoryStackView,
         separatorView[1],
         dateStackView,
         separatorView[2],
         groupSelectionButton,
         separatorView[3],
         memoTextView,
         separatorView[4]
        ].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        self.addSubview(contentStackView)
        self.addSubview(smallCalendarView)
    }

    func configureLayout() {
        
        titleField.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
 
        categoryStackView.snp.makeConstraints {
            $0.height.equalTo(30)
        }

        dateStackView.snp.makeConstraints {
            $0.height.equalTo(30)
        }

        
        groupSelectionButton.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        separatorView.forEach { view in
            view.snp.makeConstraints {
                $0.height.equalTo(0.5)
                $0.width.equalToSuperview()
            }
        }

        headerBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
            $0.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(headerBarView.snp.bottom)
        }
        
        smallCalendarView.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(300)
            $0.bottom.equalToSuperview()
        }
    }
}

class AddTodoViewController: UIViewController {
    var pageType: AddTodoViewControllerPageType = .addTodo
    
    
    var didScrolledToIndex = PublishSubject<Double>()

    var viewModel: AddTodoViewModel?
    
    // MARK: Child View
    var addTodoView = AddTodoView(frame: .zero)
    var categoryView = CategorySelectView(frame: .zero)
    var categoryCreateView = CategoryCreateView(frame: .zero)
    
    // MARK: Background
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0)
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.viewModel = AddTodoViewModel()
        self.viewModel?.configureDate(date: Date())

        configureView()
        configureLayout()
        configureAddTodoView()
        configureSelectCategoryView()
        configureCreateCategoryView()
        bind()
    }
    
    func configureAddTodoView() {
        addTodoView.smallCalendarView.smallCalendarCollectionView.dataSource = self
        addTodoView.smallCalendarView.smallCalendarCollectionView.delegate = self
        addTodoView.titleField.delegate = self
        addTodoView.memoTextView.delegate = self
        
        addTodoView.smallCalendarView.prevButton.addTarget(self, action: #selector(prevBtnTapped), for: .touchUpInside)
        addTodoView.smallCalendarView.nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        addTodoView.categoryButton.addTarget(self, action: #selector(categoryBtnTapped), for: .touchUpInside)
    }
    
    func configureSelectCategoryView() {
        categoryView.tableView.dataSource = self
        categoryView.tableView.delegate = self
        categoryView.addNewItemButton.addTarget(self, action: #selector(categoryCreateBtnTapped), for: .touchUpInside)
        categoryView.backButton.addTarget(self, action: #selector(backBtnOnSelectCategoryTapped), for: .touchUpInside)
    }
    
    func configureCreateCategoryView() {
        categoryCreateView.backButton.addTarget(self, action: #selector(backBtnOnCreateCategoryTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTodoView.titleField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
             self.addTodoView.snp.remakeConstraints {
                 $0.bottom.leading.trailing.equalToSuperview()
                 $0.height.lessThanOrEqualTo(700)
             }
             self.dimmedView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
             self.view.layoutIfNeeded()
         }, completion: nil)
    }
    
    @objc func categoryBtnTapped(_ sender: UIButton) {
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.dimmedView.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func categoryCreateBtnTapped(_ sender: UIButton) {
        self.pageType = .createCategory
        categoryCreateView.nameField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView)
                $0.height.lessThanOrEqualTo(800)
                $0.bottom.equalToSuperview()
            }
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.trailing.equalTo(self.dimmedView.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func backBtnOnCreateCategoryTapped(_ sender: UIButton) {
        self.pageType = .selectCategory
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.leading)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.categoryCreateView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.trailing)
                $0.height.equalTo(500)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func backBtnOnSelectCategoryTapped(_ sender: UIButton) {
        self.pageType = .addTodo
        addTodoView.titleField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.addTodoView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.leading)
                $0.bottom.equalToSuperview()
                $0.height.lessThanOrEqualTo(700)
            }
            
            self.categoryView.snp.remakeConstraints {
                $0.width.equalToSuperview()
                $0.leading.equalTo(self.dimmedView.snp.trailing)
                $0.height.equalTo(400)
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func configureView() {
        self.view.addSubview(dimmedView)
        dimmedView.addSubview(addTodoView)
        dimmedView.addSubview(categoryView)
        dimmedView.addSubview(categoryCreateView)
    }
    
    func configureLayout() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addTodoView.snp.makeConstraints {
            $0.leading.width.equalToSuperview()
            $0.top.equalTo(dimmedView.snp.bottom)
            $0.height.lessThanOrEqualTo(700)
        }
        categoryView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(dimmedView.snp.trailing)
            $0.height.equalTo(400)
            $0.bottom.equalToSuperview()
        }
        categoryCreateView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.equalTo(dimmedView.snp.trailing)
            $0.height.lessThanOrEqualTo(800)
            $0.bottom.equalToSuperview()
        }
    }

    var bag = DisposeBag()
    
    func bind() {
        guard let viewModel else { return }

        let input = AddTodoViewModel.Input(
            didLoadView: Observable.just(()),
            didChangedIndex: didScrolledToIndex.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output
            .didChangedTitleLabel
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { vc, title in
                vc.addTodoView.smallCalendarView.dateLabel.text = title
            })
            .disposed(by: bag)
        
        output
            .didLoadInitDays
            .compactMap { $0 }
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let frameWidth = vc.view.frame.width - 20
                vc.reloadAndMove(to: CGPoint(x: frameWidth * CGFloat(count/2), y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadPrevDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX + CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
        
        output
            .didLoadFollowingDays
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { vc, count in
                let exPointX = vc.addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
                let frameWidth = vc.view.frame.width
                vc.reloadAndMove(to: CGPoint(x: exPointX - CGFloat(count)*frameWidth, y: 0))
            })
            .disposed(by: bag)
    }
    
    func reloadAndMove(to point: CGPoint) {
        addTodoView.smallCalendarView.smallCalendarCollectionView.reloadData()
        addTodoView.smallCalendarView.smallCalendarCollectionView.performBatchUpdates {
            addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(
                point,
                animated: false
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // keyboardWillShow, keyboardWillHide observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            switch pageType {
            case .addTodo:
                addTodoView.smallCalendarView.snp.remakeConstraints {
                    $0.top.equalTo(addTodoView.contentStackView.snp.bottom)
                    $0.leading.trailing.equalToSuperview().inset(10)
                    $0.height.equalTo(keyboardHeight)
                    $0.bottom.equalToSuperview()
                }
            case .selectCategory:
                return
            case .createCategory:
                categoryCreateView.descLabel.snp.remakeConstraints {
                    $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().inset(keyboardHeight+20)
                }
            }

            self.view.layoutIfNeeded()

        }
    }


    @objc func keyboardWillHide(_ notification:NSNotification) {
        switch pageType {
        case .addTodo:
            addTodoView.smallCalendarView.snp.remakeConstraints {
                $0.top.equalTo(addTodoView.contentStackView.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(10)
                $0.height.equalTo(300)
                $0.bottom.equalToSuperview()
            }
        case .selectCategory:
            return
        case .createCategory:
            categoryCreateView.descLabel.snp.remakeConstraints {
                $0.top.equalTo(categoryCreateView.collectionView.snp.bottom)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(40)
            }
        }
        self.view.layoutIfNeeded()
    }
}

extension AddTodoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categorys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell,
              let viewModel else { return UITableViewCell() }
        
        cell.nameLabel.text = viewModel.categorys[indexPath.row].title
        cell.colorView.backgroundColor = viewModel.categorys[indexPath.row].color.todoForCalendarColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("edit 클릭 됨")
            success(true)
        }
        edit.backgroundColor = .systemTeal
        edit.image = UIImage(named: "edit_swipe")
        return UISwipeActionsConfiguration(actions:[edit])
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let remove = UIContextualAction(style: .normal, title: "Remove") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("remove 클릭 됨")
            self.viewModel?.categorys.remove(at: indexPath.row)
            self.categoryView.tableView.deleteRows(at: [indexPath], with: .fade)
            success(true)
        }
        remove.backgroundColor = .systemPink
        remove.image = UIImage(named: "remove_swipe")
        return UISwipeActionsConfiguration(actions:[remove])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}

extension AddTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == self.addTodoView.titleField {

            // 원하는 액션 지정하기
            // 엔터 누르기

        }

        return true

    }
}

extension AddTodoViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "메모를 입력하세요"
            textView.textColor = UIColor(hex: 0xBFC7D7)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
}

extension AddTodoViewController {
    @objc func prevBtnTapped(_ sender: UIButton) {
        let exPointX = addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX - frameWidth, y: 0), animated: true)
    }
    
    @objc func nextBtnTapped(_ sender: UIButton) {
        let exPointX = addTodoView.smallCalendarView.smallCalendarCollectionView.contentOffset.x ?? CGFloat()
        let frameWidth = self.view.frame.width
        addTodoView.smallCalendarView.smallCalendarCollectionView.setContentOffset(CGPoint(x: exPointX + frameWidth, y: 0), animated: true)
    }
}

extension AddTodoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.viewModel?.days.count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel?.days[section].count ?? Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SmallCalendarDayCell.reuseIdentifier,
            for: indexPath
        ) as? SmallCalendarDayCell,
              let viewModel = self.viewModel,
              let currentDate = viewModel.currentDate else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.days[indexPath.section][indexPath.row]
        cell.fill(day: item.dayLabel, state: item.state, isSelectedDay: item.date == currentDate)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if pageType == .addTodo {
            let pointX = scrollView.contentOffset.x
            let frameWidth = addTodoView.smallCalendarView.smallCalendarCollectionView.frame.width
            guard frameWidth != 0 else { return }
            
            let index = pointX/frameWidth
            self.didScrolledToIndex.onNext(index)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if pageType == .addTodo && decelerate {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = false
                self?.addTodoView.smallCalendarView.prevButton.isUserInteractionEnabled = false
                self?.addTodoView.smallCalendarView.nextButton.isUserInteractionEnabled = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageType == .addTodo {
            DispatchQueue.main.async { [weak self] in
                scrollView.isUserInteractionEnabled = true
                self?.addTodoView.smallCalendarView.prevButton.isUserInteractionEnabled = true
                self?.addTodoView.smallCalendarView.nextButton.isUserInteractionEnabled = true
            }
        }
    }
}

final class SmallCalendarView: UIView {
    lazy var prevButton: UIButton = {
        let image = UIImage(named: "monthPickerLeft")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let image = UIImage(named: "monthPickerRight")
        let button = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image?.size.width ?? 0,
            height: image?.size.height ?? 0
        ))
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x000000)
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var weekDaysStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        ["월", "화", "수", "목", "금", "토", "일"].forEach {
            let label = self.weekDayLabel(weekDay: $0)
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
    
    var smallCalendarCollectionView: SmallCalendarCollectionView = {
        return SmallCalendarCollectionView(frame: .zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func weekDayLabel(weekDay: String) -> UILabel {
        let label = UILabel(frame: .zero)
        switch weekDay {
        case "일":
            label.textColor = UIColor(hex: 0xEA4335)
        case "토":
            label.textColor = UIColor(hex: 0x6495F4)
        default:
            label.textColor = .black
        }
        label.font = UIFont(name: "Pretendard-Regular", size: 14)
        label.text = weekDay
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }
    
    func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        
        self.addSubview(dateLabel)
        self.addSubview(prevButton)
        self.addSubview(nextButton)
        self.addSubview(weekDaysStackView)
        self.addSubview(smallCalendarCollectionView)
    }
    
    func configureLayout() {
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(60)
        }
        
        prevButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(10)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
        
        weekDaysStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(20)
        }
        smallCalendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekDaysStackView.snp.bottom)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
}

final class SmallCalendarCollectionView: UICollectionView {
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        self.setCollectionViewLayout(self.createLayout(), animated: false)
        
        configureView()
    }
    
    private override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.backgroundColor = UIColor(hex: 0xF5F5FB)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.register(SmallCalendarDayCell.self, forCellWithReuseIdentifier: SmallCalendarDayCell.reuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/7),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1/6)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}




class SmallCalendarDayCell: UICollectionViewCell {
    
    static let reuseIdentifier = "small-calendar-day-cell"
    
    lazy var dayLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "Pretendard-Bold", size: 12)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func configureView() {
        self.addSubview(dayLabel)
    }
    
    func configureLayout() {
        dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func fill(day: String, state: MonthStateOfDay, isSelectedDay: Bool) {
        dayLabel.text = day
        switch state {
        case .prev:
            dayLabel.textColor = UIColor(hex: 0x000000, a: 0.4)
        case .current:
            dayLabel.textColor = isSelectedDay ? .white : .black
        case .following:
            dayLabel.textColor = UIColor(hex: 0xBFC7D7, a: 0.4)
        }
        self.backgroundColor = isSelectedDay ? UIColor(hex: 0x6495F4) : nil
    }
}
