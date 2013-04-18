//
//  FSICacheImage.m
//  FSILib
//
//  Created by Guillaume Bonnin on 30/11/12.
//  Copyright (c) 2012 Guillaume Bonnin. All rights reserved.
//

#import "FSICacheImage.h"
#import "FSIImageTransformations.h"

#define THUMBNAIL_EXTENSION @"thumbnail_"

@interface FSICacheImage ()
+(NSString*)getImagePathWithImageName:(NSString*)imageName Directory:(NSString *)directory andThumbnail:(bool)thumbnail;
+ (bool)deleteThumbnailImageNamed:(NSString *)imageName inDirectory:(NSString *)directory;
+ (bool)saveImage:(UIImage *)image WithName:(NSString *)imageName Directory:(NSString *)directory andCompressionLevel:(CompressionLevel)compressionLevel;
@end

@implementation FSICacheImage

#pragma mark - Save image

+ (bool)saveImage:(UIImage *)image WithName:(NSString *)imageName Directory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size
{
    if (![self saveImage:image WithName:imageName Directory:directory andCompressionLevel:compressionLevel])
        return false;
    
    // Save a thumbnail of the image if size different of CGSizeZero
    if (size.width != 0 && size.height != 0)
    {
        UIImage *thumbnail = [FSIImageTransformations createThumbnailofImage:image WithSize:size];
        NSString *thumbnailName = [NSString stringWithFormat:@"%@%@", THUMBNAIL_EXTENSION, imageName];
        [self saveImage:thumbnail WithName:thumbnailName Directory:directory andCompressionLevel:compressionLevel];
    }
    return true;
}

+ (NSString *)saveImage:(UIImage *)image WithDirectory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size;
{
    NSString *imageName = [NSString stringWithFormat:@"%f.png", [[NSDate date] timeIntervalSince1970]];
    
    if ([self saveImage:image WithName:imageName Directory:directory CompressionLevel:compressionLevel andThumbnailWithSize:size] == false)
        return nil;
    
    return imageName;
}

+ (NSString *)saveImageWithUrlName:(NSString *)imageURLString Directory:(NSString *)directory CompressionLevel:(CompressionLevel)compressionLevel andThumbnailWithSize:(CGSize)size
{
    NSString *imageName = [imageURLString lastPathComponent];
    
    // Fetch image
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    if (imageURL == nil)
    {
#if DEBUGX
        NSLog(@"Fail to save image '%@' because url is invalid", imageURLString);
#endif
        return nil;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:imageURL];
    if (data == nil)
    {
#if DEBUGX
        NSLog(@"Fail to save image '%@' because Internet connection appears to be offline.", imageURLString);
#endif
        return nil;
    }
    
    UIImage *image = [UIImage imageWithData:data];
    if ([self saveImage:image WithName:imageName Directory:directory CompressionLevel:compressionLevel andThumbnailWithSize:size] == false)
        return nil;
    
    return imageName;
}

#pragma mark - Get image

+ (UIImage *)getCachedImageNamed:(NSString *)imageName inDirectory:(NSString *)directory
{
    NSString *imagePath = [CacheImage getImagePathWithImageName:imageName Directory:directory andThumbnail:false];
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
#if DEBUGX
        NSLog(@"Found image: '%@'", imageName);
#endif
        return image;
    }
    
#if DEBUGX
    NSLog(@"Error: Not found image: %@", imagePath);
#endif
    
    return nil;
}

+ (UIImage *)getThumbnailCachedImageNamed:(NSString *)imageName inDirectory:(NSString *)directory
{
    NSString *imagePath = [CacheImage getImagePathWithImageName:imageName Directory:directory andThumbnail:true];
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
#if DEBUGX
        NSLog(@"Found thumbnail image: '%@'", imageName);
#endif
        return image;
    }
    
#if DEBUGX
    NSLog(@"Error: Not found thumbnail image: %@", imagePath);
#endif
    
    return [self getCachedImageNamed:imageName inDirectory:directory];
}

#pragma mark - Delete image

