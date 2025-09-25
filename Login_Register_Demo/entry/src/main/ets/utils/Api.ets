// entry/src/main/ets/utils/Api.ets
import http from '@ohos.net.http';

export const BASE_URL: string = 'http://192.168.10.9:8080';

/** 后端统一返回壳 */
export interface ApiEnvelope<T> {
  success: boolean;
  message: string;
  data: T;
}

/** 业务返回体 */
export interface LoginResp { token: string; username: string; }
export interface Me { id: number; username: string; email?: string; }

/** 请求体类型定义（仅用于调用处构造 payload） */
export interface RegisterReq { username: string; password: string; email?: string; }
export interface LoginReq { username: string; password: string; }
export interface ForgotReq { username: string; newPassword: string; }

/** 显式请求头类型 */
interface HttpHeaders {
  'Content-Type': string;
  Authorization?: string;
}

/** 通用请求：body 只接受字符串（已在调用处 stringify） */
async function request<T>(
  path: string,
  method: http.RequestMethod,
  bodyStr?: string,
  token?: string
): Promise<T> {
  const client: http.HttpRequest = http.createHttp();
  try {
    const headers: HttpHeaders = { 'Content-Type': 'application/json' };
    if (token && token.length > 0) {
      headers.Authorization = `Bearer ${token}`;
    }

    const options: http.HttpRequestOptions = {
      method: method,
      connectTimeout: 8000,
      readTimeout: 10000,
      expectDataType: http.HttpDataType.STRING,
      header: headers,
      extraData: bodyStr
    };

    const resp: http.HttpResponse = await client.request(`${BASE_URL}${path}`, options);
    const text: string = String(resp.result ?? '');
    const env: ApiEnvelope<T> = JSON.parse(text) as ApiEnvelope<T>;
    if (!env.success) {
      const msg: string = env.message ? env.message : '请求失败';
      throw new Error(msg);
    }
    return env.data;
  } finally {
    client.destroy();
  }
}

/** 业务 API（全部显式泛型 + 先 stringify 再传） */
export async function apiRegister(username: string, password: string, email?: string): Promise<string> {
  const payload: RegisterReq = { username: username, password: password, email: email };
  const body: string = JSON.stringify(payload);
  const data: string = await request<string>('/api/auth/register', http.RequestMethod.POST, body);
  return data; // 例如 "注册成功"
}

export async function apiLogin(username: string, password: string): Promise<LoginResp> {
  const payload: LoginReq = { username: username, password: password };
  const body: string = JSON.stringify(payload);
  const data: LoginResp = await request<LoginResp>('/api/auth/login', http.RequestMethod.POST, body);
  return data;
}

export async function apiForgot(username: string, newPassword: string): Promise<string> {
  const payload: ForgotReq = { username: username, newPassword: newPassword };
  const body: string = JSON.stringify(payload);
  const data: string = await request<string>('/api/auth/forgot', http.RequestMethod.POST, body);
  return data;
}

export async function apiMe(token: string): Promise<Me> {
  const data: Me = await request<Me>('/api/auth/me', http.RequestMethod.GET, undefined, token);
  return data;
}

export async function apiLogout(token: string): Promise<string> {
  const data: string = await request<string>('/api/auth/logout', http.RequestMethod.POST, undefined, token);
  return data;
}
