//
//  ChannelViewController+Keyboard.swift
//  Benji
//
//  Created by Benji Dodgson on 6/3/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelViewController {

    // MARK: - Register / Unregister Observers

    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelViewController.handleKeyboardDidChangeState(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelViewController.handleTextViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
    }

    // MARK: - Notification Handlers

    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if self.scrollsToLastItemOnKeyboardBeginsEditing || self.scrollsToBottomOnKeyboardBeginsEditing {
            guard let inputTextView = notification.object as? InputTextView,
                inputTextView === self.messageInputAccessoryView.expandingTextView else { return }

            if let indexPath = self.indexPathForEditing {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            } else if self.scrollsToLastItemOnKeyboardBeginsEditing {
                self.collectionView.scrollToLastItem()
            } else {
                self.collectionView.scrollToEnd()
            }
        }
    }

    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        guard !isMessagesControllerBeingDismissed else { return }

        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty || UIDevice.current.userInterfaceIdiom != .pad else {
            // WORKAROUND for what seems to be a bug in iPad's keyboard handling in iOS 11: we receive an extra spurious frame change
            // notification when undocking the keyboard, with a zero starting frame and an incorrect end frame. The workaround is to
            // ignore this notification.
            return
        }

        guard self.presentedViewController == nil else {
            // This is important to skip notifications from child modal controllers in iOS >= 13.0
            return
        }

        // Note that the check above does not exclude all notifications from an undocked keyboard, only the weird ones.
        //
        // We've tried following Apple's recommended approach of tracking UIKeyboardWillShow / UIKeyboardDidHide and ignoring frame
        // change notifications while the keyboard is hidden or undocked (undocked keyboard is considered hidden by those events).
        // Unfortunately, we do care about the difference between hidden and undocked, because we have an input bar which is at the
        // bottom when the keyboard is hidden, and is tied to the keyboard when it's undocked.
        //
        // If we follow what Apple recommends and ignore notifications while the keyboard is hidden/undocked, we get an extra inset
        // at the bottom when the undocked keyboard is visible (the inset that tries to compensate for the missing input bar).
        // (Alternatives like setting newBottomInset to 0 or to the height of the input bar don't work either.)
        //
        // We could make it work by adding extra checks for the state of the keyboard and compensating accordingly, but it seems easier
        // to simply check whether the current keyboard frame, whatever it is (even when undocked), covers the bottom of the collection
        // view.

        guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardEndFrame = self.view.convert(keyboardEndFrameInScreenCoords, from: self.view.window)

        let newBottomInset = self.requiredScrollViewBottomInset(forKeyboardFrame: keyboardEndFrame)
        let differenceOfBottomInset = newBottomInset - self.collectionViewBottomInset

        if self.maintainPositionOnKeyboardFrameChanged && differenceOfBottomInset != 0 {
            let contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: self.collectionView.contentOffset.y + differenceOfBottomInset)
            self.collectionView.setContentOffset(contentOffset, animated: false)
        }

        self.collectionViewBottomInset = newBottomInset
    }

    // MARK: - Inset Computation

    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
        // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
        let intersection = self.collectionView.frame.intersection(keyboardFrame)

        if intersection.isNull || (self.collectionView.frame.maxY - intersection.maxY) > 0.001 {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, self.additionalBottomInset - self.automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + self.additionalBottomInset - self.automaticallyAddedBottomInset)
        }
    }

    func requiredInitialScrollViewBottomInset() -> CGFloat {
        let inputAccessoryViewHeight = self.inputAccessoryView?.frame.height ?? 0
        return max(0, inputAccessoryViewHeight + self.additionalBottomInset - self.automaticallyAddedBottomInset)
    }

    /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
    /// which needs to be accounted for when setting the contentInset based on screen coordinates.
    ///
    /// - Returns: The distance automatically added to contentInset.bottom, if any.
    private var automaticallyAddedBottomInset: CGFloat {
        return self.collectionView.adjustedContentInset.bottom - self.collectionView.contentInset.bottom
    }
}
