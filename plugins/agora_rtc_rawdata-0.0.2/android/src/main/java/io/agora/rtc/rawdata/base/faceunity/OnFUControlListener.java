package android.src.main.java.io.agora.rtc.rawdata.base.faceunity;



import java.util.List;

import io.agora.rtc.rawdata.base.faceunity.entity.Effect;
import io.agora.rtc.rawdata.base.faceunity.entity.MakeupItem;


/**
 * FURenderer与界面之间的交互接口
 */
public interface OnFUControlListener {

    /**
     * 道具贴纸选择
     *
     * @param effectItemName 道具贴纸文件名
     */
    void onEffectSelected(Effect effectItemName);

    /**
     * Enable Face Beautification.
     */
    void onEnableFaceBeautification();

    /**
     * Disable Face Beautification.
     */
    void onDisableFaceBeautification();

    /**
     * Face Beautification Filter.
     * @param filterName
     * @param filterLevel
     */
    void onFilterSelected(String filterName, Double filterLevel);

    /**
     * Face Beautification Skin Whitening.
     * @param colorLevel
     */
    void onSkinWhiteningSelected(Double colorLevel);

    /**
     * Face Beautification Ruddy.
     * @param redLevel
     */
    void onRuddySelected(Double redLevel);

    /**
     * Face Beautification Blur.
     * @param blurLevel
     * @param skinDetect
     * @param nonskinBlurScale
     * @param heavyBlur
     */
    void onBlurSelected(Double blurLevel, Integer skinDetect, Double nonskinBlurScale, Integer heavyBlur);

    /**
     * Face Beautification Eye Bright.
     * @param eyeBright
     */
    void onEyeBrightenSelected(Double eyeBright);

    /**
     * Face Beautification Tooth Whiten.
     * @param toothWhiten
     */
    void onToothWhitenSelected(Double toothWhiten);

    /**
     * Face Beautification Face Outline.
     * @param faceShape
     * @param faceShapeLevel
     * @param eyeEnlarging
     * @param cheekThinning
     * @param intensityForehead
     * @param intensityChin
     * @param intensityNose
     * @param intensityMouth
     */
    void onFaceOutlineSelected(Integer faceShape, Double faceShapeLevel, Double eyeEnlarging, Double cheekThinning, Double intensityForehead, Double intensityChin, Double intensityNose, Double intensityMouth);

    /**
     * 滤镜强度
     *
     * @param progress 滤镜强度
     */
    void onFilterLevelSelected(float progress);

    /**
     * 滤镜选择
     *
     * @param filterName 滤镜名称
     */
    void onFilterNameSelected(String filterName);

    /**
     * 精准磨皮
     *
     * @param isOpen 是否开启精准磨皮（0关闭 1开启）
     */
    void onSkinDetectSelected(float isOpen);

    /**
     * 美肤类型
     *
     * @param isOpen 0:清晰美肤 1:朦胧美肤
     */
    void onHeavyBlurSelected(float isOpen);

    /**
     * 磨皮选择
     *
     * @param level 磨皮level
     */
    void onBlurLevelSelected(float level);

    /**
     * 美白选择
     *
     * @param level 美白
     */
    void onColorLevelSelected(float level);

    /**
     * 红润
     */
    void onRedLevelSelected(float level);

    /**
     * 亮眼
     */
    void onEyeBrightSelected(float level);

    /**
     * 美牙
     */
    void onToothWhitenSelected(float level);

    /**
     * 大眼选择
     *
     * @param level 大眼
     */
    void onEyeEnlargeSelected(float level);

    /**
     * 瘦脸选择
     *
     * @param level 瘦脸
     */
    void onCheekThinningSelected(float level);

    /**
     * 下巴
     */
    void onIntensityChinSelected(float level);

    /**
     * 额头
     */
    void onIntensityForeheadSelected(float level);

    /**
     * 瘦鼻
     */
    void onIntensityNoseSelected(float level);


    /**
     * 嘴形
     */
    void onIntensityMouthSelected(float level);

    /**
     * 窄脸选择
     *
     * @param level
     */
    void onCheekNarrowSelected(float level);

    /**
     * 小脸选择
     *
     * @param level
     */
    void onCheekSmallSelected(float level);

    /**
     * V脸选择
     *
     * @param level
     */
    void onCheekVSelected(float level);


    /**
     * 调节多个妆容（轻美妆，质感美颜）
     *
     * @param makeupItems
     */
    void onLightMakeupBatchSelected(List<MakeupItem> makeupItems);

    /**
     * 妆容总体调节（轻美妆，质感美颜）
     *
     * @param level
     */
    void onLightMakeupOverallLevelChanged(float level);

    void onFaceShapeSelected(float faceShape);


    /**
     * 选择美妆妆容
     *
     * @param paramMap
     * @param removePrevious
     */
//    void selectMakeupItem(Map<String, Object> paramMap, boolean removePrevious);

    /**
     * 调节美妆妆容强度
     *
     * @param name
     * @param density
     */
//    void setMakeupItemIntensity(String name, double density);

    /**
     * 设置美妆妆容颜色
     *
     * @param name
     * @param colors RGBA color
     */
//    void setMakeupItemColor(String name, double[] colors);

}
