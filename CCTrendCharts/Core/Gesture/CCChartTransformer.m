//
//  CCChartTransformer.m
//  CCTrendCharts
//
//  Created by Cocos on 2019/9/19.
//  Copyright © 2019 Cocos. All rights reserved.
//

#import "CCChartTransformer.h"

@interface CCChartTransformer () {
    // 偏差矩阵
    CGAffineTransform _offsetMatrix;
    // 标准矩阵
    CGAffineTransform _matrix;
}

/**
 视图放大缩小的所有信息都存放在CCChartViewHandler对象中, 结合matrixValueToPx可以计算出元素最终位置
 */
@property (nonatomic, strong) CCChartViewPixelHandler *viewPixelHandler;

@end


@implementation CCChartTransformer

- (instancetype)initWithViewPixelHandler:(CCChartViewPixelHandler *)viewPixelHandler {
    self = [super init];
    if (self) {
        _matrix = CGAffineTransformIdentity;
        _offsetMatrix = CGAffineTransformIdentity;
        _viewPixelHandler = viewPixelHandler;
    }
    return self;
}

- (void)refreshMatrix:(CGAffineTransform)matrix {
    _matrix = matrix;
}

- (void)refreshOffsetMatrix:(CGAffineTransform)offsetMatrix {
    _offsetMatrix = offsetMatrix;
}


- (CGPoint)pointToPixel:(CGPoint)point forAnimationPhaseY:(CGFloat)phaseY {
    return CGPointApplyAffineTransform(point, self.valueToPixelMatrix);
}

- (CGRect)rectToPixel:(CGRect)rect forAnimationPhaseY:(CGFloat)phaseY {
    return CGRectApplyAffineTransform(rect, self.valueToPixelMatrix);
}

- (CGPoint)pixelToPoint:(CGPoint)pixel forAnimationPhaseY:(CGFloat)phaseY {
    return CGPointApplyAffineTransform(pixel, self.pixelToValueMatrix);
}

- (CGRect)pixelToRect:(CGRect)pixel forAnimationPhaseY:(CGFloat)phaseY {
    return CGRectApplyAffineTransform(pixel, self.pixelToValueMatrix);
}

- (CGAffineTransform)calcMatrixWithMinValue:(CGFloat)minY maxValue:(CGFloat)maxY xSpace:(CGFloat)xSpace {
//    // 相邻两个元素之间中心轴的距离, 默认是8个点
//    CGAffineTransform transform = CGAffineTransformMakeScale(8, 1);
//
//    // 这里还需要对y方向进行动态计算缩放值, 算法原理如下:
//    // 1. 先获取y方向的范围, y方向和绘制区域的高度
//    // 2. 缩放值 = 高度 / 范围
//    CGFloat range = fabs(maxY - minY);
//    CGFloat scaleY = self.viewPixelHandler.contentHeight / range;
//    // 这里传入负数, 因为iOS坐标系里, 越向上数值越小
//    transform = CGAffineTransformScale(transform, 1, -scaleY);
//
//
//    // 注意这里都是在做了缩放之后的平移, 所以n表示n个单位, 对应的真实数据如下:
//    // x方向对应的实际数值是n*transform.a
//    // y方向对应的实际数值是n*transform.d
//    //
//    // 全部元素中心轴向右平移0.5个单位, 确保第一个数据实体不会和y轴重叠
//    transform = CGAffineTransformTranslate(transform, 0.5, 0);
//
//    // 根据y轴最小值, 处理y方向的平移量
//    // 算法原理如下:
//    // 平移量 = -minY*transform.d (这里对缩放后进行平移操作, 只需要传入最小值即可)
//    transform = CGAffineTransformTranslate(transform, 0, -minY);
    
    CGAffineTransform transform = [self calcMatrixOrientationX:xSpace];
    transform = CGAffineTransformConcat(transform, [self calcMatrixOrientationYWithMinValue:minY maxValue:maxY]);
    
    return transform;
}

- (CGAffineTransform)calcMatrixOrientationX:(CGFloat)space {
    // 相邻两个元素之间中心轴的距离
    CGAffineTransform transform = CGAffineTransformMakeScale(space, 1);
    
    // 注意这里都是在做了缩放之后的平移, 所以n表示n个单位, 对应的真实数据如下:
    // x方向对应的实际数值是n*transform.a
    // y方向对应的实际数值是n*transform.d
    //
    // 全部元素中心轴向右平移0.5个单位, 确保第一个数据实体不会和y轴重叠
    transform = CGAffineTransformTranslate(transform, CC_X_INIT_TRANSLATION, 0);
    
    return transform;
}

- (CGAffineTransform)calcMatrixOrientationYWithMinValue:(CGFloat)minY maxValue:(CGFloat)maxY {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
        
    // 这里还需要对y方向进行动态计算缩放值, 算法原理如下:
    // 1. 先获取y方向的范围, y方向和绘制区域的高度
    // 2. 缩放值 = 高度 / 范围
    CGFloat range = fabs(maxY - minY);
    CGFloat scaleY = self.viewPixelHandler.contentHeight / range;
    // 这里传入负数, 因为iOS坐标系里, 越向上数值越小
    transform = CGAffineTransformScale(transform, 1, -scaleY);
    
    // 根据y轴最小值, 处理y方向的平移量
    // 算法原理如下:
    // 平移量 = -minY*transform.d (这里对缩放后进行平移操作, 只需要传入最小值即可)
    transform = CGAffineTransformTranslate(transform, 0, -minY);
    
    return transform;
}

#pragma mark - Getter & Setter
- (CGAffineTransform)valueToPixelMatrix {

    // 这里手势gestureMatrix矩阵暂时是CGAffineTransformIdentity
    CGAffineTransform transform = CGAffineTransformConcat(_matrix, self.viewPixelHandler.gestureMatrix);
    transform = CGAffineTransformConcat(transform, _offsetMatrix);
    return transform;
}

- (CGAffineTransform)pixelToValueMatrix {
    // 直接返回标准矩阵的逆矩阵
    return CGAffineTransformInvert(self.valueToPixelMatrix);
}


@end
