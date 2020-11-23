//
//  ChannelsCollectionViewManager.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

struct SearchFilter {
    var text: String
}

class ChannelsCollectionViewManager: CollectionViewManager<ChannelCell> {

    // A cache of the all the user's current channels and system messages,
    // sorted by date updated, with newer channels at the beginning.
    lazy var channelCache: [DisplayableChannel] = []
    
    var channelFilter: SearchFilter? {
        didSet {
            self.loadFilteredChannels()
        }
    }

    var didSelectReservation: ((Reservation) -> Void)? = nil

    func loadFilteredChannels() {
        guard let filter = self.channelFilter else { return }

        let allChannels = !filter.text.isEmpty ? self.channelCache : ChannelSupplier.shared.allJoinedChannels
        var filteredChannels: [DisplayableChannel] = []

        filteredChannels = allChannels.filter { (channel) in
            if channel.channelType.uniqueName.contains(filter.text) {
                return true
            } else {
                return false
            }
        }

        let highlightedChannels = filteredChannels.map { (channel) -> DisplayableChannel in
            let displayable = DisplayableChannel(channelType: channel.channelType)
            displayable.highlightText = filter.text
            return displayable
        }

        let sortedChannels = highlightedChannels.sorted()

        self.set(newItems: sortedChannels) { (_) in }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.width, height: 84)
    }

    override func managerDidConfigure(cell: ChannelCell, for indexPath: IndexPath) {
        if let filter = self.channelFilter {
            cell.content.highlight(text: filter.text)
        }
    }

    func loadAllChannels() {
        let cycle = AnimationCycle(inFromPosition: .down,
                                   outToPosition: .down,
                                   shouldConcatenate: true,
                                   scrollToEnd: false)

        self.set(newItems: self.channelCache,
                 animationCycle: cycle,
                 completion: nil)
    }

    // MARK: Menu overrides

    override func collectionView(_ collectionView: UICollectionView,
                                 contextMenuConfigurationForItemAt indexPath: IndexPath,
                                 point: CGPoint) -> UIContextMenuConfiguration? {

        guard let channel = self.items.value[safe: indexPath.row],
            let cell = collectionView.cellForItem(at: indexPath) as? ChannelCell else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return ChannelPreviewViewController(with: channel, size: cell.size)
        }, actionProvider: { suggestedActions in
            if channel.isFromCurrentUser {
                return self.makeCurrentUsertMenu(for: channel, at: indexPath)
            } else {
                return self.makeNonCurrentUserMenu(for: channel, at: indexPath)
            }
        })
    }

    private func makeCurrentUsertMenu(for channel: DisplayableChannel, at indexPath: IndexPath) -> UIMenu {

        let neverMind = UIAction(title: "Never Mind", image: UIImage(systemName: "nosign")) { _ in }

        let confirm = UIAction(title: "Confirm", image: UIImage(systemName: "trash"), attributes: .destructive) { action in

            switch channel.channelType {
            case .system(_):
                self.delete(item: channel)
            case .pending(_):
                break 
            case .channel(let tchChannel):
                ChannelSupplier.delete(channel: tchChannel)
                    .ignoreUserInteractionEventsUntilDone(for: self.collectionView)
            }
        }

        let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [confirm, neverMind])

        let open = UIAction(title: "Open", image: UIImage(systemName: "arrowshape.turn.up.right")) { _ in
            self.select(indexPath: indexPath)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: "Options", children: [open, deleteMenu])
    }

    private func makeNonCurrentUserMenu(for channel: DisplayableChannel, at indexPath: IndexPath) -> UIMenu {

        let neverMind = UIAction(title: "Never Mind", image: UIImage(systemName: "nosign")) { _ in }

        let confirm = UIAction(title: "Confirm", image: UIImage(systemName: "clear"), attributes: .destructive) { action in

            switch channel.channelType {
            case .system(_):
                self.delete(item: channel)
            case .pending(_):
                break 
            case .channel(let tchChannel):
                ChannelSupplier.leave(channel: tchChannel)
                    .ignoreUserInteractionEventsUntilDone(for: self.collectionView)
            }
        }

        let deleteMenu = UIMenu(title: "Leave", image: UIImage(systemName: "clear"), options: .destructive, children: [confirm, neverMind])

        let open = UIAction(title: "Open", image: UIImage(systemName: "arrowshape.turn.up.right")) { _ in
            self.select(indexPath: indexPath)
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: "Options", children: [open, deleteMenu])
    }

    // Footer

    override func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return self.footer(for: collectionView, at: indexPath)
        default:
            fatalError("UNRECOGNIZED SECTION KIND")
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let height = (Theme.buttonHeight * 3) + (Theme.contentOffset * 4)
        return CGSize(width: collectionView.width, height: height)
    }

    private func footer(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let channelsCollectionView = collectionView as? ChannelsCollectionView else { fatalError() }

        let footer = channelsCollectionView.dequeueReusableFooterView(ReservationsFooter.self, for: indexPath)
        footer.configure()
        footer.didSelectReservation = { [unowned self] reservation in
            self.didSelectReservation?(reservation)
        }
        return footer
    }
}
