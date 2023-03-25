//
//  TUIVideoSeat.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//  Copyright © 2022 Tencent. All rights reserved.
//

import TUIRoomEngine
import UIKit
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

class TUIVideoSeatView: UIView {
    
    let CellID_Normal = "TUIVideoSeatCell_Normal"
    let CellID_Share = "TUIVideoSeatCell_Share"
    
    let viewModel: TUIVideoSeatViewModel
    private var isViewReady: Bool = false
    let kCellNumberOfOneRow = 2 //一行中有几个cell
    let kCellMaxNumberOfRow = 3 //最多有多少行
    let kMaxShowCellCount = 6   //一页最多有多少个cell
    let kCellSpacing: CGFloat = 5
    init(frame: CGRect, roomEngine: TUIRoomEngine, roomId: String) {
        viewModel = TUIVideoSeatViewModel(roomEngine: roomEngine, roomId: roomId)
        super.init(frame: frame)
        viewModel.viewResponder = self
        self.isUserInteractionEnabled = true
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var attendeeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: layout)
        collection.register(TUIVideoSeatCell.self, forCellWithReuseIdentifier: CellID_Normal)
        collection.register(TUIVideoSeatShareCell.self, forCellWithReuseIdentifier: CellID_Share)
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.isUserInteractionEnabled = true
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .black
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    func constructViewHierarchy() {
        backgroundColor = .clear
        addSubview(attendeeCollectionView)
    }
    
    func activateConstraints() {
        attendeeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

// MARK: - TUIVideoSeatViewResponder
extension TUIVideoSeatView: TUIVideoSeatViewResponder {
    func reloadData() {
        attendeeCollectionView.reloadData()
    }
    
    func updateSeatItem(_ item: VideoSeatItem) {
        guard let cellIndexPath = item.cellIndexPath else { return }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) else { return }
        if let seatCell = cell as? TUIVideoSeatShareCell {
            seatCell.updateUI(item: item)
        }
        if let seatCell = cell as? TUIVideoSeatCell {
            seatCell.updateUI(item: item)
        }
    }
    
    func updateSeatVolume(_ item: VideoSeatItem) {
        guard let cellIndexPath = item.cellIndexPath else { return }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) else { return }
        if let seatCell = cell as? TUIVideoSeatShareCell {
            seatCell.updateUIVolume(item: item)
        }
        if let seatCell = cell as? TUIVideoSeatCell {
            seatCell.updateUIVolume(item: item)
        }
    }
    
