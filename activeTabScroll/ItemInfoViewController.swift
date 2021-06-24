//
//  ItemInfoViewController.swift
//  activeTabScroll
//
//  Created by Siddhesh Redkar  on 22/06/21.
//

import UIKit
import Foundation

// MARK: - WelcomeElement
struct ItemInfo: Codable {
    let title, welcomeDescription: String?

    enum CodingKeys: String, CodingKey {
        case title
        case welcomeDescription = "Description "
    }
}

typealias Info = [ItemInfo]

class ItemInfoViewController: UIViewController {
    
    var categoryInfo = [ItemInfo]()
    
    private let cellId = "TopGamesCollectionViewCell"
    private let headId = "HeaderCell"
    
    lazy var segmentView:CustomSegmentView = {
        let v = CustomSegmentView()
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: view.frame.width - 100, height: 50)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.register(TopGamesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        cv.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headId)
        cv.backgroundColor = .white
        cv.setCollectionViewLayout(layout, animated: false)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let transactionResponce = loadJson(filename: "houseDetails")
        segmentView.setData(categoryData: transactionResponce ?? [])
        categoryInfo = transactionResponce ?? []
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        view.backgroundColor = .white
        view.addSubview(segmentView)
        view.addSubview(collectionView)
        setUpCustomNavBar()
        setUpConstraints()

        // Do any additional setup after loading the view.
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            segmentView.topAnchor.constraint(equalTo: view.topAnchor),
            segmentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentView.heightAnchor.constraint(equalToConstant: 100),
            
            collectionView.topAnchor.constraint(equalTo: segmentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    func setUpCustomNavBar(){
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        //MARK:- search Button
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage(named: "search")?.withRenderingMode(.alwaysOriginal), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        let rightBarButtonItem1 = UIBarButtonItem()
        rightBarButtonItem1.customView = searchButton
        
        //MARK:- home Button
        let homeButton = UIButton(type: .system)
        homeButton.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), for: .normal)
        homeButton.addTarget(self, action: #selector(homeButtonPressed), for: .touchUpInside)
        homeButton.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: homeButton)
        let rightBarButtonItem2 = UIBarButtonItem()
        rightBarButtonItem2.customView = homeButton
        
        navigationItem.setRightBarButtonItems([rightBarButtonItem2, rightBarButtonItem1], animated: true)
        
        //MARK:- Title
        let title = UILabel()
        title.text = " Info"
        title.textColor = CustomColor.appBlack
        title.font = UIFont(name: CustomFont.RalewayBold, size: 20)
        let leftBarButtonItem = UIBarButtonItem()
        leftBarButtonItem.customView = title
        
        navigationItem.setLeftBarButtonItems([leftBarButtonItem], animated: true)
    }
    
    @objc func homeButtonPressed(){
    }
    
    //MARK:Service
    
    func loadJson(filename fileName: String) -> Info?{
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Info.self, from: data)
                return jsonData
            }catch{
                print("error:\(error)")
            }
        }
        return nil
    }


}

extension ItemInfoViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categoryInfo.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopGamesCollectionViewCell", for: indexPath) as! TopGamesCollectionViewCell
        cell.data = categoryInfo[indexPath.section]
            return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.width, height: 360)
        } else {
            return CGSize(width: collectionView.frame.width, height: 270 + 70)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        var header = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionHeader {
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: headId,
                    for: indexPath) as? HeaderCell
                else {
                    fatalError("Invalid view type")
            }
            headerView.data = categoryInfo[indexPath.section]
            header = headerView
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        segmentView.scrollToIndex(index:indexPath.section)
    }
    
    

    
}




extension ItemInfoViewController:CustomSegmentViewActionsProtocol{
    func categoryTapped(_ category: String, index: Int) {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
    }
    

    
    
}







class TopGamesCollectionViewCell: UICollectionViewCell {
    
    var data:ItemInfo?{
        didSet{
            manageData()
        }
    }

    let label1:UILabel = {
        let l = UILabel()
        l.text = "Rage 2"
        l.textColor = .white
        l.numberOfLines = 0
        l.font = UIFont(name: CustomFont.RalewaySemiBoldItalic, size: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let VView1:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .lightGray
        v.layer.cornerRadius = 10
        v.layer.shadowColor = UIColor(red: 172/255, green: 135/355, blue: 87/255, alpha: 1).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 5)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.5
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(VView1)
        VView1.addSubview(label1)
        label1.pin(to: VView1)
        setUpConstraints()
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            VView1.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            VView1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            VView1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            VView1.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func manageData(){
        guard let data = data else {return}
        label1.text = data.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



class HeaderCell: UICollectionReusableView {

    
    var data:ItemInfo?{
        didSet{
            manageData()
        }
    }
    
    var HeaderTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .black
        lbl.textAlignment = .left
        lbl.numberOfLines = 1
        lbl.text = "My Saved Fitness Session"
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.myCustomInit()
        layoutUI()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.myCustomInit()
    }
    
    private func layoutUI() {
        addSubview(HeaderTitleLbl)
        HeaderTitleLbl.pin(to: self)
        HeaderTitleLbl.translatesAutoresizingMaskIntoConstraints = false

    }

    func manageData(){
        guard let data = data else {return}
        HeaderTitleLbl.text = data.title
    }
    func myCustomInit() {
        print("hello there from SupView")
    }

}



