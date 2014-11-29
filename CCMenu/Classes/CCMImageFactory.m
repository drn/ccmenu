
#import "CCMImageFactory.h"
#import "CCMProject.h"
#import "CCMProjectStatus.h"


@implementation CCMImageFactory

- (NSImage *)imageNamed:(NSString *)name
{
	NSImage *image = [NSImage imageNamed:name];
	if(image == nil)
	{
		// This is a hack to make the unit tests work when run from otool, in which case imageNamed: doesn't work
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"CCMenu/Images/%@", name]];
		image = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
        if(image == nil)
        {
            // Hack to make it work in AppCode...
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"CCMenu.app/Contents/Resources/%@", name]];
            image = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
        }
		[image setName:[name substringToIndex:[name length] - [[name pathExtension] length] - 1]];
	}
	return image;	
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status
{
    if(status == nil)
        return [self imageForUnavailableServer];

    NSString *name = @"";
    if([[status activity] isEqualToString:@"Building"])
    {
        if([status buildDidFail])
            name = @"icon-failure-building";
        else
            name = @"icon-success-building";
    }
    else
    {
        if([status buildWasSuccessful])
            name = @"icon-success";
        else if([status buildDidFail])
            name = @"icon-failure";
        else if([[status lastBuildStatus] isEqualToString:@"Unknown"])
            name = @"icon-pause";
        else
            name = @"icon-inactive";
    }
    return [self imageNamed:name];
}

- (NSImage *)imageForUnavailableServer
{
	return [self imageNamed:@"icon-inactive"];
}

- (NSImage *)convertForMenuUse:(NSImage *)originalImage
{
	NSString *name = [NSString stringWithFormat:@"%@-menu", [originalImage name]];
	NSImage *menuImage = [NSImage imageNamed:name];
	if(menuImage == nil)
	{
        menuImage = [NSImage imageWithSize:NSMakeSize(15, 17) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            [originalImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            return YES;
        }];
		[menuImage setName:name];
	}
	return menuImage;
}

- (NSImage *)convertForItemUse:(NSImage *)originalImage
{
    NSString *name = [NSString stringWithFormat:@"%@-item", [originalImage name]];
    NSImage *itemImage = [NSImage imageNamed:name];
   	if(itemImage == nil)
   	{
           itemImage = [NSImage imageWithSize:NSMakeSize(15, 17) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
               [originalImage drawAtPoint:NSMakePoint(0, 0.5) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
               return YES;
           }];
   		[itemImage setName:name];
   	}
   	return itemImage;
}

@end
