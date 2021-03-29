package com.agora.data.manager;

import android.content.Context;
import android.util.Log;

import com.agora.data.R;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;

public final class RtcManager {

    private final String TAG = RtcManager.class.getSimpleName();

    private static RtcManager instance;

    private Context mContext;
    private RtcEngine mRtcEngine;

    private String channel;
    private int uid;
    private boolean isJoined = false;

    private final List<IRtcEngineEventHandler> handlers = new ArrayList<>();

    private RtcManager(Context context) {
        mContext = context.getApplicationContext();
    }

    public static RtcManager Instance(Context context) {
        if (instance == null) {
            synchronized (RtcManager.class) {
                if (instance == null)
                    instance = new RtcManager(context);
            }
        }
        return instance;
    }

    public void init() {
        Log.d(TAG, "init() called");
        if (mRtcEngine == null) {
            try {
                mRtcEngine = RtcEngine.create(mContext, mContext.getString(R.string.app_id), mEventHandler);
            } catch (Exception e) {
                e.printStackTrace();
                Log.e(TAG, "init: ", e);
            }
        }

        setClientRole(IRtcEngineEventHandler.ClientRole.CLIENT_ROLE_AUDIENCE);
        mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        mRtcEngine.enableAudio();
        mRtcEngine.setAudioProfile(Constants.AUDIO_PROFILE_MUSIC_HIGH_QUALITY, Constants.AUDIO_SCENARIO_CHATROOM_ENTERTAINMENT);
    }

    public void joinChannel(String channelId, int userId) {
        Log.d(TAG, "joinChannel() called with: channelId = [" + channelId + "], userId = [" + userId + "]");
        if (mRtcEngine == null) {
            return;
        }

        if (isJoined) {
            for (IRtcEngineEventHandler handler : handlers) {
                handler.onJoinChannelSuccess(channel, uid, 0);
            }
            return;
        }
        mRtcEngine.joinChannel(mContext.getString(R.string.token), channelId, null, userId);
    }

    public void leaveChannel() {
        Log.d(TAG, "leaveChannel() called");
        if (mRtcEngine == null) {
            return;
        }
        mRtcEngine.leaveChannel();
    }

    public void setClientRole(int role) {
        if (mRtcEngine != null)
            mRtcEngine.setClientRole(role);
    }

    public void startAudio() {
        if (mRtcEngine == null) {
            return;
        }

        setClientRole(IRtcEngineEventHandler.ClientRole.CLIENT_ROLE_BROADCASTER);
        mRtcEngine.enableLocalAudio(true);
    }

    public void stopAudio() {
        if (mRtcEngine == null) {
            return;
        }

        setClientRole(IRtcEngineEventHandler.ClientRole.CLIENT_ROLE_AUDIENCE);
        mRtcEngine.enableLocalAudio(false);
    }

    public void muteRemoteVideoStream(int uid, boolean muted) {
        if (mRtcEngine == null) {
            return;
        }

        mRtcEngine.muteRemoteVideoStream(uid, muted);
    }

    public void muteLocalAudioStream(boolean muted) {
        if (mRtcEngine == null) {
            return;
        }

        mRtcEngine.muteLocalAudioStream(muted);
    }

    public void addHandler(IRtcEngineEventHandler handler) {
        if (mRtcEngine == null) {
            return;
        }

        handlers.add(handler);
        mRtcEngine.addHandler(handler);
    }

    public void removeHandler(IRtcEngineEventHandler handler) {
        if (mRtcEngine == null) {
            return;
        }

        handlers.remove(handler);
        mRtcEngine.removeHandler(handler);
    }

    private final IRtcEngineEventHandler mEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onError(int err) {
            super.onError(err);
            Log.e(TAG, "onError: " + err);
        }

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            super.onJoinChannelSuccess(channel, uid, elapsed);
            RtcManager.this.isJoined = true;
            RtcManager.this.channel = channel;
            RtcManager.this.uid = uid;
            Log.d(TAG, "onJoinChannelSuccess() called with: channel = [" + channel + "], uid = [" + uid + "], elapsed = [" + elapsed + "]");
        }

        @Override
        public void onLeaveChannel(RtcStats stats) {
            super.onLeaveChannel(stats);
            RtcManager.this.isJoined = false;
            RtcManager.this.channel = null;
            RtcManager.this.uid = 0;
            Log.d(TAG, "onLeaveChannel() called with: stats = [" + stats + "]");
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            super.onUserJoined(uid, elapsed);
            Log.d(TAG, "onUserJoined() called with: uid = [" + uid + "], elapsed = [" + elapsed + "]");
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            super.onUserOffline(uid, reason);
            Log.d(TAG, "onUserOffline() called with: uid = [" + uid + "], reason = [" + reason + "]");
        }

        @Override
        public void onLocalAudioStateChanged(int state, int error) {
            super.onLocalAudioStateChanged(state, error);
            Log.d(TAG, "onLocalAudioStateChanged() called with: state = [" + state + "], error = [" + error + "]");
        }

        @Override
        public void onRemoteAudioStateChanged(int uid, int state, int reason, int elapsed) {
            super.onRemoteAudioStateChanged(uid, state, reason, elapsed);
            Log.d(TAG, "onRemoteAudioStateChanged() called with: uid = [" + uid + "], state = [" + state + "], reason = [" + reason + "], elapsed = [" + elapsed + "]");
        }
    };
}
