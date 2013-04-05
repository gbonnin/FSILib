//
//  Thumbnail.m
//  FSILib
//
//  Created by Guillaume Bonnin on 05/04/13.
//  Copyright (c) 2013 Guillaume Bonnin. All rights reserved.
//

#import "FSIThumbnail.h"

@implementation FSIThumbnail

+ (UIImage *)createThumbnailofImage:(UIImage *)image WithSize:(CGSize)size
{
    UIImage *thumbnail = nil;
    if (size.width != 0 && size.height != 0)
    {
        thumbnail = image;//[UIImage imageWithCIImage:image.CIImage];
        UIGraphicsBeginImageContext(size);
        [thumbnail drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIGraphicsEndImageContext();
    }
    return thumbnail;
}

@end
