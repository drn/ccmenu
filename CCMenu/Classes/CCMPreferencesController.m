
#import "CCMPreferencesController.h"
#import "CCMConnection.h"
#import "NSArray+EDExtensions.h"
#import "NSAppleScript+EDAdditions.h"
#import "CCMKeychainHelper.h"
#import "CCMAddProjectsController.h"

#define WINDOW_TITLE_HEIGHT 78


NSString *CCMPreferencesChangedNotification = @"CCMPreferencesChangedNotification";


@implementation CCMPreferencesController

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
		[NSBundle loadNibNamed:@"Preferences" owner:self];
		[preferencesWindow center];
		[preferencesWindow setToolbar:[self createToolbarWithName:@"Preferences"]];
		[[preferencesWindow toolbar] setSelectedItemIdentifier:@"Projects"];
		[self switchPreferencesPane:self];
        NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		[versionField setStringValue:[NSString stringWithFormat:@"%@ (r%@)", shortVersion, version]];
	}
    [soundNamesViewController setContent:[self availableSounds]];
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (void)switchPreferencesPane:(id)sender
{
	NSString *selectedIdentifier = [[preferencesWindow toolbar] selectedItemIdentifier];
	NSUInteger index = [[self toolbarDefaultItemIdentifiers:nil] indexOfObject:selectedIdentifier];
	NSArray *allViews = [NSArray arrayWithObjects:projectsView, notificationPrefsView, advancedPrefsView, aboutView, nil];
	NSView *prefView = [allViews objectAtIndex:index];
	NSDictionary *itemDef = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:selectedIdentifier];
	[preferencesWindow setTitle:[itemDef objectForKey:@"label"]]; 
    
	NSRect windowFrame = [preferencesWindow frame];
	windowFrame.size.height = [prefView frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [prefView frame].size.width;
	windowFrame.origin.y = NSMaxY([preferencesWindow frame]) - ([prefView frame].size.height + WINDOW_TITLE_HEIGHT);
	
	if([[paneHolderView subviews] count] > 0)
		[[[paneHolderView subviews] firstObject] removeFromSuperview];
	[preferencesWindow setFrame:windowFrame display:YES animate:(sender != self)];
	
	[paneHolderView setFrame:[prefView frame]];
	[paneHolderView addSubview:prefView];
}

- (void)addProjects:(id)sender
{
    // slightly naughty but we want to split the XIB files eventually
    [addProjectsController setValue:defaultsManager forKey:@"defaultsManager"];
    [addProjectsController beginSheetForWindow:preferencesWindow];
}

- (void)removeProjects:(id)sender
{
	[allProjectsViewController remove:sender];
	[self preferencesChanged:sender];
}

- (void)editProject:(id)sender
{
    // slightly naughty but we want to split the XIB files eventually
    [editProjectController setValue:defaultsManager forKey:@"defaultsManager"];
    [editProjectController beginSheetForWindow:preferencesWindow];
}

- (NSArray *)availableSounds
{
    NSMutableArray *sounds = [NSMutableArray arrayWithObject:@"-"];
    for(NSString *libPath in NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES)) 
    {
        NSString *soundLibPath = [libPath stringByAppendingPathComponent:@"Sounds"];
        for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundLibPath error:nil]) 
        {
            if([filename hasPrefix:@"."] == NO)
                [sounds addObject:[filename stringByDeletingPathExtension]];
        }
    }
    return sounds;
}

- (void)soundSelected:(id)sender
{
    [[NSSound soundNamed:[sender title]] play];
}

- (IBAction)openNotificationPreferences:(id)sender
{
    [[NSAppleScript scriptWithName:@"handlers"] callHandler:@"open_notifications"];
}

- (void)preferencesChanged:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

- (IBAction)updateIntervalChanged:(id)sender
{
	[updater setUpdateCheckInterval:(NSTimeInterval)[sender selectedTag]];
}

- (IBAction)checkForUpdateNow:(id)sender
{
    [updater checkForUpdates:sender];
}

@end
