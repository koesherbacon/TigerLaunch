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
	PathsWindow.h
	TigerLaunch

	Created by Brent Simmons on Tue Oct 01 2002.
	Copyright (c) 2002 Ranchero Software. All rights reserved.
	Copyright (c) 2006 NewsGator Technologies, Inc. All rights reserved.
*/


#import <Cocoa/Cocoa.h>


@interface PathsWindow : NSObject {

	IBOutlet NSTableView *pathsTable;
	IBOutlet NSWindow *mainWindow;
	
	NSMutableArray *pathsArray;
	}


+ (PathsWindow *) sharedInstance;

- (NSMutableArray *) pathsArray;

- (void) awakeFromNib;

- (void) savePathsArray;	


/*Actions*/

- (IBAction) deletePath: (id) sender;

- (IBAction) newPath: (id) sender;


/*Table data source and delegate methods*/

- (int) numberOfRowsInTableView: (NSTableView *) tableView;

- (id) tableView: (NSTableView *) tableView
	objectValueForTableColumn: (NSTableColumn *) column
	row: (int) row;


@end
