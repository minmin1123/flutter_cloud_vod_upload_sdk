package com.sirius.cloud_vod_upload_sdk.util;

import android.content.Context;
import android.graphics.Point;
import android.os.Build;
import android.view.WindowManager;
import android.widget.Toast;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

/*
 * Create by Chivan on 2020/07/06
 * Copyright © 2018 Tencent
 *
 * Description:
 */
public class Util {
    /**
     * 将秒数转换为日时分秒，
     *
     * @param second
     * @return
     */
    public static String formatTime(long second) {
        //转换天数
        final long days = second / 86400;
        //剩余秒数
        second = second % 86400;
        //转换小时
        final long hours = second / 3600;
        //剩余秒数
        second = second % 3600;
        //转换分钟
        final long minutes = second / 60;
        //剩余秒数
        second = second % 60;
        if (days > 0) {
            return days + "天" + hours + "小时" + minutes + "分" + second + "秒";
        } else {
            return hours + "小时" + minutes + "分" + second + "秒";
        }
    }

    /**
     * 获取文件大小
     * */
    public static String getFilePrintSize(long size) {
        //如果字节数少于1024，则直接以B为单位，否则先除于1024，后3位因太少无意义
        if (size < 1024) {
            return String.valueOf(size) + "B";
        } else {
            size = size / 1024;
        }
        //如果原字节数除于1024之后，少于1024，则可以直接以KB作为单位
        //因为还没有到达要使用另一个单位的时候
        //接下去以此类推
        if (size < 1024) {
            return String.valueOf(size) + "KB";
        } else {
            size = size / 1024;
        }
        if (size < 1024) {
            //因为如果以MB为单位的话，要保留最后1位小数，
            //因此，把此数乘以100之后再取余
            size = size * 100;
            return String.valueOf((size / 100)) + "."
                    + String.valueOf((size % 100)) + "MB";
        } else {
            //否则如果要以GB为单位的，先除于1024再作同样的处理
            size = size * 100 / 1024;
            return String.valueOf((size / 100)) + "."
                    + String.valueOf((size % 100)) + "GB";
        }
    }

    /**
     * 获取系统属性
     *
     * @param key
     * @param defaultValue
     * @return
     */
    public static String getSystemProperty(String key, String defaultValue) {
        try {
            Class<?> clz = Class.forName("android.os.SystemProperties");
            Method get = clz.getMethod("get", String.class, String.class);
            return (String) get.invoke(clz, key, defaultValue);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return defaultValue;
    }


    public static int getScreenWidth(Context context) {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Point point = new Point();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            //noinspection ConstantConditions
            wm.getDefaultDisplay().getRealSize(point);
        } else {
            //noinspection ConstantConditions
            wm.getDefaultDisplay().getSize(point);
        }
        return point.x;
    }

    /**
     * convert px to its equivalent dp
     * 将px转换为与之相等的dp
     */
    public static int px2dp(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    /**
     * 把dp类型的值进行屏幕自适应
     *
     * @param context
     * @param value
     * @return
     */
    public static double flexible(Context context, double value) {
        double threshold1 = 375.0;
        double threshold2 = 600.0;
        double designScreenWidth = 375.0;
        double screenWidth = getScreenWidth(context);
        if (screenWidth > threshold1 && screenWidth < threshold2) {
            screenWidth = threshold1;
        } else if (screenWidth >= threshold2) {
            screenWidth = screenWidth * 0.85;
        }
        screenWidth = px2dp(context, (float) screenWidth);
        double result = ((value * screenWidth) / designScreenWidth);
        return result;
    }

    /**
     * dp转px
     * */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 设置toast可以点击
     *
     * @param toast
     */
    public static void setToastClickable(Toast toast) {
        try {
            Object mTN;
            mTN = getField(toast, "mTN");
            if (mTN != null) {
                Object mParams = getField(mTN, "mParams");
                if (mParams != null
                        && mParams instanceof WindowManager.LayoutParams) {
                    WindowManager.LayoutParams params = (WindowManager.LayoutParams) mParams;
                    //Toast可点击
                    params.flags = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                            | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 反射字段
     *
     * @param object    要反射的对象
     * @param fieldName 要反射的字段名称
     */
    public static Object getField(Object object, String fieldName)
            throws NoSuchFieldException, IllegalAccessException {
        Field field = object.getClass().getDeclaredField(fieldName);
        if (field != null) {
            field.setAccessible(true);
            return field.get(object);
        }
        return null;
    }

    /**
     * 文件是否存在
     *
     * @param path 文件路径
     * */
    public static boolean isFileExist(String path) {
        File file = new File(path);
        return file.isFile();
    }
}
