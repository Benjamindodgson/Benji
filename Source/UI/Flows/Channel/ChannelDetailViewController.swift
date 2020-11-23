//
//  ChannelDetailBar.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import Parse
import TMROLocalization
import ReactiveSwift

protocol ChannelDetailViewControllerDelegate: class {
    func channelDetailViewControllerDidTapMenu(_ vc: ChannelDetailViewController)
}

class ChannelDetailViewController: ViewController {

    enum State {
        case collapsed
        case expanded
    }

    let collapsedHeight: CGFloat = 84
    private let titleButton = Button()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)
    private let content = ChannelContentView()
    let disposables = CompositeDisposable()

    unowned let delegate: ChannelDetailViewControllerDelegate

    var currentState = MutableProperty<State>(.collapsed)

    init(delegate: ChannelDetailViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.disposables.dispose()
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.content)
        self.content.addSubview(self.titleButton)

        self.view.roundCorners()

        self.subscribeToUpdates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.content.expandToSuperviewWidth()
        self.content.top = 0
        self.content.centerOnX()
        self.content.height = self.collapsedHeight

        self.titleButton.frame = self.content.titleLabel.frame
    }

    private func subscribeToUpdates() {

        self.disposables.add(ChannelSupplier.shared.activeChannel.producer.on(value:  { [unowned self] (channel) in
            guard let activeChannel = channel else { return }
            self.content.configure(with: activeChannel.channelType)
        }).start())

        ChannelManager.shared.channelSyncUpdate.producer.on(value:  { [weak self] (update) in
            guard let `self` = self else { return }
            
            guard let channelsUpdate = update, let activeChannel = ChannelSupplier.shared.activeChannel.value else { return }
            
            switch activeChannel.channelType {
            case .system(_):
                break
            case .pending(_):
                break 
            case .channel(let channel):
                guard channelsUpdate.channel == channel else { return }
                switch channelsUpdate.status {
                case .all:
                    self.content.configure(with: .channel(channelsUpdate.channel))
                default:
                    break
                }
            }
        }).start()
    }
}
