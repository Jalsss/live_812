//
//  FUManager.m
//  agora_rtc_rawdata
//
//  Created by loop on 2021/05/18.
//

#import "FUManager.h"
#import "FURenderer.h"
#import "authpack.h"


@interface FUManager ()
{
    //MARK: Faceunity
    int items[FUNamaHandleTotal];
    int frameID;
}

@end

static FUManager *shareManager = NULL;

@implementation FUManager

+ (FUManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[FUManager alloc] init];
    });

    return shareManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _asyncLoadQueue = dispatch_queue_create("com.faceLoadItem", DISPATCH_QUEUE_SERIAL);

        [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];

        /* 加载AI模型    AIモデルをロードする*/
        [self loadAIModle];
        [FURenderer setMaxFaces:4]; //
        fuSetDefaultRotationMode(3);// 0 1 2 3
    }
    return self;
}

-(void)loadAIModle{
    NSData *ai_human_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_human_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_human_processor.bytes size:(int)ai_human_processor.length aitype:FUAITYPE_HUMAN_PROCESSOR];

    NSData *ai_face_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes size:(int)ai_face_processor.length aitype:FUAITYPE_FACEPROCESSOR];
}


- (void)loadBundleWithName:(NSString *)name aboutType:(FUNamaHandleType)type{
    dispatch_async(_asyncLoadQueue, ^{
        if (name == nil || name.length == 0) {
            return;
        }

        if (self->items[type] != 0) {
            NSLog(@"faceunity: destroy item");
            [FURenderer destroyItem:self->items[type]];
            self->items[type] = 0;
        }

        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        self->items[FUNamaHandleTypeItem] = [FURenderer itemWithContentsOfFile:filePath];

    });
}

/**処理 YUV*/
- (void)processFrameWithY:(void*)y U:(void*)u V:(void*)v yStride:(int)ystride uStride:(int)ustride vStride:(int)vstride FrameWidth:(int)width FrameHeight:(int)height {

    static int readerItems[2] = {0};
    readerItems[0] = items[FUNamaHandleTypeItem];
    readerItems[1] = items[FUNamaHandleTypeBeauty];

    [[FURenderer shareRenderer] renderFrame:y u:u  v:v  ystride:ystride ustride:ustride vstride:vstride width:width height:height frameId:frameID items:readerItems itemCount:2];
    frameID ++ ;
}
/// Single Prop Item Destruction.
///
- (void)destroyItem:(int)index{
    if (self->items[index] != 0) {
        [FURenderer destroyItem:self->items[index]];
    }
    self->items[index] = 0;
}

/// All Prop Items Destruction.
///
- (void)destroyAllItems{
    [FURenderer destroyAllItems];
    for (int i = 0; i < FUNamaHandleTotal; i++) {
        self->items[i] = 0;
    }
}

/// Enable Face Beautification.
///
- (void)enableFaceBeautification {
    dispatch_async(_asyncLoadQueue, ^{
        if (self->items[FUNamaHandleTypeBeauty] == 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
            self->items[FUNamaHandleTypeBeauty] = [FURenderer itemWithContentsOfFile:path];
        }
    });
}

/// Disable Face Beautification.
///
- (void)disableFaceBeautification {
    dispatch_async(_asyncLoadQueue, ^{
        [self destroyItem:FUNamaHandleTypeBeauty];
    });
}

/// Face Beautification - Filter.
///
- (void)setFaceBeautificationFilter:(NSString *)filterName
                        filterLevel:(NSNumber *)filterLevel {
    if ([filterName length] == 0) {
        NSLog(@"Filter Name is Empty.");
        return;
    }
//    NSLog(@"Filter\n\tfilter_name : %@\n\tfilter_level : %f", filterName, filterLevel.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"filter_name" value:filterName];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"filter_level" value:@(filterLevel.floatValue)];
    });
}

/// Face Beautification - Skin Whitening.
///
- (void)setFaceBeautificationSkinWhitening:(NSNumber *)colorLevel {
//    NSLog(@"SkinWhitening : %f", colorLevel.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"color_level" value:@(colorLevel.floatValue)];
    });
}

/// Face Beautification - Ruddy.
///
- (void)setFaceBeautificationRuddy:(NSNumber *)redLevel {
//    NSLog(@"Ruddy : %f", redLevel.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"red_level" value:@(redLevel.floatValue)];
    });
}

/// Face Beautification - Blur.
///
- (void)setFaceBeautificationBlur:(NSNumber *)blurLevel
                       skinDetect:(NSNumber *)skinDetect
                 nonskinBlurScale:(NSNumber *)nonskinBlurScale
                        heavyBlur:(NSNumber *)heavyBlur
                   blurBlendRatio:(NSNumber * )blurBlendRatio {
//    NSLog(@"Blur\n\tblur_level : %f\n\tskin_detect : %d\n\tnonskin_blur_scale : %f\n\theavy_blur : %d\n\tblur_blend_ratio : %f", blurLevel.floatValue, skinDetect.intValue, nonskinBlurScale.floatValue, heavyBlur.intValue, blurBlendRatio.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"blur_level" value:@(blurLevel.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"skin_detect" value:@(skinDetect.intValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"nonskin_blur_scale" value:@(nonskinBlurScale.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"heavy_blur" value:@(heavyBlur.intValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"blur_blend_ratio" value:@(blurBlendRatio.floatValue)];
    });
}

/// Face Beautification - Eye Brighten.
///
- (void)setFaceBeautificationEyeBrighten:(NSNumber *)eyeBright {
//    NSLog(@"EyeBrighten : %f", eyeBright.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"eye_bright" value:@(eyeBright.floatValue)];
    });
}

/// Face Beautification - Tooth Whiten.
///
- (void)setFaceBeautificationToothWhiten:(NSNumber *)toothWhiten {
//    NSLog(@"ToothWhiten : %f", toothWhiten.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"tooth_whiten" value:@(toothWhiten.floatValue)];
    });
}

/// Face Beautification - Face Outline Beautification.
///
- (void)setFaceBeautificationFaceOutline:(NSNumber *)faceShape
                          faceShapeLevel:(NSNumber *)faceShapeLevel
                            eyeEnlarging:(NSNumber *)eyeEnlarging
                           cheekThinning:(NSNumber *)cheekThinning
                       intensityForehead:(NSNumber *)intensityForehead
                           intensityChin:(NSNumber *)intensityChin
                           intensityNose:(NSNumber *)intensityNose
                          intensityMouth:(NSNumber *)intensityMouth {
//    NSLog(@"Face Outline Beautification\n\tface_shape : %d\n\tface_shape_level : %f\n\teye_enlarging : %f\n\tcheek_thinning : %f\n\tintensity_forehead : %f\n\tintensity_chin : %f\n\tintensity_nose : %f\n\tintensity_mouth : %f", faceShape.intValue, faceShapeLevel.floatValue, eyeEnlarging.floatValue, cheekThinning.floatValue, intensityForehead.floatValue,intensityChin.floatValue, intensityNose.floatValue, intensityMouth.floatValue);
    dispatch_async(_asyncLoadQueue, ^{
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"face_shape" value:@(faceShape.intValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"face_shape_level" value:@(faceShapeLevel.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"eye_enlarging" value:@(eyeEnlarging.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"cheek_thinning" value:@(cheekThinning.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"intensity_forehead" value:@(intensityForehead.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"intensity_chin" value:@(intensityChin.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"intensity_nose" value:@(intensityNose.floatValue)];
        [FURenderer itemSetParam:self->items[FUNamaHandleTypeBeauty] withName:@"intensity_mouth" value:@(intensityMouth.floatValue)];
    });
}

@end
