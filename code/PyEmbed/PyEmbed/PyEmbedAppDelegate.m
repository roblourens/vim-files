//
//  PyEmbedAppDelegate.m
//  PyEmbed
//
//  Created by Rob Lourens on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PyEmbedAppDelegate.h"

@implementation PyEmbedAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *tst = [NSString stringWithFormat:@"%02d", 5];
    NSLog(tst);
}

@end
