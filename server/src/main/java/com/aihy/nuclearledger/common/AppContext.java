package com.aihy.nuclearledger.common;

/**
 * ThreadLocal holder for current request's appId.
 * Set by JwtAuthenticationFilter or AuthController.
 */
public class AppContext {

    private static final ThreadLocal<Long> APP_ID = new ThreadLocal<>();

    public static void setAppId(Long appId) {
        APP_ID.set(appId);
    }

    public static Long getAppId() {
        return APP_ID.get();
    }

    public static void clear() {
        APP_ID.remove();
    }

}
