//
//  BUSArrowIndicatorView.m
//  BUStedDebug
//
//  Created by Lukas on 03/12/16.
//  Copyright © 2016 Lukas Fritzsche. All rights reserved.
//

#import "BUSArrowIndicatorView.h"



@implementation BUSArrowIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColorFromRGB(0xfde602) CGColor]));
    CGContextFillPath(ctx);
    
    UIImage *img = [UIImage imageNamed:@"arrow_smaller_black.png"];
    [img drawInRect:rect];
}


@end
