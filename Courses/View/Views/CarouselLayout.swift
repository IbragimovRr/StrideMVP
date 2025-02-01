//
//  CarouselLayout.swift
//  Courses
//
//  Created by Руслан on 16.01.2025.
//

import UIKit

class CarouselLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let itemWidth = collectionView.bounds.width / 3
        let itemHeight = collectionView.bounds.height
        itemSize = CGSize(width: itemWidth, height: itemHeight)

        // Настройка прокрутки
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        sectionInset = UIEdgeInsets(top: 0, left: collectionView.bounds.width / 3, bottom: 0, right: collectionView.bounds.width / 3)

    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
            guard let collectionView = collectionView else { return attributes }
            let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2

            var newAttributes = attributes.compactMap { attr -> UICollectionViewLayoutAttributes? in
                guard attr.representedElementKind == nil else { return nil } // Пропускаем supplementary views
                
                var newAttr = attr.copy() as! UICollectionViewLayoutAttributes
                let distance = abs(centerX - newAttr.center.x)
                let scale = 1 - distance / collectionView.bounds.width / 2
                newAttr.transform = CGAffineTransform(scaleX: scale, y: scale)
                newAttr.zIndex = Int(scale * 1000) // Z-index для расположения ячеек ближе к центру
                return newAttr
            }

           return newAttributes
        }


    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else { return proposedContentOffset }

        let itemWidth = itemSize.width
        let currentPage = round(proposedContentOffset.x / itemWidth)
        let proposedOffset = CGPoint(x: currentPage * itemWidth, y: proposedContentOffset.y)

        return proposedOffset
    }
}
