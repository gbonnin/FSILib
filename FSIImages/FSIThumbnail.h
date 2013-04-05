//
//  Thumbnail.h
//  FSILib
//
//  Created by Guillaume Bonnin on 05/04/13.
//  Copyright (c) 2013 Guillaume Bonnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSIThumbnail : NSObject

// Create and return a thumbnail
// Parameters are the image that will be resize and the sizes of the thumbnail
// Return nil if size is equal to CGSizeZero
+ (UIImage *)createThumbnailofImage:(UIImage *)image WithSize:(CGSize)size;

@end
