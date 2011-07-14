//
//  ISDJustSayinAppDelegate.m
//  ISDJustSayin
//
//  Created by Rob Lourens on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ISDJustSayinAppDelegate.h"

@implementation ISDJustSayinAppDelegate


@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize facebook=_facebook;

- (UINavigationController *)makeTabVCWithSource:(JSSourceType)source {
    JSListVC *vc = [[JSListVC alloc] initWithSource:source];
    switch (source) {
        case JSHome:
            vc.title = @"Home";
            break;
        case JSBest:
            vc.title = @"Best Sayin's";
            break;
        case JSWorst:
            vc.title = @"Worst Sayin's";
            break;            
        default:
            break;
    }
    
    [fbUIs addObject:vc];
    UINavigationController *navControllerTmp = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc release];
    return [navControllerTmp autorelease];
}

- (NSArray *)getAllTabVCs {
    NSMutableArray *tabVCs = [NSMutableArray arrayWithCapacity:3];
    [tabVCs addObject:[self makeTabVCWithSource:JSHome]];
    [tabVCs addObject:[self makeTabVCWithSource:JSBest]];
    [tabVCs addObject:[self makeTabVCWithSource:JSWorst]];
    
    return tabVCs;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    signedIn = NO;
    fbUIs = [[NSMutableArray alloc] init];
    facebook = [[Facebook alloc] initWithAppId:@"139732709422244"];
    
    [self.tabBarController setViewControllers:[self getAllTabVCs]];
    
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

// Called by VC when Sign In button is pressed
- (void)signin
{
    // Check for existing session
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"])
    {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // If the session is expired, non-existent, etc., prompt user to login or authorize app
    if (![facebook isSessionValid])
        [facebook authorize:nil delegate:self];
    // Otherwise, use the saved details
    else if ([defaults objectForKey:kUserNameDefaultsKey] == nil || [[defaults objectForKey:kUserNameDefaultsKey] isEqualToString:@""])
        [facebook requestWithGraphPath:@"me" andDelegate:self];
    else
        [self notifySignedIn:[defaults objectForKey:kUserNameDefaultsKey]];
}

// Acknowledge sign in to the user with alert view and whatever the VC wants to do
- (void)notifySignedIn:(NSString *)userName
{
    NSLog(@"Notifying login. Expires %@", [[facebook expirationDate] description]);
    NSString *confMessage = [NSString stringWithFormat:@"You have logged in successfully as %@.", userName];
    UIAlertView *loginConfirmationAlert = [[UIAlertView alloc] initWithTitle:@"Logged in!"
                                                                     message:confMessage 
                                                                    delegate:self 
                                                           cancelButtonTitle:@"Sweet" 
                                                           otherButtonTitles:nil];
    [loginConfirmationAlert show];
    [loginConfirmationAlert release];
    
    signedIn = YES;
    for (JSListVC *vc in fbUIs) [vc signedIn];
}

// Acknowledge logout to the user by sending the signal to all VCs
- (void)notifyLoggedOut
{
    signedIn = NO;
    for (JSListVC *vc in fbUIs) [vc logout];    
}

// Can be called by VC to do logout for all VCs (maybe weird but it makes sense, trust me)
- (void)logout
{
    [facebook logout:self];
}

// Called when a new signin completes successfully
- (void)fbDidLogin
{
    NSLog(@"logged in with new session successfully");
    // Update default once login is complete
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // Get the name
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)fbDidLogout {
    [self notifyLoggedOut];
    NSLog(@"Logged out successfully");
}

// Checks whether session is still valid, sends logout signal if not, returns whether a user is signed in
- (BOOL)checkSignedIn
{
    if (signedIn)
    {
        signedIn = [facebook isSessionValid];
        if (!signedIn) NSLog(@"Session expired");
    }
    
    if (!signedIn)
        [self notifyLoggedOut];
    
    return signedIn;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [facebook handleOpenURL:url]; 
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"FB request failed with an error: %@", [error localizedDescription]);

    UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Log in failed"
                                                               message:@"Sorry... could not connect to Facebook servers to log in."
                                                              delegate:self 
                                                     cancelButtonTitle:@"Cancel" 
                                                     otherButtonTitles:nil];
    [loginFailedAlert show];
    [loginFailedAlert release];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on the format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"Request loaded from url: %@", [request url]);

    NSDictionary *resultDict = (NSDictionary *)result;
    NSString *userName = [resultDict valueForKey:@"name"];
    
    // Save the user name to defaults, then notify logged in with it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:kUserNameDefaultsKey];
    [self notifySignedIn:userName];
}

- (NSString *)currentAccessToken {
    if ([self checkSignedIn])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults valueForKey:@"FBAccessTokenKey"];
    }
    else
        return nil;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
