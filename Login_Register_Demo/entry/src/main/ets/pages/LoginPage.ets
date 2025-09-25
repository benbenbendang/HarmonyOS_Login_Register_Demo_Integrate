import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { apiLogin } from '../utils/Api';

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State errorMsg: string = ''

  private async doLogin() {
    this.errorMsg = '';
    try {
      const res = await apiLogin(this.username, this.password);
      AppStorage.SetOrCreate('token', res.token);
      AppStorage.SetOrCreate('username', res.username);
      promptAction.showToast({ message: '登录成功' });
      router.pushUrl({ url: 'pages/HomePage' });
    } catch (e) {
      this.errorMsg = (e as Error).message ?? '登录失败';
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('登录').fontSize(26).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 })
      TextInput({ placeholder: '用户名', text: this.username }).onChange(v => this.username = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')
      TextInput({ placeholder: '密码', text: this.password }).type(InputType.Password).onChange(v => this.password = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')

      if (this.errorMsg) { Text(this.errorMsg).fontColor('#E53935').fontSize(14) }

      Button('登录', { type: ButtonType.Capsule }).width('88%').height(44).onClick(() => this.doLogin())

      Row({ space: 20 }) {
        Text('去注册').fontColor('#2979FF').onClick(() => router.pushUrl({ url: 'pages/RegisterPage' }))
        Text('忘记密码').fontColor('#2979FF').onClick(() => router.pushUrl({ url: 'pages/ForgotPasswordPage' }))
      }
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}
