//
//  CalendarCleanAppDelegate.h
//  CalendarClean
//
//  Created by Andrea on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import	<CPSCoreDataAppKit/CPSCalPickerController.h>

@interface CalendarCleanAppDelegate : NSObject <NSApplicationDelegate,CPSCalendarSelected> {
    NSWindow *window;
	CPSCalPickerController *calPicker;
	NSString *selectedCalendarUID;
	NSArrayController* eventsAC;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CPSCalPickerController *calPicker;
@property (retain) NSString *selectedCalendarUID;
@property (retain, readonly) IBOutlet NSString *calendarName;
@property (retain, readonly) IBOutlet NSString *calendarUID;
@property (retain, readonly) IBOutlet NSArray *recurrentEvents;
@property (retain) IBOutlet NSArrayController* eventsAC;

- (IBAction)selectCalendar:(id)sender;
- (IBAction)itemizeSelected:(id)sender;
- (IBAction)deleteSelected:(id)sender;
// CPSCalendarSelected
- (void)didSelectCalendar:(NSString*)selectedUID withName:(NSString*)displayName;
- (NSString*)currentlySelectedCalendarUID;
@end
