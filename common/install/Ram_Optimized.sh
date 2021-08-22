mulu="/sdcard/Android/data"

alipay='com.alipay.mobile.liteprocess.ipc.IpcMsgServer
com.alipay.mobile.liteprocess.LiteProcessService$LiteProcessService1
com.alipay.mobile.liteprocess.LiteProcessService$LiteProcessService2
com.alipay.mobile.liteprocess.LiteProcessService$LiteProcessService3
com.alipay.mobile.liteprocess.LiteProcessService$LiteProcessService4
com.alipay.mobile.liteprocess.LiteProcessService$LiteProcessService5
com.alipay.mobile.nebulacore.GpuSandboxedProcessService0
com.alipay.mobile.healthcommand.stepcounter.APExtStepService
com.alipay.mobile.nebulacore.SandboxedPrivilegedProcessService0
com.amap.api.location.APSservice
mtopsdk.xstate.XStateService
com.alipay.dexaop.power.RuntimePowerService'

if [[ -e $mulu/"com.eg.android.AlipayGphone" ]]; then
  for i in $alipay; do
    pm disable "com.eg.android.AlipayGphone/$i"
  done
fi

netease="com.netease.cloudmusic.module.webview.BrowserPreService
com.netease.cloudmusic.video.service.VideoPlayService
com.netease.android.extension.servicekeeper.service.ipc.server.IPCCommunicationAndroidService
com.netease.cloudmusic.service.LocalMusicMatchService
com.netease.play.base.LookPreloadService
com.netease.cloudmusic.service.PlayNannyService"

if [[ -e $mulu/"com.netease.cloudmusic" ]]; then
  for i in $netease; do
    pm disable "com.netease.cloudmusic/$i"
  done
fi

mobileqq="com.tencent.mobileqq.mini.app.InternalAppBrandTaskPreloadReceiver
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver1
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver2
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver3
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver4
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver5
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver6
com.tencent.mobileqq.mini.app.AppBrandTaskPreloadReceiver7
com.tencent.mobileqq.mini.launch.AppBrandMainService
com.tencent.mobileqq.music.QQPlayerService
com.tencent.mobileqq.kandian.biz.ugc.KandianVideoUploadService
com.tencent.qqmini.sdk.server.AppMainService
com.tencent.mobileqq.emosm.web.MessengerService
com.tencent.mobileqq.activity.PreloadWebService
cooperation.qzone.QzonePluginProxyService
cooperation.qzone.remote.logic.QzoneWebPluginProxyService
com.tencent.biz.troop.TroopMemberApiService
com.tencent.qqmini.sdk.receiver.AppBrandMainReceiver1
com.tencent.qqmini.sdk.receiver.AppBrandMainReceiver2
com.tencent.qqmini.sdk.receiver.AppBrandMainReceiver3
com.tencent.qqmini.sdk.receiver.AppBrandMainReceiver4
com.tencent.qqmini.sdk.receiver.AppBrandMainReceiver5
com.tencent.qqmini.sdk.receiver.InternalAppBrandMainReceiver
com.tencent.qqmini.miniapp.receiver.WebProcessReceiver
cooperation.qqdataline.ipc.DatalineProxyService"

if [[ -e $mulu/"com.tencent.mobileqq" ]]; then
  for i in $mobileqq; do
    pm disable "com.tencent.mobileqq/$i"
  done
fi

mm='com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand1IPCService
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand0IPCService
com.tencent.mm.service.ProcessService$ToolsProcessService
com.tencent.mm.service.ProcessService$ToolsmpProcessService
com.tencent.mm.ipcinvoker.wx_extension.service.ToolsMpProcessIPCService
com.tencent.mm.ipcinvoker.wx_extension.service.ToolsProcessIPCService
com.tencent.mm.plugin.hld.WxHldService
com.tencent.mm.plugin.appbrand.task.AppBrandTaskPreloadReceiver
com.tencent.mm.plugin.appbrand.task.AppBrandTaskPreloadReceiver1
com.tencent.mm.plugin.appbrand.task.AppBrandTaskPreloadReceiver2
com.tencent.mm.plugin.appbrand.task.AppBrandTaskPreloadReceiver3
com.tencent.mm.plugin.appbrand.task.AppBrandTaskPreloadReceiver4
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand0IPCService
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand1IPCService
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand2IPCService
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand3IPCService
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand4IPCService
com.tencent.mm.booter.MMReceivers$ToolsMpProcessReceiver
com.tencent.mm.booter.MMReceivers$ToolsProcessReceiver
com.tencent.mm.ipcinvoker.wx_extension.service.Appbrand1IPCService
com.tencent.mm.sandbox.updater.AppUpdaterUI
com.tencent.mm.sandbox.updater.AppInstallerUI'

if [[ -e $mulu/"com.tencent.mm" ]]; then
  for i in $mm; do
    pm disable "com.tencent.mm/$i"
  done
fi
