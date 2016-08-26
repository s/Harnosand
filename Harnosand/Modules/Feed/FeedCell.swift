//
//  FeedCell.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 26/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NSDate_TimeAgo

enum CellState{
    case LoadedWithNoImageURL
    case LoadedOK
    case Loading
}

protocol FeedCellProtocol{
    func configureCell(with photo:Photo)
}

class FeedCell: UICollectionViewCell{
    private var userLabel: UILabel?
    private var relativeDateLabel: UILabel?
    private var messageLabel: UILabel?
    private var imageView: UIImageView?
    private var userImageView: UIImageView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var currentState: CellState?{
        didSet{
            if let state = currentState{
                switch state{
                case .Loading:
                    self.messageLabel?.hidden = true
                    self.activityIndicator?.startAnimating()
                    self.activityIndicator?.hidden = false
                    
                case .LoadedOK:
                    self.userImageView?.hidden = false
                    self.messageLabel?.hidden = true
                    self.activityIndicator?.stopAnimating()
                    self.activityIndicator?.hidden = true
                    
                case .LoadedWithNoImageURL:
                    self.userImageView?.hidden = true
                    self.messageLabel?.hidden = false
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView?.image = nil
        self.userImageView?.image = nil
        
        self.userLabel?.text = ""
        self.relativeDateLabel?.text = ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.createUserImageView()
        self.createRelativeDateLabel()
        self.createUserLabel()
        self.createImageView()
        
        self.createActivityIndicatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUserImageView(){
        let userImageViewSize = 40.0
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = CGFloat(userImageViewSize / 2)
        imageView.layer.masksToBounds = true
        self.addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.width.height.equalTo(userImageViewSize)
        }
        self.userImageView = imageView
    }
    
    private func createUserLabel(){
        let label = UILabel()
        label.minimumScaleFactor = 0.8
        self.addSubview(label)
        
        label.snp_makeConstraints { (make) in
            if let userImageView = self.userImageView, dateLabel = self.relativeDateLabel{
                make.left.equalTo(userImageView.snp_right).offset(10)
                make.right.equalTo(dateLabel.snp_left).offset(5)
                make.height.equalTo(30)
                make.centerY.equalTo(userImageView)
            }
        }
        self.userLabel = label
    }
    
    private func createRelativeDateLabel(){
        let label = UILabel()
        label.textAlignment = .Right
        self.addSubview(label)
        
        label.snp_makeConstraints { (make) in
            if let userImageView = self.userImageView{
                make.centerY.equalTo(userImageView)
            }
            make.right.equalTo(self).inset(10)
            make.height.equalTo(30)
        }
        
        self.relativeDateLabel = label
    }
    
    private func createImageView(){
        let imageView = UIImageView()
        self.addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) in
            if let label = userLabel{
                make.top.equalTo(label.snp_bottom).offset(20)
            }
            make.center.equalTo(self)
        }
        self.imageView = imageView
    }
    
    private func createActivityIndicatorView(){
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.addSubview(activityIndicator)
        
        activityIndicator.snp_makeConstraints { (make) in
            make.center.equalTo(self)
        }
        self.activityIndicator = activityIndicator
    }
    
    private func createMessageLabel(){
        let label = UILabel()
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.8
        self.addSubview(label)
        
        label.snp_makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(200)
        }
        self.messageLabel = label
    }
    
    private func setImage(imageView: UIImageView, url: NSURL){
        self.currentState = CellState.Loading
        FlickrService.sharedService.getImage(url: url) { (response:FlickrServiceResult<UIImage>) in
            self.currentState = CellState.LoadedOK
            switch response{
            case .Success(let image):
                imageView.image = image
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    private func loadCellImage(with url:NSURL){
        if let imageView = self.imageView{
            self.setImage(imageView, url: url)
        }
    }
    
    private func loadPersonDetails(with photo:Photo){
        if let userImageView = self.userImageView{
            FlickrService.sharedService.getOwner(of: photo, completion: { (response:FlickrServiceResult<Person>) in
                switch response{
                case .Success(let person):
                    self.userLabel?.text = person.username
                    self.setImage(userImageView, url: person.profileImageURL)
                case .Failure(let error):
                    print(error)
                }
            })
        }
    }
}

extension FeedCell: FeedCellProtocol{
    func configureCell(with photo:Photo) {
        
        self.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.loadPersonDetails(with: photo)
        if let dateLabel = relativeDateLabel, dateTaken = photo.dateTaken{
            dateLabel.text = dateTaken.timeAgo()
        }
        if let url = photo.url{
            self.loadCellImage(with: url)
        }else{
            self.currentState = CellState.LoadedWithNoImageURL
            self.messageLabel?.text = NSLocalizedString("No url found for this time. Sorry.", comment: "")
        }
    }
}