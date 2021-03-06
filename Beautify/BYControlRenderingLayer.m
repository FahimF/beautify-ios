//
//  BYControlRenderingLayer.m
//  Beautify
//
//  Created by Chris Grant on 26/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYControlRenderingLayer.h"
#import "BYGradientStop.h"
#import "BYRenderUtils.h"
#import "BYStyleRenderer_Private.h"
#import "BYBackgroundImage.h"

@implementation BYControlRenderingLayer {
    BYStyleRenderer* _renderer;
    BOOL _useSuppliedState;
    UIControlState _state;
    CGRect originalFrame;
}

-(id)initWithRenderer:(BYStyleRenderer*)renderer {
    if (self = [super init] ) {
        _renderer = renderer;
        _useSuppliedState = NO;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

-(id)initWithRenderer:(BYViewRenderer*)renderer state:(UIControlState)state {
    if (self = [super init] ) {
        _renderer = renderer;
        _useSuppliedState = YES;
        _state = state;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    BYShadow *outerShadow = [self propertyValue:@"outerShadow"];
    BYBorder *border = [self propertyValue:@"border"];
    originalFrame = frame;
    
    if(outerShadow || border) {
        UIEdgeInsets insets = ComputeExpandingInsetsForShadowAndBorder(outerShadow, border, YES);
        
        // Inflate the frame to make space for outer shadow
        frame = UIEdgeInsetsInsetRect(frame, insets);
        
        // Move the origin of the 'original' frame to compensate
        originalFrame.origin = CGPointMake(-frame.origin.x, -frame.origin.y);
    }
    
    self.masksToBounds = NO;
    [super setFrame:frame];
}

-(void)drawInContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);
    [self drawLayerInRect:originalFrame withContext:ctx];
    UIGraphicsPopContext();
}

-(id)propertyValue:(NSString*)propertyName {
    if (_useSuppliedState) {
        return [_renderer propertyValueForName:propertyName forState:_state];
    }
    else {
        return [_renderer propertyValueForNameWithCurrentState:propertyName];
    }
}

-(void)drawLayerInRect:(CGRect)rect withContext:(CGContextRef)ctx {
    BYShadow *outerShadow = [self propertyValue:@"outerShadow"];
    UIColor* backgroundColor = [self propertyValue:@"backgroundColor"];
    BYGradient *backgroundGradient = [self propertyValue:@"backgroundGradient"];
    BYShadow *innerShadow = [self propertyValue:@"innerShadow"];
    BYBorder *border = [self propertyValue:@"border"];
    BYBackgroundImage *backgroundImage = [self propertyValue:@"backgroundImage"];
    
    // a rounded rectangle bezier path that describes the layer
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                         cornerRadius:border.cornerRadius];
    if(self.customPath) {
        layerPath = self.customPath;
    }
    
    // Draw the outer shadow
    RenderOuterShadow(ctx, outerShadow, layerPath);
    
    if(backgroundColor) {
        [backgroundColor setFill];
        [layerPath fill];
    }
    
    // Create a new context to render the background layers that we have to clip.
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, layerPath.CGPath);
        CGContextClip(ctx);
        
        // Draw the background gradient
        if (backgroundGradient.stops.count > 0) {
            RenderGradient(backgroundGradient, ctx, originalFrame);
        }
        
        // Draw the background image
        if (backgroundImage) {
            UIImage *image = [backgroundImage data];
            CGImageRef imageRef = image.CGImage;
            
            if(backgroundImage.contentMode == BYImageContentModeAspectFill) {
                // There's no built in way to make an image use aspect fill, so calculate a new frame.
                CGSize rectSize = rect.size;
                CGFloat horizontalRatio = rectSize.width / CGImageGetWidth(imageRef);
                CGFloat verticalRatio = rectSize.height / CGImageGetHeight(imageRef);
                CGFloat ratio = MAX(horizontalRatio, verticalRatio); // The ratio is the biggest of the v & h ratio
                // Calculate a new size based on the ratio
                CGSize aspectFillSize = CGSizeMake(CGImageGetWidth(imageRef) * ratio, CGImageGetHeight(imageRef) * ratio);
                
                // Calculate the final frame, centered on the original frame, then draw the image in this.
                CGRect r = CGRectMake((rectSize.width-aspectFillSize.width)/2,
                                      (rectSize.height-aspectFillSize.height)/2,
                                      aspectFillSize.width,
                                      aspectFillSize.height);
                
                CGContextTranslateCTM(ctx, 0, rect.size.height);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextDrawImage(ctx, r, imageRef);
            }
            else if (backgroundImage.contentMode == BYImageContentModeFill) {
                CGContextTranslateCTM(ctx, 0, rect.size.height);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextDrawImage(ctx, rect, imageRef);
            }
            else if (backgroundImage.contentMode == BYImageContentModeTile) {
                CGContextTranslateCTM(ctx, 0, image.size.height / self.contentsScale);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextDrawTiledImage(ctx, CGRectMake(0, 0, image.size.width / self.contentsScale, image.size.height / self.contentsScale), imageRef);
            }
        }
        
        RenderInnerShadow(ctx, innerShadow, layerPath);
    }
    CGContextRestoreGState(ctx);
    
    // Draw the border. This is outside the block above because we don't want to clip the border.
    if (border.width > 0) {
        CGContextSetStrokeColorWithColor(ctx, border.color.CGColor);
        layerPath.lineWidth = border.width;
        [layerPath stroke];
    }
}

-(id<CAAction>)actionForKey:(NSString *)key {
    // This stops the animation of the layer when drawInContext is called.
    if ([key isEqualToString: @"contents"]) {
        return nil;
    }
    return [super actionForKey:key];
}

@end