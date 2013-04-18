//
//  FSICacheImage.h
//  FSILib
//
//  Created by Guillaume Bonnin on 30/11/12.
//  Copyright (c) 2012 Guillaume Bonnin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSICacheImage : NSObject

typedef enum {
    kCompressionNone=1,
    kCompressionMedium=2,
    kCompressionMax=4,
}CompressionLevel;

// Save image in cache
// If thumbnailWithSize is different of CGSizeZero, a thumbnail is too create to the specify size
// Return true for success or nil for fail
+ (bool)saveImage:(UIImage *)image WithName:(NSString *)imageName Directory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size;

// Save image in cache without name
// If thumbnailWithSize is different of CGSizeZero, a thumbnail is too create to the specify size
// Name is create with the current timestamp
// Return the name of the image or nil if save fail
+ (NSString *)saveImage:(UIImage *)image WithDirectory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size;

// Save image of internet in cache
// If thumbnailWithSize is different of CGSizeZero, a thumbnail is too create to the specify size
// Return the name of the image or nil if save fail
+ (NSString *)saveImageWithUrlName:(NSString *)imageURLString Directory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size;

// Get image named 'imageName 'in cache
// Return nil if the image is not found
+ (UIImage *)getCachedImageNamed:(NSString *)imageName inDirectory:(NSString *)directory;

// Get thumbnail of the image named 'imageName' in cache
// Return nil if the image is not found
// If thumbnail don't exist, return the originate image
+ (UIImage *)getThumbnailCachedImageNamed:(NSString *)imageName inDirectory:(NSString *)directory;

// Delete image named 'imageName' in cache
// Return true for success or nil for fail
+ (bool)deleteCachedImageNamed:(NSString*)imageName inDirectory:(NSString *)directory;

@end