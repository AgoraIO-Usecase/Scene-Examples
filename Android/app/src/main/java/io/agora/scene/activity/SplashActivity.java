package io.agora.scene.activity;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.agora.baselibrary.base.DataBindBaseActivity;
import com.agora.data.manager.UserManager;
import io.agora.interactivepodcast.activity.RoomListActivity;
import io.agora.scene.R;
import io.agora.scene.databinding.ActivitySplashBinding;

/**
 * 闪屏界面
 *
 * @author chenhengfei@agora.io
 */
public class SplashActivity extends DataBindBaseActivity<ActivitySplashBinding> {

    @Override
    protected void iniBundle(@NonNull Bundle bundle) {

    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_splash;
    }

    @Override
    protected void iniView() {

    }

    @Override
    protected void iniListener() {

    }

    @Override
    protected void iniData() {
        UserManager.Instance(this).loginIn();

        startActivity(new Intent(this, RoomListActivity.class));
        finish();
    }
}
