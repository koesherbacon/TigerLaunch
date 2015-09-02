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
	TigerLaunch.h
	TigerLaunch

	Created by Brent Simmons on Fri Aug 02 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
	Copyright (c) 2006 NewsGator Technologies, Inc. All rights reserved.
*/


#import <Cocoa/Cocoa.h>


@interface TigerLaunch : NSObject {

	IBOutlet NSTableView *appsTable;
	IBOutlet NSWindow *configureWindow;
	IBOutlet NSPopUpButton *iconPopup;
	IBOutlet NSButton *neverShowProjectsMenu;
	IBOutlet NSWindow *addPathsWindow;
	
	NSTableColumn *checkColumn, *iconColumn, *appColumn, *pathColumn;
	NSStatusItem *appsStatusItem;
	NSStatusItem *projectsStatusItem;
	NSMenu *appsMenu;
	NSMenu *projectsMenu;
	NSMutableArray *appsArray;
	NSMutableArray *projectsArray;
	int depth;
	NSFont *tableFont;
	NSMutableArray *appsToSkip;
	NSMutableDictionary *iconsCache;
	NSArray *sortedAppsArray;
	NSArray *appsMenuIconNames, *appsMenuIconNamesHuman;
	}


+ (TigerLaunch *) sharedInstance;

- (BOOL) appShouldBeSkipped: (NSString *) path;

- (IBAction) openAddPathsWindow: (id) sender;

- (void) awakeFromNib;	

- (void) registerDefaultPreferences;

- (void) handleCheckboxClicked: (id) sender;

- (IBAction) changeIconPref: (id) sender;

- (IBAction) handleNeverShowProjectsClicked: (id) sender;

- (BOOL) neverShowProjectsMenu;

- (NSArray *) getSortedAppsArray;

- (void) buildProjectsMenu;

- (void) setAppsMenuIcon;

- (void) launchProject: (id) sender;

- (void) launchApp: (id) sender;

- (void) visitAppsInFolder: (NSString *) path;

- (void) visitProjectsInFolder: (NSString *) path;

- (NSMenu *) applicationDockMenu: (NSApplication *) sender;

- (void) setUpAppsMenu;

- (void) setUpProjectsMenu;

- (BOOL) folderExists: (NSString *) path;

- (void) buildAppsMenu;

- (void) refresh: (id) sender;


@end
