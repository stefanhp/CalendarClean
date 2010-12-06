//
//  CalendarCleanAppDelegate.m
//  CalendarClean
//
//  Created by Andrea on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarCleanAppDelegate.h"
#import <CalendarStore/CalendarStore.h>

@implementation CalendarCleanAppDelegate

@synthesize window;
@synthesize calPicker;
@synthesize selectedCalendarUID;
@dynamic calendarName;
- (NSString *)calendarName {
	if(selectedCalendarUID != nil){
		CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:selectedCalendarUID];
		if(calendar != nil){
			return [calendar title];
		}
	}
	return NSLocalizedStringWithDefaultValue(@"INVALID_CAL_UID", 
											 @"CalendarClean", 
											 [NSBundle mainBundle], 
											 @"<No iCal Calendar selected>", 
											 @"Error string for calendar name when no calendar is selected");
}

@dynamic calendarUID;
- (NSString *)calendarUID {
	if(selectedCalendarUID != nil){
		return selectedCalendarUID;
	}
	return NSLocalizedStringWithDefaultValue(@"INVALID_CAL_UID", 
											 @"CalendarClean", 
											 [NSBundle mainBundle], 
											 @"<No iCal Calendar selected>", 
											 @"Error string for calendar name when no calendar is selected");
}

@dynamic recurrentEvents;
- (NSArray *)recurrentEvents{
	if([self selectedCalendarUID]!= nil){
		NSInteger year = [[NSCalendarDate date] yearOfCommonEra];
		NSDate *startDate = [[NSCalendarDate dateWithYear:year month:1 day:1 hour:0 minute:0 second:0 timeZone:nil] retain];
		NSDate *endDate = [[NSCalendarDate dateWithYear:year month:12 day:31 hour:23 minute:59 second:59 timeZone:nil] retain];
		NSArray *calendars = [NSArray arrayWithObject:[[CalCalendarStore defaultCalendarStore] calendarWithUID:[self selectedCalendarUID]]];
		NSPredicate *eventsForThisYear = [CalCalendarStore eventPredicateWithStartDate:startDate endDate:endDate calendars:calendars];
		
		// Fetch all events for this year
		NSArray *events = [[CalCalendarStore defaultCalendarStore] eventsWithPredicate:eventsForThisYear];
		
		if(events != nil && ([events count]>0)){
			// filter out recurring
			NSMutableArray *recurrents = [[NSMutableArray alloc]init];
			for(CalEvent* event in events){
				if([event recurrenceRule] != nil){
					[recurrents addObject:event];
				}
			}
			return recurrents;
		}
	}
	return nil;
}
@synthesize eventsAC;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Init calendar picker
	if(calPicker == nil){
		calPicker = [[CPSCalPickerController alloc]init];
		BOOL ok = [NSBundle loadNibNamed:@"CPSCalPicker" owner:calPicker];
		if(ok){
			[calPicker setParentWindow:window];
			[calPicker setSelectedCalendarDelegate:self];
		} 
	}
	// Set default calendar
	if([[NSUserDefaults standardUserDefaults] stringForKey:@"selectedCalendarUID"] != nil){
		[self willChangeValueForKey:@"calendarName"];
		[self willChangeValueForKey:@"calendarUID"];
		[self willChangeValueForKey:@"recurrentEvents"];

		[self setSelectedCalendarUID:[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedCalendarUID"]];
		
		[self didChangeValueForKey:@"recurrentEvents"];
		[self didChangeValueForKey:@"calendarUID"];
		[self didChangeValueForKey:@"calendarName"];
	}
}

- (void)didSelectCalendar:(NSString*)selectedUID withName:(NSString*)displayName{
	[self willChangeValueForKey:@"calendarName"];
	[self willChangeValueForKey:@"calendarUID"];
	[self willChangeValueForKey:@"recurrentEvents"];
	
	[self setSelectedCalendarUID:selectedUID];
	[[NSUserDefaults standardUserDefaults]setObject:selectedUID forKey:@"selectedCalendarUID"];
	
	[self didChangeValueForKey:@"recurrentEvents"];
	[self didChangeValueForKey:@"calendarUID"];
	[self didChangeValueForKey:@"calendarName"];
}

- (NSString*)currentlySelectedCalendarUID{
	return [self selectedCalendarUID];
}

- (IBAction)selectCalendar:(id)sender{
	if(calPicker != nil){
		[calPicker showPickerSheet];
	}
}

- (IBAction)itemizeSelected:(id)sender{
	[self willChangeValueForKey:@"recurrentEvents"];
	for(CalEvent *event in [eventsAC selectedObjects]){
		// create new event with same values
		CalEvent *newEvent = [CalEvent event];
		[newEvent setCalendar:[event calendar]];
		[newEvent setStartDate:[event occurrence]];
		[newEvent setEndDate:[event endDate]];
		[newEvent setIsAllDay:[event isAllDay]];

		[newEvent setTitle:[event title]];
		if([event location] != nil){
			[newEvent setLocation:[event location]];
		}
		[[CalCalendarStore defaultCalendarStore] saveEvent:newEvent span:CalSpanThisEvent error:nil];

		// delete the reccurent one
		[[CalCalendarStore defaultCalendarStore] removeEvent:event span:CalSpanThisEvent error:nil];
	}
	[self didChangeValueForKey:@"recurrentEvents"];
}

- (IBAction)deleteSelected:(id)sender{
	[self willChangeValueForKey:@"recurrentEvents"];
	for(CalEvent *event in [eventsAC selectedObjects]){
		NSError *error;
		if(![[CalCalendarStore defaultCalendarStore] removeEvent:event span:CalSpanThisEvent error:&error]){
			[[NSApplication sharedApplication] presentError:error];
		}
		
	}
	[self didChangeValueForKey:@"recurrentEvents"];
}

@end
