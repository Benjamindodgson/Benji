//
//  ChannelCollectionViewManager+Menu.swift
//  Benji
//
//  Created by Benji Dodgson on 11/16/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization
import TwilioChatClient

extension ChannelCollectionViewManager: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let view = interaction.view as? MessageBubbleView,
            let indexPath = view.indexPath,
            let message = self.item(at: indexPath) else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(for: message, at: indexPath)
        })
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    private func makeContextMenu(for message: Messageable, at indexPath: IndexPath) -> UIMenu {

        // Create a UIAction for sharing
        let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
            self.didTapShare?(message)
        }

        let editMessage = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { action in
            self.didTapEdit?(message, indexPath)
        }

        let resend = UIAction(title: "Resend", image: UIImage(systemName: "arrow.2.circlepath")) { action in
            self.didTapResend?(message)
        }

        let neverMind = UIAction(title: "Never Mind", image: UIImage(systemName: "nosign")) { action in}

        let confirm = UIAction(title: "Confirm", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            self.delete(item: message, in: indexPath.section)
            MessageSupplier.shared.delete(message: message)
        }

        let deleteMenu = UIMenu(title: "Delete", image: UIImage(systemName: "trash"), options: .destructive, children: [confirm, neverMind])

        let readOk = UIAction(title: "Ok", image: UIImage(systemName: "hand.thumbsup")) { action in
            self.setToRead(message: message)
        }

        let readCancel = UIAction(title: "Never mind", image: UIImage(systemName: "nosign")) { action in
        }

        let readMenu = UIMenu(title: "Set messages to read", image: UIImage(systemName: "eyeglasses"), children: [readCancel, readOk])

        if message.isFromCurrentUser {
            if message.status == .error {
                return UIMenu(title: "There was an error sending this message.", children: [resend])
            } else {
                return UIMenu(title: "", children: [deleteMenu, share, editMessage])
            }
        }

        // Create and return a UIMenu with the share action
        return UIMenu(title: "", children: [share, readMenu])
    }

    private func setToRead(message: Messageable) {
        guard let current = User.current() else { return }
        _ = message.udpateConsumers(with: current)
    }
}
