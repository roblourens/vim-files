//
//  ISDJustSayinAppDelegate.h
//  ISDJustSayin
//
//  Created by Rob Lourens on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSListVC.h"

#define kUserNameDefaultsKey @"JSUserName"

@interface ISDJustSayinAppDelegate : NSObject <UIApplicationDelegate,
                                                UITabBarControllerDelegate,
                                                FBSessionDelegate,
                                                FBRequestDelegate>
{
    Facebook *facebook;
    
    NSMutableArray *fbUIs;
    BOOL signedIn;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) Facebook *facebook;

- (NSArray *)getAllTabVCs;
- (UINavigationController *)makeTabVCWithSource:(JSSourceType)source;
- (void)signin;
- (void)logout;
- (BOOL)checkSignedIn;
- (void)notifySignedIn:(NSString *)userName;
- (void)notifyLoggedOut;
- (NSString *)currentAccessToken;

@end
