//
//  CustomSegmentView.swift
//  activeTabScroll
//
//  Created by Siddhesh Redkar  on 22/06/21.
//

import UIKit


protocol CustomSegmentViewActionsProtocol {
    func categoryTapped(_ category:String,index:Int)
}

class CustomSegmentView: UIView {
    var categoryTypes = [ItemInfo]()
    var delegate:CustomSegmentViewActionsProtocol?
    
    private let cellId = "ImageCategoryCollectionViewCell"
     

    let segmentWidth = (UIScreen.main.bounds.width - 50)
    
    let segmentView:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = CustomColor.lightBlue
        v.layer.cornerRadius = 12
        return v
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(ImageCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCategoryCollectionViewCell")
        cv.backgroundColor = .white
        cv.setCollectionViewLayout(layout, animated: false)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(segmentView)
        segmentView.addSubview(collectionView)
        collectionView.pin(to: segmentView)
        setUpConstraints()
    }
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            segmentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            segmentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            segmentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            segmentView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    func setData(categoryData:[ItemInfo]){
        self.categoryTypes = categoryData
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func scrollToIndex(index:Int){
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension CustomSegmentView:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCategoryCollectionViewCell", for: indexPath) as! ImageCategoryCollectionViewCell
        cell.data = categoryTypes[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.contentInset = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 17)
        let font = UIFont(name: "Times-Bold", size: 23)
        let width = categoryTypes[indexPath.row].title?.width(withConstrainedHeight: 60, font: font!) ?? 0
        return CGSize(width: width + 30, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCategoryCollectionViewCell{
                cell.cellCardView.transform = .init(scaleX: 0.90, y: 0.90)
            }
        }, completion: { _ in
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCategoryCollectionViewCell{
                cell.cellCardView.transform = .identity
            }
        }, completion: { _ in
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoryTapped(categoryTypes[indexPath.row].title ?? "", index: indexPath.row)
    }
    
}



class ImageCategoryCollectionViewCell: UICollectionViewCell {
    
    var data:ItemInfo?{
        didSet{
            manageData()
        }
    }
    
    let cellCardView:UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    let imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.layer.cornerRadius = 5
        img.isUserInteractionEnabled = true
        return img
    }()
    
    let opaqueView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 5
        v.backgroundColor = UIColor(white: 0 , alpha: 0.5)
        return v
    }()
    
    let categoryLabel: UILabel = {
        let cl = UILabel()
        cl.textColor = .white
        cl.font = UIFont(name: "Times-Bold", size: 23)
        cl.textAlignment = .center
        cl.translatesAutoresizingMaskIntoConstraints = false
        return cl
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        addSubview(cellCardView)
        cellCardView.addSubview(imgView)
        cellCardView.addSubview(opaqueView)
        cellCardView.addSubview(categoryLabel)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints(){
        cellCardView.pin(to: self)
        imgView.pin(to: cellCardView)
        opaqueView.pin(to: cellCardView)
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: cellCardView.leadingAnchor, constant: 15),
            categoryLabel.trailingAnchor.constraint(equalTo: cellCardView.trailingAnchor, constant: -15),
            categoryLabel.bottomAnchor.constraint(equalTo: cellCardView.bottomAnchor),
            categoryLabel.topAnchor.constraint(equalTo: cellCardView.topAnchor)
        ])
    }
    
    func manageData(){
        guard let data = data else {return}
        categoryLabel.text = data.title
    }
    
}

