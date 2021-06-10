//
//  LiveKtvMusic.swift
//  LiveKtv
//
//  Created by XC on 2021/6/10.
//

import Core
import Foundation
import RxSwift

class LiveKtvMusic: Codable, IAgoraModel {
    public var id: String

    public var memberId: String
    public var roomId: String
    public var name: String
    public var musicId: String

    init(id: String, memberId: String, roomId: String, name: String, musicId: String) {
        self.id = id
        self.memberId = memberId
        self.roomId = roomId
        self.name = name
        self.musicId = musicId
    }

    func toDictionary() -> [String: Any?] {
        return [
            LiveKtvMusic.NAME: name,
            LiveKtvMusic.MUSIC_ID: musicId,
            LiveKtvMusic.ROOM: roomId,
            LiveKtvMusic.MEMBER: memberId,
        ]
    }
}

extension LiveKtvMusic {
    static let TABLE: String = "MUSIC_KTV"
    static let ROOM: String = "roomId"
    static let MEMBER = "memberId"
    static let NAME = "name"
    static let MUSIC_ID = "musicId"

    private static var manager: SyncManager {
        SyncManager.shared
    }

    static func get(object: IAgoraObject, member: LiveKtvMember) throws -> LiveKtvMusic {
        let id = try object.getId()
        let name: String = try object.getValue(key: LiveKtvMusic.NAME, type: String.self) as! String
        let music: String = try object.getValue(key: LiveKtvMusic.MUSIC_ID, type: String.self) as! String
        let roomId = member.roomId
        let memberId: String = member.id // try object.getValue(key: LiveKtvMusic.MEMBER, type: String.self) as! String
        return LiveKtvMusic(id: id, memberId: memberId, roomId: roomId, name: name, musicId: music)
    }

    func order() -> Observable<Result<LiveKtvMusic>> {
        return Single.create { single in
            LiveKtvMusic.manager
                .getRoom(id: self.roomId)
                .collection(className: LiveKtvMusic.TABLE)
                .add(data: self.toDictionary(), delegate: AgoraObjectDelegate(success: { object in
                    do {
                        self.id = try object.getId()
                        single(.success(Result(success: true, data: self)))
                    } catch {
                        single(.success(Result(success: false, message: error.localizedDescription)))
                    }
                }, failed: { _, message in
                    single(.success(Result(success: false, message: message)))
                }))
            return Disposables.create()
        }.asObservable()
    }
}
