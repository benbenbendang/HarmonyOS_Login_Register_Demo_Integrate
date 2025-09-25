import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { nowStr } from '../utils/Time';
import { apiLogout, apiMe, Me } from '../utils/Api';

@Entry
@Component
struct HomePage {
  @State username: string = '未知用户'
  @State now: string = nowStr()
  @State me: Me | null = null
  private tId: number = -1

  // ...省略上文
  aboutToAppear() {
    const token: string = AppStorage.Get<string>('token') ?? '';
    const name: string = AppStorage.Get<string>('username') ?? '未知用户';
    this.username = name;

    apiMe(token)
      .then((info: Me) => { this.me = info; })
      .catch((_e: Error) => { /* 可按需提示 */ });

    // ✅ 只做一次强转到 number，去掉 unknown
    const id = setInterval((): void => {
      this.now = nowStr();
    }, 1000) as number;
    this.tId = id;
  }

  aboutToDisappear() {
    if (this.tId !== -1) {
      clearInterval(this.tId);
      this.tId = -1;
    }
  }

  private async doLogout() {
    try {
      const token: string = AppStorage.Get<string>('token') ?? '';
      await apiLogout(token);
    } catch (_e) { /* 忽略 */ }
    AppStorage.Set('token', '');
    promptAction.showToast({ message: '已退出' });
    router.replaceUrl({ url: 'pages/LoginPage' });
  }
  // ...省略下文


  build() {
    Column({ space: 20 }) {
      Text('欢迎回来').fontSize(18).fontColor('#666')
      Text(this.username).fontSize(28).fontWeight(FontWeight.Bold)
      Text(`当前时间：${this.now}`).fontSize(18)

      if (this.me) {
        Text(`用户ID：${this.me.id}`).fontSize(16)
        Text(`邮箱：${this.me.email ?? '-'}`).fontSize(16)
      }

      Button('退出登录', { type: ButtonType.Capsule })
        .width(160).height(40)
        .onClick(() => this.doLogout())
    }
    .width('100%').height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
