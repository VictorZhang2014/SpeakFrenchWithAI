package org.qimei.ai

import android.app.Application
// import com.umeng.commonsdk.UMConfigure


class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()

//        val umApiKey = "67c57d6d8f232a05f1256181"
//        UMConfigure.preInit(this, umApiKey, "")
//        UMConfigure.init(this, umApiKey, "", UMConfigure.DEVICE_TYPE_PHONE, null)
    }
}