+(bool)deleteCachedImageNamed:(NSString*)imageName inDirectory:(NSString *)directory
{
    NSString *imagePath = [CacheImage getImagePathWithImageName:imageName Directory:directory andThumbnail:false];
    
#if DEBUGX
    NSLog(@"start delete cached image: %@", imagePath);
#endif
    if ([[NSFileManager defaultManager]fileExistsAtPath:imagePath])
    {
        NSError *error;
        bool success=[[NSFileManager defaultManager]removeItemAtPath:imagePath error:&error];
        if (!success || imagePath==nil)
        {
#if DEBUGX
            NSLog(@"Fail to delete cached image: %@", error.description);
#endif
            return false;
        }
        
        // delete the thumbnail of the image if it exist
        [self deleteThumbnailImageNamed:imageName inDirectory:directory];
        
        return true;
    }
    else
    {
#if DEBUGX
        NSLog(@"Fail to delete cached image: %@, the image didn't exist anymore.", imagePath);
#endif
        return false;
    }
}

#pragma mark - private functions

+(NSString*)getImagePathWithImageName:(NSString*)imageName Directory:(NSString *)directory andThumbnail:(bool)thumbnail
{
    NSError *error;
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    if (directory != nil)
        docsDir = [docsDir stringByAppendingString:directory];
    bool success=[[NSFileManager defaultManager] createDirectoryAtPath:docsDir withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!success)
    {
#if DEBUGX
        NSLog(@"CacheImage => error method getImagePath:%@", error.description);
#endif
        return nil;
    }
    else
    {
        if (thumbnail)
        {
            imageName = [NSString stringWithFormat:@"%@%@", THUMBNAIL_EXTENSION, imageName];
        }
        
        NSString *imagePath=[docsDir stringByAppendingPathComponent:imageName];
        return imagePath;
    }
}

+ (bool)deleteThumbnailImageNamed:(NSString *)imageName inDirectory:(NSString *)directory
{
    NSString *imagePath = [CacheImage getImagePathWithImageName:imageName Directory:directory andThumbnail:true];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:imagePath])
    {
#if DEBUGX
        NSLog(@"delete thumbnail of image: %@", imagePath);
#endif
        
        NSError *error;
        bool success=[[NSFileManager defaultManager]removeItemAtPath:imagePath error:&error];
        if (!success || imagePath==nil)
        {
#if DEBUGX
            NSLog(@"Fail to delete thumbnail of image: %@", error.description);
#endif
            return false;
        }
    }
    return true;
}

+ (bool)saveImage:(UIImage *)image WithName:(NSString *)imageName Directory:(NSString *)directory andCompressionLevel:(CompressionLevel)compressionLevel
{
    NSData *imageData;
    
    if (imageName == nil)
        return false;
    
    NSString *imagePath = [CacheImage getImagePathWithImageName:imageName Directory:directory andThumbnail:false];
    
#if DEBUGX
    NSLog(@"start copy of image '%@' in path '%@'", imageName, imagePath);
#endif
    
    // We delete old image if it already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        [CacheImage deleteCachedImageNamed:imageName inDirectory:directory];
    
    // Running the image representation function writes the data from the image to a file
    if([imageName rangeOfString:@".png" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        imageData = UIImagePNGRepresentation([FSIImageTransformations fixImageOrientation:image]);
    }
    else if([imageName rangeOfString:@".jpg" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [imageName rangeOfString:@".jpeg" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        // Define compression quality
        CGFloat compressionQuality = 1.0f;
        switch (compressionLevel)
        {
            case kCompressionMax: compressionQuality = 0; break;
            case kCompressionMedium: compressionQuality = 0.5f; break;
            case kCompressionNone: compressionQuality = 1.0f; break;
        }
        
        imageData = UIImageJPEGRepresentation([FSIImageTransformations fixImageOrientation:image], compressionQuality);
    }
    if (imageData == nil)
    {
#if DEBUGX
        NSLog(@"Fail to save image %@ because it appears invalid.", imageName);
#endif
        return false;
    }
    
    [imageData writeToFile:imagePath atomically:YES];
    return true;
}

@end
