//
//  SOSPicker.m
//  SyncOnSet
//
//  Created by Christopher Sullivan on 10/25/13.
//
//

#import "SOSPicker.h"
#import "WPhotoViewController.h"
#define CDV_PHOTO_PREFIX @"cdv_photo_"

@implementation SOSPicker

@synthesize callbackId;

- (void) getPictures:(CDVInvokedUrlCommand *)command {
	NSDictionary *options = [command.arguments objectAtIndex: 0];

	NSInteger maximumImagesCount = [[options objectForKey:@"maximumImagesCount"] integerValue];
	self.width = [[options objectForKey:@"width"] integerValue];
	self.height = [[options objectForKey:@"height"] integerValue];
	self.quality = [[options objectForKey:@"quality"] integerValue];

	// Create the an album controller and image picker
	
    //**************wl***************
    self.callbackId = command.callbackId;
    WPhotoViewController *WphotoVC = [[WPhotoViewController alloc] init];
    //选择图片的最大数
    WphotoVC.selectPhotoOfMax = maximumImagesCount;
    WphotoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [WphotoVC setSelectPhotosBack:^(NSMutableArray *phostsArr) {
        NSMutableArray *photos = [[NSMutableArray alloc]init];
        CDVPluginResult* result = nil;
        NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
        NSError* err = nil;
        NSFileManager* fileMgr = [[NSFileManager alloc] init];
        NSString* filePath;
        for(NSData *data in phostsArr){
            int i=1;
            do {
                filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, @"jpg"];
            } while ([fileMgr fileExistsAtPath:filePath]);
            //
            @autoreleasepool{
                if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
                    break;
                } else {
                    NSString *encodedImageString = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    NSString *myStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",encodedImageString];
                    
                    [photos addObject:myStr];
                   // [photos addObject:[[NSURL fileURLWithPath:filePath] absoluteString]];
                }
            }
        }
        
        if (nil == result) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photos];
        }
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }];
    [self.viewController presentViewController:WphotoVC animated:YES completion:nil];
}



@end
