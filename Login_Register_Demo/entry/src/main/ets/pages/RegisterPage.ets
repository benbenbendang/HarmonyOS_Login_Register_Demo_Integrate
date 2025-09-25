import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { apiRegister } from '../utils/Api';

@Entry
@Component
struct RegisterPage {
  @State username: string = ''
  @State password: string = ''
  @State confirm: string = ''
  @State email: string = ''
  @State errorMsg: string = ''

  private async doRegister() {
    this.errorMsg = '';
    if (this.password !== this.confirm) {
      this.errorMsg = '两次密码不一致'; return;
    }
    try {
      await apiRegister(this.username, this.password, this.email);
      promptAction.showToast({ message: '注册成功，请登录' });
      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (e) {
      this.errorMsg = (e as Error).message ?? '注册失败';
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('注册').fontSize(26).fontWeight(FontWeight.Bold).margin({ top: 40, bottom: 20 })
      TextInput({ placeholder: '用户名', text: this.username }).onChange(v => this.username = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')
      TextInput({ placeholder: '邮箱（可选）', text: this.email }).onChange(v => this.email = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')
      TextInput({ placeholder: '密码', text: this.password }).type(InputType.Password).onChange(v => this.password = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')
      TextInput({ placeholder: '确认密码', text: this.confirm }).type(InputType.Password).onChange(v => this.confirm = v)
        .width('88%').height(48).borderRadius(12).padding(12).backgroundColor('#F5F6FA')

      if (this.errorMsg) { Text(this.errorMsg).fontColor('#E53935').fontSize(14) }

      Button('注册', { type: ButtonType.Capsule }).width('88%').height(44).onClick(() => this.doRegister())
      Text('返回登录').fontColor('#2979FF').onClick(() => router.back())
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}
