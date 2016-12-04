//
//  BUSArrowIndicatorView.m
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import "BUSArrowIndicatorView.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)



@implementation BUSArrowIndicatorView {
    UIImage *arrow;
    UIColor *circleColor;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        arrow = [UIImage imageNamed:@"arrow_smaller_black.png"];
        circleColor = UIColorFromRGB(0xfde602);
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //draw circle
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([circleColor CGColor]));
    CGContextFillPath(ctx);
    
    
    [arrow drawInRect:rect];
}

- (void) reachedDestination {
    circleColor = UIColorFromRGB(0x00CA70);
    [self setNeedsDisplay];
}

- (void)rotateArrowBy:(CGFloat) degrees {
    
    double rads = DEGREES_TO_RADIANS(degrees);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    self.transform = transform;
}

@end
