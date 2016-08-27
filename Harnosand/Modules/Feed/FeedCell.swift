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
    case LoadedDataWithNoImageURL
    case LoadedImageWithError
    case LoadedDataOK
    case LoadingData
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
    private var person: Person? = nil
    
    private var previousState: CellState?
    private var currentState: CellState?{
        willSet{
            self.previousState = currentState
        }
        didSet{
            if let state = currentState, messageLabel = self.messageLabel, userImageView = self.userImageView, activityIndicator = self.activityIndicator{
                switch state{
                case .LoadingData:
                    messageLabel.hidden = true
                    activityIndicator.startAnimating()
                    activityIndicator.hidden = false
                    
                case .LoadedDataOK:
                    userImageView.hidden = false
                    messageLabel.hidden = true
                    activityIndicator.stopAnimating()
                    activityIndicator.hidden = true
                    
                case .LoadedDataWithNoImageURL, .LoadedImageWithError:
                    activityIndicator.hidden = true
                    userImageView.hidden = true
                    messageLabel.hidden = false
                    messageLabel.text = NSLocalizedString("There was an error while loading this image.", comment: "")
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.activityIndicator?.hidden = false
        self.messageLabel?.hidden = true
        
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
        if let userLabel = self.userLabel, userImageView = self.userImageView, dateLabel = self.relativeDateLabel{
            userLabel.minimumScaleFactor = 0.8
            self.addSubview(userLabel)
            
            userLabel.snp_makeConstraints { (make) in
                make.left.equalTo(userImageView.snp_right).offset(10)
                make.right.equalTo(dateLabel.snp_left).inset(5)
                make.height.equalTo(40)
                make.centerY.equalTo(userImageView)
            }
        }
    }
    
    private func createRelativeDateLabel(){
        self.relativeDateLabel = UILabel()
        if let relativeDateLabel = self.relativeDateLabel, userImageView = self.userImageView{
            relativeDateLabel.textAlignment = .Right
            self.addSubview(relativeDateLabel)
            
            relativeDateLabel.snp_makeConstraints { (make) in
                make.centerY.equalTo(userImageView)
                make.right.equalTo(self).inset(10)
                make.height.equalTo(40)
            }
        }
    }
    
    private func createImageView(){
        self.cellImageView = UIImageView()
        if let cellImageView = self.cellImageView, userLabel = self.userLabel{
            cellImageView.contentMode = .ScaleAspectFit
            self.addSubview(cellImageView)
            
            cellImageView.snp_makeConstraints { (make) in
                make.top.equalTo(userLabel.snp_bottom).offset(5)
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
            messageLabel.numberOfLines = 2
            messageLabel.minimumScaleFactor = 0.75
            messageLabel.textAlignment = .Center
            messageLabel.hidden = true
            self.addSubview(messageLabel)
            
            messageLabel.snp_makeConstraints { (make) in
                make.center.equalTo(self)
                make.width.equalTo(self).inset(20)
                make.bottom.equalTo(self.snp_bottom)
            }
        }
    }
    
    private func setImage(imageView: UIImageView, url: NSURL){
        self.currentState = CellState.LoadingData
        
        FlickrService.sharedService.getImage(url: url) { (response:FlickrServiceResult<UIImage>) in
            if let photoURL = self.photo?.url, userImageURL = self.person?.profileImageURL{
                if url == photoURL || url == userImageURL{
                    switch response{
                    case .Success(let image):
                        self.currentState = CellState.LoadedDataOK
                        imageView.image = image
                    case .Failure(let error):
                        self.currentState = CellState.LoadedImageWithError
                        print(error)
                    }
                }else{
                    self.currentState = self.previousState
                }
            }else{
                self.currentState = self.previousState
            }
        }
    }
    
    private func loadPersonDetails(with photo:Photo, completion:(FlickrServiceResult<Person>)->Void){
        FlickrService.sharedService.getOwner(of: photo, completion: { (response:FlickrServiceResult<Person>) in
            if let selfPhoto = self.photo where selfPhoto.identifier == photo.identifier{
                completion(response)
            }
        })
    }
}

extension FeedCell: FeedCellProtocol{
    func configureCell(with photo:Photo) {
        self.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.photo = photo
        
        self.loadPersonDetails(with: photo) { (response:FlickrServiceResult<Person>) in
            switch response{
            case .Success(let person):
                self.person = person
                self.userLabel?.text = person.username
                if let userImageView = self.userImageView{
                    self.setImage(userImageView, url: person.profileImageURL)
                }
            case .Failure(let error):
                print(error)
            }
        }
        
        if let dateLabel = relativeDateLabel, dateTaken = photo.dateTaken{
            dateLabel.text = dateTaken.timeAgo()
        }
        
        if let url = photo.url where url != ""{
            if let cellImageView = self.cellImageView{
                self.setImage(cellImageView, url: url)
            }
        }else{
            self.currentState = CellState.LoadedDataWithNoImageURL
        }
    }
}