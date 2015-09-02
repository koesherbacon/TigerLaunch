/*

BSD License

Copyright (c) 2002, Brent Simmons
Copyright (c) 2006, NewsGator Technologies, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

*	Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
*	Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
*	None of the names newsgator.com, ranchero.com, NewsGator Technologies, Inc.,
	and Brent Simmons nor the names of its contributors may be used to endorse
	or promote products derived from this software without specific prior
	written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


*/


/*
	PathsWindow.m
	TigerLaunch

	Created by Brent Simmons on Tue Oct 01 2002.
	Copyright (c) 2002 Ranchero Software. All rights reserved.
	Copyright (c) 2006 NewsGator Technologies, Inc. All rights reserved.
*/


#import "PathsWindow.h"
#import "TigerLaunch.h"


#define searchPathsKey @"additionalSearchPaths"


static PathsWindow *myInstance;


@implementation PathsWindow


+ (PathsWindow *) sharedInstance {
	
	return (myInstance);
	} /*sharedInstance*/
	

- (NSMutableArray *) pathsArray {
	
	return (pathsArray);
	} /*pathsArray*/
	
	
- (void) awakeFromNib {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (pathsArray == nil) {
				
		if ([defaults objectForKey: searchPathsKey] == nil)		
			pathsArray = [[NSMutableArray alloc] initWithCapacity: 5];	
		else
			pathsArray = [[defaults objectForKey: searchPathsKey] mutableCopy];
		} /*if*/
		
	myInstance = self;
	} /*awakeFromNib*/


- (void) savePathsArray {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject: pathsArray forKey: searchPathsKey];
	
	[defaults synchronize];
	
	[[TigerLaunch sharedInstance] refresh: self];
	} /*savePathsArray*/
	

/*Actions -- Delete and New buttons.*/

- (IBAction) deletePath: (id) sender {
	
	int ix = [pathsTable selectedRow];
	
	if (ix < 0)
		return;
		
	[pathsArray removeObjectAtIndex: ix];
	
	[self savePathsArray];
	
	[pathsTable reloadData];
	} /*deletePath*/
	

- (void) newPathPanelDidEnd: (NSWindow *) sheet returnCode: (int) returnCode
	contextInfo: (void  *) contextInfo {
		
	NSArray *urls;
	NSURL *url;
	NSString *path;
	
	if (returnCode != NSOKButton)
		return;
		
	urls = [(NSOpenPanel *) sheet URLs];
	
	url = [urls objectAtIndex: 0];
	
	path = [url path];
	
	[pathsArray addObject: path];
	
	[self savePathsArray];
	
	[pathsTable reloadData];
	
	[pathsTable selectRow: ([pathsArray count] - 1) byExtendingSelection: NO];
	} /*newPathPanelDidEnd*/


- (IBAction) newPath: (id) sender {
	
	/*
	Run an Open Panel to locate the folder.
	*/
	
	NSOpenPanel *op = [NSOpenPanel openPanel];
	
	[op setAllowsMultipleSelection: NO];
	
	[op setCanChooseDirectories: YES];
	
	[op setCanChooseFiles: NO];
	
	[op setTitle: @"Choose a folder to add:"];
	
	[op beginSheetForDirectory: NSHomeDirectory ()
		file: nil
		types: nil
		modalForWindow: mainWindow
		modalDelegate: self
		didEndSelector: @selector (newPathPanelDidEnd:returnCode:contextInfo:)
		contextInfo: nil];
	} /*newPath*/



/*Table data source and delegate methods*/

- (int) numberOfRowsInTableView: (NSTableView *) tableView {
	
	return [pathsArray count];
	} /*numberOfRowsInTableView*/


- (id) tableView: (NSTableView *) tableView
	objectValueForTableColumn: (NSTableColumn *) column
	row: (int) row {
	
	return [pathsArray objectAtIndex: row];
	} /*tableView: objectValueForTableColumn*/


@end
