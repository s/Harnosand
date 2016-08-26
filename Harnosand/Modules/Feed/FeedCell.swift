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
    private var cellImageView: UIImageView?
    private var userImageView: UIImageView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var photo: Photo? = nil
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
        
        self.cellImageView?.image = nil
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
        self.createMessageLabel()
        
        self.createActivityIndicatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
    }
    
    private func createUserImageView(){
        let userImageViewSize = 40.0
        
        self.userImageView = UIImageView()
        if let userImageView = self.userImageView{
            userImageView.layer.cornerRadius = CGFloat(userImageViewSize / 2)
            userImageView.layer.masksToBounds = true
            self.addSubview(userImageView)
            
            userImageView.snp_makeConstraints { (make) in
                make.top.left.equalTo(10)
                make.width.height.equalTo(userImageViewSize)
            }

        }
    }
    
    private func createUserLabel(){
        self.userLabel = UILabel()
        if let userLabel = self.userLabel{
            userLabel.minimumScaleFactor = 0.8
            self.addSubview(userLabel)
            
            userLabel.snp_makeConstraints { (make) in
                if let userImageView = self.userImageView, dateLabel = self.relativeDateLabel{
                    make.left.equalTo(userImageView.snp_right).offset(10)
                    make.right.equalTo(dateLabel.snp_left).inset(5)
                    make.height.equalTo(40)
                    make.centerY.equalTo(userImageView)
                }
            }
        }
    }
    
    private func createRelativeDateLabel(){
        self.relativeDateLabel = UILabel()
        if let relativeDateLabel = self.relativeDateLabel{
            relativeDateLabel.textAlignment = .Right
            self.addSubview(relativeDateLabel)
            
            relativeDateLabel.snp_makeConstraints { (make) in
                if let userImageView = self.userImageView{
                    make.centerY.equalTo(userImageView)
                }
                make.right.equalTo(self).inset(10)
                make.height.equalTo(40)
            }
        }
    }
    
    private func createImageView(){
        self.cellImageView = UIImageView()
        if let cellImageView = self.cellImageView{
            self.addSubview(cellImageView)
            
            cellImageView.snp_makeConstraints { (make) in
                if let userLabel = self.userLabel{
                    make.top.equalTo(userLabel.snp_bottom).offset(5)
                }
                make.left.right.equalTo(self)
            }
        }
    }
    
    private func createActivityIndicatorView(){
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        
        if let activityIndicator = self.activityIndicator{
            self.addSubview(activityIndicator)
            activityIndicator.snp_makeConstraints { (make) in
                make.center.equalTo(self)
            }
        }
    }
    
    private func createMessageLabel(){
        self.messageLabel = UILabel()
        if let messageLabel = self.messageLabel{
            messageLabel.numberOfLines = 0
            messageLabel.minimumScaleFactor = 0.8
            self.addSubview(messageLabel)
            
            messageLabel.snp_makeConstraints { (make) in
                make.center.equalTo(self)
                make.width.equalTo(200)
            }
        }
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
        if let imageView = self.cellImageView{
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
        self.photo = photo
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