import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { apiForgot } from '../utils/Api';

@Entry
@Component
struct ForgotPasswordPage {
  @State username: string = ''
  @State newPassword: string = ''
  @State errorMsg: string = ''

  private async doReset() {
    this.errorMsg = '';
    try {
      await apiForgot(this.username, this.newPassword);
      promptAction.showToast({ message: '密码已重置，请用新密码登录' });
      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (e) {
      this.errorMsg = (e as Error).message ?? '重置失败';
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('找回/重置密码').fontSize(24).fontWeight(FontWeight.Medium).margin({ top: 40, bottom: 20 })
      TextInput({ placeholder: '用户名', text: this.username }).onChange(v => this.username = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')
      TextInput({ placeholder: '新密码', text: this.newPassword }).type(InputType.Password).onChange(v => this.newPassword = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')

      if (this.errorMsg) { Text(this.errorMsg).fontColor('#E53935').fontSize(14) }

      Button('重置密码', { type: ButtonType.Capsule }).width('88%').height(44).onClick(() => this.doReset())
      Text('返回登录').fontColor('#2979FF').onClick(() => router.back())
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}
