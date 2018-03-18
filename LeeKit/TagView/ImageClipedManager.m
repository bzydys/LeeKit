//
//  ImageClipedManager.m
//  LeeKit
//
//  Created by Lee on 2018/2/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

#import "ImageClipedManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/message.h>

static inline NSUInteger cacheCostForImage(UIImage *image){
    return image.size.width * image.size.height * image.scale * image.scale;
}

@interface ImageClipedManager()

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) NSFileManager *fileManager;

@end

@implementation ImageClipedManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static ImageClipedManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self shared];
}

-(NSCache *)sharedCache{
    return self.cache;
}

-(instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCaches) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        self.shouldCache = YES;
        self.totalCostInMemory = 60 * 1024 * 1024; // 默认60M
        _cache = [[NSCache alloc] init];
        _cache.totalCostLimit = self.totalCostInMemory;
        _serialQueue = dispatch_queue_create("com.lee.imagecliped_serial_queue",
                                             DISPATCH_QUEUE_SERIAL);
        self.fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

-(void)clearCaches{
    [self.cache removeAllObjects];
}

+(UIImage *)clipedImageFromDiskWithKey:(NSString *)key{
    if (key && key.length) {
        NSString *subpath = [self md5:key];
        UIImage *image = nil;
        if ([ImageClipedManager shared].sharedCache) {
            image = [[ImageClipedManager shared].cache objectForKey:subpath];
            if (image) {
                return image;
            }
        }
        NSString *path = [[self cachePath] stringByAppendingPathComponent:subpath];
        image = [UIImage imageWithContentsOfFile:path];
        return image;
    }
    return nil;
    
}

+(void)clipedImageFromDiskWithKey:(NSString *)key completion:(CacheImage)completion{
    if (key && key.length) {
        dispatch_async([ImageClipedManager shared].serialQueue, ^{
            NSString *subpath = [self md5:key];
            
            UIImage *image = nil;
            if ([ImageClipedManager shared].shouldCache) {
                image = [[ImageClipedManager shared].cache objectForKey:subpath];
                
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(image);
                        }
                    });
                    return;
                }
            }
            
            NSString *path = [[self cachePath] stringByAppendingPathComponent:subpath];
            image = [UIImage imageWithContentsOfFile:path];
            
            if (image != nil && [ImageClipedManager shared].shouldCache) {
                NSUInteger cost = cacheCostForImage(image);
                [[ImageClipedManager shared].cache setObject:image forKey:subpath cost:cost];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(image);
                }
            });
        });
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

+(void)storeClipedImage:(UIImage *)clipedImage toDiskWithKey:(NSString *)key{
    if (clipedImage == nil || key == nil || key.length == 0) {
        return;
    }
    
    NSString *subpath = [self md5:key];
    
    if ([ImageClipedManager shared].shouldCache) {
        NSUInteger cost = cacheCostForImage(clipedImage);
        [[ImageClipedManager shared].cache setObject:clipedImage forKey:subpath cost:cost];
    }
    
    dispatch_async([ImageClipedManager shared].serialQueue, ^{
        if (![[ImageClipedManager shared].fileManager fileExistsAtPath:[self cachePath] isDirectory:nil]) {
            NSError *error = nil;
            BOOL isOK = [[ImageClipedManager shared].fileManager createDirectoryAtPath:[self cachePath]
                                                              withIntermediateDirectories:YES
                                                                               attributes:nil
                                                                                    error:&error];
            if (isOK && error == nil) {
                NSLog(@"create folder ClipedImages ok");
            } else {
                return;
            }
        }
        
        @autoreleasepool {
            NSString *path = [[self cachePath] stringByAppendingPathComponent:subpath];
            
            NSData *data = UIImageJPEGRepresentation(clipedImage, 1.0);
            BOOL isOk = [[ImageClipedManager shared].fileManager createFileAtPath:path
                                                                            contents:data
                                                                          attributes:nil];
            if (isOk) {
                NSLog(@"save cliped image to disk ok, key path is %@", path);

            } else {

                NSLog(@"save cliped image to disk fail, key path is %@", path);
            }
        }
    });
}

+(void)clearClipedImagesCache{
    dispatch_async([ImageClipedManager shared].serialQueue, ^{
        [[ImageClipedManager shared].cache removeAllObjects];
        
        NSString *directoryPath = [self cachePath];
        
        if ([[ImageClipedManager shared].fileManager fileExistsAtPath:directoryPath isDirectory:nil]) {
            NSError *error = nil;
            [[ImageClipedManager shared].fileManager removeItemAtPath:directoryPath error:&error];
            
            if (error) {
                NSLog(@"clear caches error: %@", error);
            } else {
                NSLog(@"clear caches ok");
            }
        }
    });
}

+ (unsigned long long)imagesCacheSize {
    NSString *directoryPath = [self cachePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[ImageClipedManager shared].fileManager fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[ImageClipedManager shared].fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[ImageClipedManager shared].fileManager attributesOfItemAtPath:path
                                                                                                      error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}

+(NSString *)cachePath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"ClipedImages"];
}

+(NSString *)md5:(NSString *)string{
    if (string == nil || [string length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    
    return [ms copy];
}

@end
