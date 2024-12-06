//
//  RefreshControll.swift
//  Courses
//
//  Created by Руслан on 28.10.2024.
//

import Foundation
import UIKit


class RefreshControll {
    var refreshControl = UIRefreshControl()
    
    func refreshSettings(scrollView: UIScrollView? = nil, collectionView: UICollectionView? = nil) {
        refreshControl.tintColor = UIColor.blueMain
        if let scrollView = scrollView {
            scrollView.addSubview(refreshControl)
        }else if let collectionView = collectionView {
            collectionView.addSubview(refreshControl)
        }
    }
    
}
