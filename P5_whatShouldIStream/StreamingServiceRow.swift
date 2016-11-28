//
//  CategoryRow.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/5/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
//import BNRCoreDataStack
import CoreData


class StreamingServiceRow: UITableViewCell
{
    @IBOutlet weak var collectionView: UICollectionView!
}

//MARK: Delegate 

extension StreamingServiceRow {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        if collectionView == nil {
            print("Error - CollectionView = nil")
            return
        }
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            if collectionView != nil {
                collectionView.contentOffset.x = newValue
            }
        }
        
        get {
            if collectionView != nil {
                return collectionView.contentOffset.x
            } else {
                return 1
            }
        }
    }
    
}

//MARK: flowDelegate

//extension StreamingServiceRow: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let itemsPerRow: CGFloat = 4
//        let hardCodedPadding: CGFloat = 5
//        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
//        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
//        return CGSize(width: itemWidth, height: itemHeight)
//        
//    }
//    
//}
