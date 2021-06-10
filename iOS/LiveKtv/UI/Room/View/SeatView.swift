//
//  SeatView.swift
//  LiveKtv
//
//  Created by XC on 2021/6/7.
//

import Core
import Foundation
import RxSwift
import UIKit

class SeatView {
    weak var delegate: RoomControlDelegate!
    weak var root: UIView!
    weak var icon: UIImageView!
    weak var label: UILabel!

    private var getUserDisposable: Disposable?

    var member: LiveKtvMember? {
        didSet {
            if let member = member {
                if member.isManager {
                    label.text = "房主"
                } else {
                    label.text = String(index + 1)
                }
                if member.userId == oldValue?.userId {
                    return
                }
                getUserDisposable?.dispose()
                getUserDisposable = User.getUser(by: member.userId)
                    .observe(on: MainScheduler.instance)
                    .subscribe { [weak self] result in
                        guard let self = self else {
                            return
                        }
                        if result.success {
                            let user = result.data!
                            self.setIconImage(named: user.getLocalAvatar())
                        } else {
                            self.setIconImage(named: "default")
                        }
                    } onError: { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        self.setIconImage(named: "default")
                    }
            } else {
                icon.image = UIImage(named: "seat", in: Utils.bundle, with: nil)
                label.text = String(index + 1)
            }
        }
    }

    private let index: Int

    init(index: Int) {
        self.index = index
    }

    func subcribeUIEvent() {
        root.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapIcon)))
    }

    private func setIconImage(named: String) {
        icon.image = UIImage(named: named, in: Bundle(identifier: "io.agora.InteractivePodcast"), with: nil)
    }

    @objc func onTapIcon() {
        Logger.log(message: "onTapIcon \(index + 1)", level: .info)
        delegate.onTap(view: self)
    }

    deinit {
        Logger.log(self, message: "deinit", level: .info)
        getUserDisposable?.dispose()
        getUserDisposable = nil
    }
}