    func getSeatVideoRenderView(_ item: VideoSeatItem) -> UIView? {
        guard let cellIndexPath = item.cellIndexPath else { return nil }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) else { return nil }
        if let seatCell = cell as? TUIVideoSeatShareCell {
            return seatCell.cameraRenderView
        }
        if let seatCell = cell as? TUIVideoSeatCell {
            return seatCell.cameraRenderView
        }
        return nil
    }
    
    func getSeatShareRenderView(_ item: VideoSeatItem) -> UIView? {
        guard let cellIndexPath = item.cellIndexPath else { return nil }
        guard let cell = attendeeCollectionView.cellForItem(at: cellIndexPath) else { return nil }
        guard let shareCell = cell as? TUIVideoSeatShareCell else { return nil }
        return shareCell.screenShareRenderView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TUIVideoSeatView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.seatItems.count == 1 || (viewModel.shareSeatItem != nil) {
            return CGSize(width: self.mm_w, height: self.mm_h)
        } else {
            let cellWidth: CGFloat = (attendeeCollectionView.frame.size.width - kCellSpacing * CGFloat(kCellNumberOfOneRow)) /
            CGFloat(kCellNumberOfOneRow)
            let cellHight: CGFloat = cellWidth
            return CGSize(width: cellWidth, height: cellHight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if viewModel.seatItems.count == 1 || viewModel.shareSeatItem != nil {
            return UIEdgeInsets(top: kCellSpacing, left: kCellSpacing, bottom: kCellSpacing, right: kCellSpacing)
        } else {
            let cellWidth: CGFloat = (attendeeCollectionView.frame.size.width - kCellSpacing * 3 ) / 2
            let cellHight: CGFloat = cellWidth
            var cellInSectionCount = viewModel.seatItems.count
            let sectionNumber = section + 1
            if cellInSectionCount/(sectionNumber * kMaxShowCellCount) >= 1 {
                cellInSectionCount = kMaxShowCellCount
            } else {
                if section == 0 {
                    cellInSectionCount = cellInSectionCount % kMaxShowCellCount
                } else {
                    cellInSectionCount = cellInSectionCount % (section * kMaxShowCellCount)
                }
            }
            let cellHorizontalCount = cellInSectionCount / kCellNumberOfOneRow + cellInSectionCount % kCellNumberOfOneRow
            if section == 0 {
                let totalCellHight = CGFloat(cellHorizontalCount) * cellHight + CGFloat(cellHorizontalCount - 1) * kCellSpacing
                let topInset = (attendeeCollectionView.frame.size.height - totalCellHight) / 2
                let bottomInset = topInset
                return UIEdgeInsets(top: topInset, left: kCellSpacing, bottom: bottomInset, right: kCellSpacing)
            } else {
                let totalCellHight = CGFloat(cellHorizontalCount) * cellHight + CGFloat(cellHorizontalCount - 1) * kCellSpacing
                let topCellInset = CGFloat(kCellMaxNumberOfRow) * cellHight + CGFloat(kCellMaxNumberOfRow - 1) * kCellSpacing
                let topInset = (attendeeCollectionView.frame.size.height - topCellInset) / 2
                let bottomInset = (attendeeCollectionView.frame.size.height - totalCellHight - topInset)
                return UIEdgeInsets(top: topInset, left: kCellSpacing, bottom: bottomInset, right: kCellSpacing)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let seatCell = cell as? TUIVideoSeatCell, let seatItem = seatCell.seatItem {
            if seatItem.hasVideoStream {
                viewModel.startPlayCameraVideo(item: seatItem, renderView: seatCell.cameraRenderView)
            } else {
                viewModel.stopPlayCameraVideo(item: seatItem)
            }
            viewModel.asyncUserInfo(seatItem)
        }
        if let seatCell = cell as? TUIVideoSeatShareCell, let seatItem = seatCell.seatItem {
            viewModel.startPlayScreenVideo(item: seatItem, renderView: seatCell.screenShareRenderView)
            if seatItem.hasVideoStream {
                viewModel.startPlayCameraVideo(item: seatItem, renderView: seatCell.cameraRenderView)
            } else {
                viewModel.stopPlayCameraVideo(item: seatItem)
            }
            viewModel.asyncUserInfo(seatItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let seatCell = cell as? TUIVideoSeatCell, let seatItem = seatCell.seatItem {
            viewModel.stopPlayCameraVideo(item: seatItem)
        }
        if let seatCell = cell as? TUIVideoSeatShareCell, let seatItem = seatCell.seatItem {
            viewModel.stopPlayCameraVideo(item: seatItem)
            viewModel.stopPlayScreenVideo(item: seatItem)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TUIVideoSeatView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel.shareSeatItem != nil {
            return 1
        } else {
            let itemCount = viewModel.seatItems.count
            guard itemCount > 0 else { return 0 }
            if itemCount%kMaxShowCellCount == 0 {
                return itemCount/kMaxShowCellCount
            } else {
                return viewModel.seatItems.count/kMaxShowCellCount + 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.shareSeatItem != nil {
            return 1
        } else {
            let cellCount = viewModel.seatItems.count
            guard cellCount > 0 else { return 0 }
            let sectionNumber = section + 1
            if cellCount / (sectionNumber * kMaxShowCellCount) >= 1 {
                return kMaxShowCellCount
            } else {
                if section == 0 {
                    return cellCount % kMaxShowCellCount
                } else {
                    return cellCount % (section * kMaxShowCellCount)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let seatItem = viewModel.shareSeatItem, indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellID_Share,
                for: indexPath) as! TUIVideoSeatShareCell
            seatItem.cellIndexPath = indexPath
            cell.updateUI(item: seatItem)
            viewModel.startPlayScreenVideo(item: seatItem, renderView: cell.screenShareRenderView)
            if seatItem.hasVideoStream {
                viewModel.startPlayCameraVideo(item: seatItem, renderView: cell.cameraRenderView)
            } else {
                viewModel.stopPlayCameraVideo(item: seatItem)
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellID_Normal,
            for: indexPath) as! TUIVideoSeatCell
        let seatItemIndex = indexPath.section * kMaxShowCellCount + indexPath.item
        let seatItem = viewModel.seatItems[seatItemIndex]
        seatItem.cellIndexPath = indexPath
        cell.updateUI(item: seatItem)
        if seatItem.hasVideoStream {
            viewModel.startPlayCameraVideo(item: seatItem, renderView: cell.cameraRenderView)
        } else {
            viewModel.stopPlayCameraVideo(item: seatItem)
        }
        return cell
    }
    
}
