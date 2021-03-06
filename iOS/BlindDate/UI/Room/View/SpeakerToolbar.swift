//
//  SpeakerToolbar.swift
//  BlindDate
//
//  Created by XC on 2021/4/22.
//

import Foundation
import UIKit
import RxSwift
import Core

class SpeakerToolbar: UIView {
    weak var delegate: RoomController!
    let disposeBag = DisposeBag()
    
    var sendMsgBtn: IconButton = {
       let view = IconButton()
        view.icon = "tool_send_message"
        return view
    }()
    
    var beautyBtn: IconButton = {
        let view = IconButton()
         view.icon = "tool_beauty_close"
         return view
     }()
    
    var onMicView: IconButton = {
        let view = IconButton()
        view.icon = "tool_mic_open"
        return view
    }()
    
    var isMuted: Bool = false {
        didSet {
            onMicView.icon = isMuted ? "tool_mic_close" : "tool_mic_open"
        }
    }
    
    var isBeauty: Bool = false {
        didSet {
            beautyBtn.icon = isBeauty ? "tool_beauty_open" : "tool_beauty_close"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(sendMsgBtn)
        addSubview(beautyBtn)
        addSubview(onMicView)
        
        onMicView.height(constant: 34)
            .marginTrailing(anchor: trailingAnchor, constant: 12)
            .centerY(anchor: centerYAnchor)
            .active()
        
        beautyBtn.height(constant: 34)
            .marginTrailing(anchor: onMicView.leadingAnchor, constant: 14)
            .centerY(anchor: centerYAnchor)
            .active()
        
        sendMsgBtn.height(constant: 34)
            .marginLeading(anchor: leadingAnchor, constant: 12)
            .centerY(anchor: centerYAnchor)
            .active()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subcribeUIEvent() {
        sendMsgBtn.rx.tap
            .debounce(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.delegate.enableInputMessage()
            })
            .disposed(by: disposeBag)
        
        onMicView.rx.tap
            .debounce(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .filter {
                return !self.delegate.viewModel.member.isMuted
            }
            .flatMap { [unowned self] _ in
                return self.delegate.viewModel.selfMute(mute: !self.delegate.viewModel.muted())
            }
            .subscribe(onNext: { [unowned self] result in
                if (!result.success) {
                    self.delegate.show(message: result.message ?? "unknown error".localized, type: .error)
                }
            })
            .disposed(by: disposeBag)
        
        self.delegate.viewModel.isMuted
            .startWith(self.delegate.viewModel.muted())
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] muted in
                self.isMuted = muted
                if (self.delegate.viewModel.member.isMuted) {
                    self.delegate.show(message: "You've been muted".localized, type: .error)
                }
            })
            .disposed(by: disposeBag)
        
        self.delegate.viewModel.syncLocalUIStatus()
        
        //self.isBeauty = self.delegate.viewModel.enabledBeauty()
        beautyBtn.rx.tap
            .debounce(RxTimeInterval.microseconds(300), scheduler: MainScheduler.instance)
            .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.delegate.viewModel.enableBeauty(enable: !self.delegate.viewModel.enabledBeauty())
            })
            .disposed(by: disposeBag)
        
        self.delegate.viewModel.isEnableBeauty
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] isBeauty in
                self.isBeauty = isBeauty
            })
            .disposed(by: disposeBag)
    }
    
    func onReceivedAction(_ result: Result<BlindDateAction>) {}
    func subcribeRoomEvent() {}
}

