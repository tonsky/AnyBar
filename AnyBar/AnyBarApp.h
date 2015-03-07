//
//  AnyBarApp.h
//  AnyBar
//
//  Created by Nikita Prokopov on 04/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface AnyBarApp : NSApplication

//
// OSA Scripting endpoints
// @see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_intro/SAppsIntro.html
// @see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ScriptableCocoaApplications/SApps_about_apps/SAppsAboutApps.html
//
-(id) osaImage;
-(void) setOsaImage:(id)imgName;

@end
