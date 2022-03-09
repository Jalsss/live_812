package android.src.main.java.io.agora.rtc.rawdata.base.faceunity;

/**
 * @author benyq
 * @time 2020/12/31
 * @e-mail 1520063035@qq.com
 * @note
 */
public class ModelParams {
    public static float sBlurLevel = 0.7f;// 精细磨皮程度
    public static float sColorLevel = 0.3f;// 美白
    public static float sRedLevel = 0.3f;// 红润
    public static float sEyeBright = 0.0f;// 亮眼
    public static float sToothWhiten = 0.0f;// 美牙
    public static float sMicroPouch = 0.0f;// 去黑眼圈
    public static float sMicroNasolabialFolds = 0.0f;// 去法令纹


    public static void setItemParam(String name, float param) {
        switch (name) {
            case FURenderer.BeautificationParams.BLUR_LEVEL:
                sBlurLevel = param;
                break;
            case FURenderer.BeautificationParams.COLOR_LEVEL:
                sColorLevel = param;
                break;
            case FURenderer.BeautificationParams.RED_LEVEL:
                sRedLevel = param;
                break;
            case FURenderer.BeautificationParams.EYE_BRIGHT:
                sEyeBright = param;
                break;
            case FURenderer.BeautificationParams.TOOTH_WHITEN:
                sToothWhiten = param;
                break;
            case "remove_pouch_strength":
                sMicroPouch = param;
                break;
            case "remove_nasolabial_folds_strength":
                sMicroNasolabialFolds = param;
                break;
        }
        FURenderer.isNeedUpdateFaceBeauty = true;
    }
}
