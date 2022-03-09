package android.src.main.java.io.agora.rtc.rawdata.base.faceunity.entity;

import java.util.List;

/**
 * @author LiuQiang on 2018.11.15
 * 妆容组合     顔の組み合わせ
 */
public class FaceMakeup {
    // 无妆   normal
    public static final int FACE_MAKEUP_TYPE_NONE = -1;
    // 口红   口紅
    public static final int FACE_MAKEUP_TYPE_LIPSTICK = 0;
    // 腮红   赤面
    public static final int FACE_MAKEUP_TYPE_BLUSHER = 1;
    // 眉毛   眉
    public static final int FACE_MAKEUP_TYPE_EYEBROW = 2;
    // 眼影   アイシャドウ
    public static final int FACE_MAKEUP_TYPE_EYE_SHADOW = 3;
    // 眼线   アイライナー
    public static final int FACE_MAKEUP_TYPE_EYE_LINER = 4;
    // 睫毛    まつげ
    public static final int FACE_MAKEUP_TYPE_EYELASH = 5;
    // 美瞳    化粧品コンタクトレンズ
    public static final int FACE_MAKEUP_TYPE_EYE_PUPIL = 6;

    private List<MakeupItem> mMakeupItems;
    private int nameId;
    private int iconId;

    public FaceMakeup(List<MakeupItem> makeupItems, int nameId, int iconId) {
        mMakeupItems = makeupItems;
        this.nameId = nameId;
        this.iconId = iconId;
    }

    public List<MakeupItem> getMakeupItems() {
        return mMakeupItems;
    }

    public void setMakeupItems(List<MakeupItem> makeupItems) {
        mMakeupItems = makeupItems;
    }

    public int getNameId() {
        return nameId;
    }

    public void setNameId(int nameId) {
        this.nameId = nameId;
    }

    public int getIconId() {
        return iconId;
    }

    public void setIconId(int iconId) {
        this.iconId = iconId;
    }

    @Override
    public String toString() {
        return "FaceMakeup{" +
                "MakeupItems=" + mMakeupItems +
                ", name='" + nameId + '\'' +
                ", iconId=" + iconId +
                '}';
    }
}
