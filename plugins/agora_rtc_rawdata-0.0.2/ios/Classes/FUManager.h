//
//  FUManager.h
//  agora_rtc_rawdata
//
//  Created by loop on 2021/05/18.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FUNamaHandleType) {
    FUNamaHandleTypeItem = 0,       /* items[0] ------ 放置 普通道具句柄    通常のアイテムハンドルを配置します*/ /*（包含很多，如：贴纸，aoimoji...若不单一存在，可放句柄集其他位置） */
    FUNamaHandleTypeBeauty = 1,     /* items[1] ------ 放置 美颜道具句柄    美容アイテムのハンドルを置きます*/
    FUNamaHandleTypeFxaa = 2,       /* items[2] ------ fxaa抗锯齿道具句柄 */
    FUNamaHandleTypeMakeup = 3,     /* items[3] ------ 美妆道具句柄 */
    FUNamaHandleTypeBodySlim = 4,   /* items[4] ------ 美体道具 */
    FUNamaHandleTypeBodyAvtar = 5,
    FUNamaHandleTotal = 6,
};

@interface FUManager : NSObject
@property (nonatomic, strong) dispatch_queue_t asyncLoadQueue;

+ (FUManager *)shareManager;

/* 加载bundle 到指定items位置   指定されたアイテムの場所にバンドルをロードします*/
- (void)loadBundleWithName:(NSString *)name aboutType:(FUNamaHandleType)type;

/*  处理视频  ビデオを処理する*/
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height;

- (void)destroyItem:(int)index;
- (void)destroyAllItems;

// Face Beautification.
- (void)enableFaceBeautification;
- (void)disableFaceBeautification;
- (void)setFaceBeautificationFilter:(NSString *)filterName
                        filterLevel:(NSNumber *)filterLevel;
- (void)setFaceBeautificationSkinWhitening:(NSNumber *)colorLevel;
- (void)setFaceBeautificationRuddy:(NSNumber *)redLevel;
- (void)setFaceBeautificationBlur:(NSNumber *)blurLevel
                       skinDetect:(NSNumber *)skinDetect
                 nonskinBlurScale:(NSNumber *)nonskinBlurScale
                        heavyBlur:(NSNumber *)heavyBlur
                   blurBlendRatio:(NSNumber *)blurBlendRatio;
- (void)setFaceBeautificationEyeBrighten:(NSNumber *)eyeBright;
- (void)setFaceBeautificationToothWhiten:(NSNumber *)toothWhiten;
- (void)setFaceBeautificationFaceOutline:(NSNumber *)faceShape
                          faceShapeLevel:(NSNumber *)faceShapeLevel
                            eyeEnlarging:(NSNumber *)eyeEnlarging
                           cheekThinning:(NSNumber *)cheekThinning
                       intensityForehead:(NSNumber *)intensityForehead
                           intensityChin:(NSNumber *)intensityChin
                           intensityNose:(NSNumber *)intensityNose
                          intensityMouth:(NSNumber *)intensityMouth;

@end

NS_ASSUME_NONNULL_END
