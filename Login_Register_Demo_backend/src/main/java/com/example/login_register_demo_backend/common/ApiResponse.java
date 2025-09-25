package com.example.login_register_demo_backend.common;

public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    private ApiResponse(boolean success, String message, T data) {
        this.success = success; this.message = message; this.data = data;
    }
    public static <T> ApiResponse<T> ok(T data) { return new ApiResponse<>(true, "ok", data); }
    public static <T> ApiResponse<T> fail(String msg) { return new ApiResponse<>(false, msg, null); }

    public boolean isSuccess() { return success; }
    public String getMessage() { return message; }
    public T getData() { return data; }
}
