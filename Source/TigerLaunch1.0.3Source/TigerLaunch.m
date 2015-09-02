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
	TigerLaunch.m
	TigerLaunch

	Created by Brent Simmons on Fri Aug 02 2002.
	Copyright (c) 2002 Brent Simmons.
	Copyright (c) 2006 NewsGator Technologies, Inc. All rights reserved.
*/


/*
To do:

Support REALbasic and Metrowerks files in Projects menu.
*/

/*
June 29 2006 / Brent : This app was written when I was just barely learning Cocoa,
so it's not a good example of Cocoa code or style. However, to the extent
that it's helpful to anybody, that's cool and I'm glad.

Were I writing the app starting from scratch today, I'd use Spotlight
to find the apps and use Cocoa bindings for the configure table.

Changes:

- Universal (PPC and Intel) binary.
- Strips .app suffix that Tiger sometimes wants to add.
- Finds .xcodeproj projects for the Projects menu.
*/


#import "TigerLaunch.h"
#import "PathsWindow.h" /*For the additional paths to search in for applications.*/


#define iconsAppsMenuKey @"iconAppsMenu"
#define neverShowProjectsMenuKey @"neverShowProjectsMenu"


static TigerLaunch *myInstance = nil;


static int sortbyfilename (id left, id right, void *context);

static int sortbyfilename (id left, id right, void *context) {
	
	NSString *leftFilename, *rightFilename;
	
	leftFilename = [left lastPathComponent];
	
	rightFilename = [right lastPathComponent];
	
	return [leftFilename caseInsensitiveCompare: rightFilename];	
	} /*sortbyfilename*/
	

@implementation TigerLaunch


- (id) init {
	
	iconsCache = [[NSMutableDictionary alloc] initWithCapacity: 50];
	
	projectsArray = [[NSMutableArray alloc] initWithCapacity: 20];
	
	tableFont = [[NSFont fontWithName: @"Lucida Grande" size: 13] retain];
	
	sortedAppsArray = nil;
	
	appsMenu = nil;
	
	projectsMenu = nil;
	
	myInstance = self;
	
	return (self);
	} /*init*/


- (void) dealloc {
	
	[iconsCache release];
	
	[appsArray release];
	
	[appsToSkip release];
	
	[projectsArray release];
	
	[tableFont release];
	
	[sortedAppsArray release];
	
	[appsStatusItem release];
	
	[projectsStatusItem release];
	
	[appsMenuIconNames release];
	
	[appsMenuIconNamesHuman release];
	[super dealloc];
	} /*dealloc*/
	

+ (TigerLaunch *) sharedInstance {
	
	return (myInstance);
	} /*sharedInstance*/
	
	
- (NSString *) appsMenuIconName {
	
	return [[NSUserDefaults standardUserDefaults] objectForKey: iconsAppsMenuKey];	
	} /*appsMenuIconName*/
	

- (void) setAppsMenuIconName: (NSString *) name {
	
	[[NSUserDefaults standardUserDefaults] setObject: name forKey: iconsAppsMenuKey];
	} /*setAppsMenuIconName*/
	

- (NSString *) iconFileNameForIndex: (int) ix {
	
	return [appsMenuIconNames objectAtIndex: ix];	
	} /*iconFileNameForIndex*/
	

- (NSString *) iconHumanNameForIndex: (int) ix {
	
	return [appsMenuIconNamesHuman objectAtIndex: ix];	
	} /*iconHumanNameForIndex*/
	
	
- (void) initializeIconPopup {
	
	int i, ixSelected;
	
	appsMenuIconNames = [[NSArray alloc] initWithObjects:
		@"pawWhite", @"pawSolid", @"appPaw",
		@"faceBw", @"faceColor", @"headBw",
		@"headBw2", @"eyeLeft", @"eyeRight",
		@"stripesBw", @"stripesBwRect", @"stripesColor",
		@"stripesColorRect", nil];

	appsMenuIconNamesHuman = [[NSArray alloc] initWithObjects:
		@"White Paw", @"Solid Paw", @"Application Paw",
		@"Black and White Face", @"Colorful Face", @"Black and White Head",
		@"Black and White Head 2", @"Left-facing Eye", @"Right-facing Eye",
		@"Black and White Stripes", @"Rectangular Black and White Stripes", @"Colorful Stripes",
		@"Rectangular Colorful Stripes", nil];
		
	[iconPopup removeAllItems]; /*Clear the popup menu.*/

	//[iconPopup addItemsWithTitles: appsMenuIconNamesHuman]; /*Add items to the popup menu.*/
	
	/*Add images to the pop-up menu.*/
	
	for (i = 0; i < [appsMenuIconNames count]; i++) {
		
		NSMenuItem *menuItem;
		
		[iconPopup addItemWithTitle: @""];
		 
		menuItem = [iconPopup itemAtIndex: i];
		
		[menuItem setImage: [NSImage imageNamed: [self iconFileNameForIndex: i]]];		
		} /*for*/
	
	ixSelected = [appsMenuIconNames indexOfObject: [self appsMenuIconName]];
	
	[iconPopup selectItemAtIndex: ixSelected];
	} /*initializeIconPopup*/
	

- (void) applicationDidFinishLaunching: (NSNotification *) note {
	
	/*
	PBS 05/13/03: build the initial menus here rather than in awakeFromNib.
	This fixes a bug where the user-added paths could get ignored when
	first building the menus.
	*/
	
	/*Build the Apps and Projects status items and menus*/
	
	if (![self neverShowProjectsMenu])
		[self setUpProjectsMenu];
	
	[self setUpAppsMenu];
	} /*applicationDidFinishLaunching*/
	
	
- (void) awakeFromNib {
	
	NSButtonCell *buttonCell = nil;
	NSImageCell *iconCell = nil;

	/*Deal with apps-to-skip preferences.*/
	
	[self registerDefaultPreferences];
	
	appsToSkip = [[[NSUserDefaults standardUserDefaults] objectForKey: @"appsToSkip"] mutableCopy];
	
	/*Set up the apps table*/
	
	checkColumn = [[appsTable tableColumnWithIdentifier: @"check"] retain];
	
	iconColumn = [[appsTable tableColumnWithIdentifier: @"icon"] retain];
	
	appColumn = [[appsTable tableColumnWithIdentifier: @"application"] retain];
	
	pathColumn = [[appsTable tableColumnWithIdentifier: @"path"] retain];

	[appsTable setIntercellSpacing: NSMakeSize (0, 0)];
	
	[appsTable setDrawsGrid: NO];
	
	/*Set up icon and checkbox cells for the apps table*/
	
	iconCell = [[[NSImageCell alloc] initImageCell: nil] autorelease];
	
	[iconCell setEditable: NO];

	[iconColumn setDataCell: iconCell];

	buttonCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
 
	[buttonCell setControlSize: NSSmallControlSize];
	
	[buttonCell setEditable: NO];

	[buttonCell setButtonType: NSSwitchButton];
	
	[buttonCell setTarget: self];
	
	[buttonCell setAction: @selector (handleCheckboxClicked:)];
	
	[checkColumn setDataCell: buttonCell];
	
	/*Set up icon popup menu*/
	
	[self initializeIconPopup];
	} /*awakeFromNib*/


- (void) registerDefaultPreferences {
	
	/*
	Register the default sources in prefs storage.
	*/
	
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
	/*Default (empty) apps-to-skip prefs*/
	
	[defaultValues setObject: [NSArray array] forKey: @"appsToSkip"];
	
	/*Default icon*/
	
	[defaultValues setObject: @"pawWhite" forKey: @"iconAppsMenu"];
	
	/*Register default prefs.*/
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
	} /*registerDefaultPreferences*/


- (void) removeProjectsMenu {
		
	[projectsArray autorelease];
	
	projectsArray = [[NSMutableArray alloc] initWithCapacity: 20];
	
	[projectsMenu release];
	
	[projectsStatusItem release];
	} /*removeProjectsMenu*/
	
	
- (void) setUpProjectsMenu {
	
	/*
	Create the Projects status item and its menu --
	but only if a ~/Projects/ folder exists.
	*/
	
	NSString *projectsPath = [[NSString alloc] initWithString: @"~/Projects/"];
	
	projectsPath = [projectsPath stringByExpandingTildeInPath];
	
	/*Don't set up the projects menu if the Projects folder doesn't exist.*/
	
	if (![self folderExists: projectsPath])
		return;
		
	depth = 0;
	
	[self visitProjectsInFolder: projectsPath];
	
	/*Don't set up the projects menu if there were no found project files.*/
	
	if ([projectsArray count] < 1)
		return;
		
	/*Build the menu.*/
	
	[self buildProjectsMenu];
	
	/*Create the status item.*/
	
	projectsStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: 65.0];
		
	[projectsStatusItem retain];
		
	[projectsStatusItem setTitle: @"Projects"];
	
	/*Attach the menu to the status item.*/
	
	[projectsStatusItem setMenu: projectsMenu];

	[projectsStatusItem setHighlightMode: YES];
	} /*setUpAppsMenu*/


- (IBAction) changeIconPref: (id) sender {
	
	int ixSelected = [sender indexOfSelectedItem];
	NSString *iconName = [self iconFileNameForIndex: ixSelected];
	
	[self setAppsMenuIconName: iconName];
	
	[self setAppsMenuIcon];
	} /*changeIconPref*/
	


- (void) searchFolderForApps: (NSString *) path {
	
	depth = 0;
	
	if (![self folderExists: path])
		return;
	
	[self visitAppsInFolder: path];
	} /*searchFolderForApps*/
	
	
- (void) buildAppsArray {
	
	/*
	Find all the applications in the /Applications/ folder. And in
	various other folders.
	*/
	
	NSString *userAppsFolder;
	NSArray *additionalAppsFolders;
	NSEnumerator *enumerator;
	NSString *onePath;
	
	[appsArray release];
	
	[sortedAppsArray release];
	
	sortedAppsArray = nil;
		
	appsArray = [[NSMutableArray alloc] initWithCapacity: 100];
	
	/*Apps in /Applications*/
	
	[self visitAppsInFolder: @"/Applications/"];
	
	/*/Developer/Applications*/

	[self searchFolderForApps: @"/Developer/Applications/"];
	
	/*Search ~/Applications folder: PBS 17 Sep 02*/
	
	userAppsFolder = @"~/Applications/";
	
	userAppsFolder = [userAppsFolder stringByExpandingTildeInPath];
	
	[self searchFolderForApps: userAppsFolder];
	
	/*Search in additional apps folders specified by user: PBS 1 Oct 02*/
	
	additionalAppsFolders = [[PathsWindow sharedInstance] pathsArray];
	
	enumerator = [additionalAppsFolders objectEnumerator];
	
	while (onePath = [enumerator nextObject])
		[self searchFolderForApps: onePath];
	} /*buildAppsArray*/
	

- (void) setAppsMenuIcon {
	
	[appsStatusItem setImage: [NSImage imageNamed: [self appsMenuIconName]]];	
	} /*setAppsMenuIcon*/
	
	
- (void) setUpAppsMenu {
		
	/*
	Create the Apps status item and its menu.
	*/

	/*Find all the applications in the /Applications/ folder.*/
	
	[self buildAppsArray];
	
	/*Build the menu.*/
	
	[self buildAppsMenu];
	
	/*Create the Apps status item.*/
	
	appsStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: 27.0];

	[appsStatusItem retain];
		
	/*Icon for the Apps menu: PBS 20 Sep 02*/
	
	[self setAppsMenuIcon];
	
	/*Attach the menu to the status item.*/

	[appsStatusItem setMenu: appsMenu];
	
	[appsStatusItem setHighlightMode: YES];
	} /*setUpAppsMenu*/
	
	
- (void) updateAppsMenu {
	
	[self buildAppsMenu];
	
	[appsStatusItem setMenu: appsMenu];
	} /*updateAppsMenu*/


- (BOOL) fileExists: (NSString *) path {
	
	/*
	Return YES if it exists *and* it's *not* a folder;
	return NO otherwise.
	*/
	
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	BOOL isDirectory = NO;
	
	if (![fileManager fileExistsAtPath: path isDirectory: &isDirectory])
		return (NO);
	
	return (!isDirectory);
	} /*fileExists*/


- (BOOL) folderExists: (NSString *) path {
	
	/*
	Return YES if it exists *and* it's a folder;
	return NO otherwise.
	*/
	
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	BOOL isDirectory = NO;
	
	if (![fileManager fileExistsAtPath: path isDirectory: &isDirectory])
		return (NO);
	
	return (isDirectory);
	} /*folderExists*/


static int ctPrefsChanges = 0;

- (void) savePreferences {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject: appsToSkip forKey: @"appsToSkip"];
	
	/*synchronize to disk every 3rd change. Whatever.*/

	ctPrefsChanges++;
	
	if ((ctPrefsChanges % 3) == 0)
		[defaults synchronize];
	} /*savePreferences*/



- (BOOL) neverShowProjectsMenu {
	
	return [[NSUserDefaults standardUserDefaults] boolForKey: neverShowProjectsMenuKey];
	} /*neverShowProjectsMenu*/
	

- (IBAction) handleNeverShowProjectsClicked: (id) sender {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL flNeverShow = (BOOL) [sender intValue];
	
	[defaults setBool: flNeverShow forKey: neverShowProjectsMenuKey];
	
	if (flNeverShow)
		[self removeProjectsMenu];
	else
		[self setUpProjectsMenu];
	} /*handleNeverShowProjectsClicked*/
	
	
- (void) handleCheckboxClicked: (id) sender {
	
	/*
	Called when a checkbox is clicked in the Configure window.
	*/
	
	int ix = [appsTable selectedRow];
	NSString *path = [[self getSortedAppsArray] objectAtIndex: ix];
	
	if ([appsToSkip containsObject: path])
		[appsToSkip removeObject: path];
	else
		[appsToSkip addObject: path];
	
	[self savePreferences];
	
	[self updateAppsMenu];
	} /*handleCheckboxClicked*/
	

- (NSImage *) iconForFileAtPath: (NSString *) path {
	
	/*
	Return a 16 x 16 icon for an app or a file.
	*/
	
	NSImage *icon = [iconsCache objectForKey: path];
	
	if (icon == nil) { /*Get it and cache it. A performance thing.*/
	
		icon = [[NSWorkspace sharedWorkspace] iconForFile: path];
		
		[icon setSize: NSMakeSize (16, 16)];
		
		[iconsCache setObject: icon forKey: path];
		} /*if*/
		
	return (icon);
	} /*iconForFileAtPath*/


- (NSString *) stripSuffixFromFilePath: (NSString *) filePath {
	
	NSRange range = [filePath rangeOfString: @"." options: NSCaseInsensitiveSearch];
	
	if (range.location == NSNotFound)
		return (filePath);
		
	return [filePath substringToIndex: range.location];
	} /*stripSuffixFromFilePath*/
	
	
- (void) buildProjectsMenu {
	
	NSArray *sortedArray = [projectsArray sortedArrayUsingFunction: sortbyfilename context: nil];
	NSEnumerator *enumerator = [sortedArray objectEnumerator];
	NSString *path;
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	NSMenuItem *menuItem;
	
	projectsMenu = [[NSMenu alloc] initWithTitle: @"Projects"];
	
	while (path = [enumerator nextObject]) {
		
		NSString *name = [fileManager displayNameAtPath: path];
		
		name = [self stripSuffixFromFilePath: name];
		
		menuItem = [projectsMenu addItemWithTitle: name
			action: @selector (launchProject:) keyEquivalent: @""];
	
		[menuItem setTarget: self];
		
		[menuItem setRepresentedObject: path];
		
		[menuItem setImage: [self iconForFileAtPath: path]];
		} /*path*/
	} /*buildMenu*/


- (NSArray *) getSortedAppsArray {
	
	/*
	Return the apps array sorted by app name (not by path).
	*/
	
	if (sortedAppsArray == nil) {
	
		sortedAppsArray = [appsArray sortedArrayUsingFunction: sortbyfilename context: nil];
		
		[sortedAppsArray retain];
		} /*if*/
	
	return (sortedAppsArray);
	} /*getSortedAppsArray*/
	

- (void) updateConfigureWindowControls {
	
	[neverShowProjectsMenu setIntValue: [self neverShowProjectsMenu]];
	} /*updateConfigureWindowControls*/
	
	
- (void) configure: (id) sender {
	
	/*
	User wants to include and exclude apps from the Apps menu.
	*/
	
	/*Bring app to front.*/
	
	[NSApp activateIgnoringOtherApps: YES];
	
	/*Bring configure window to front.*/

	[configureWindow makeKeyAndOrderFront: self];
	
	[self updateConfigureWindowControls];
	
	/*PBS 05/14/03: suddenly it's necessary to jiggle the scrollbar
	to get it to display. I don't know why.*/
	
	[[appsTable enclosingScrollView] setHasVerticalScroller: NO];
	[[appsTable enclosingScrollView] setHasVerticalScroller: YES];
	
	[appsTable reloadData]; /*PBS 29 June 2006: the table could be empty without this call.*/
	} /*configure*/


- (IBAction) openAddPathsWindow: (id) sender {
	
	[NSApp activateIgnoringOtherApps: YES];

	[addPathsWindow makeKeyAndOrderFront: self];
	} /*openAddPathsWindow*/
	
	
- (void) refresh: (id) sender {
	
	/*
	Re-scan for apps and rebuild the Apps menu.
	*/
	
	[self buildAppsArray];
	
	[self buildAppsMenu];
	
	[appsStatusItem setMenu: appsMenu];
	
	[appsTable reloadData];
	} /*refresh*/
	

- (NSString *)appNameWithDotAppSuffixStripped:(NSString *)path {
	/*PBS 29 June 2006: strip .app suffix which Tiger (sometimes) insists on adding.*/
	NSString *name = [[NSFileManager defaultManager] displayNameAtPath:path];
	if ([name hasSuffix:@".app"])
		name = [self stripSuffixFromFilePath:name];
	return name;
	}
	
	
- (void) addAppToMenu: (NSString *) path {
	
	/*
	Add one application to the Apps menu.
	*/
	
	NSMenuItem *menuItem = menuItem = [appsMenu addItemWithTitle:[self appNameWithDotAppSuffixStripped:path] action: @selector (launchApp:) keyEquivalent: @""];
	[menuItem setTarget: self];	
	[menuItem setRepresentedObject: path];
	[menuItem setImage: [self iconForFileAtPath: path]];
	} /*addAppToMenu*/
	
	
- (void) buildAppsMenu {
	
	/*
	Build the Apps menu. The Apps menu is also displayed
	from the dock icon.
	*/
	
	NSArray *sortedArray = [self getSortedAppsArray];
	NSEnumerator *enumerator = [sortedArray objectEnumerator];
	NSString *path;
	NSMenuItem *menuItem;
	
	[appsMenu release];
	
	appsMenu = [[NSMenu alloc] initWithTitle: @"Apps"];
	
	/*Configure and Refresh commands*/
	
	menuItem = [appsMenu addItemWithTitle: @"ConfigureÉ"
		action: @selector (configure:) keyEquivalent: @""];
	
	[menuItem setTarget: self];
	
	menuItem = [appsMenu addItemWithTitle: @"Refresh"
		action: @selector (refresh:) keyEquivalent: @""];
	
	[menuItem setTarget: self];
	
	/*Separator*/
			
	[appsMenu addItem: [NSMenuItem separatorItem]];

	/*Applications*/
	
	while (path = [enumerator nextObject]) {
		
		/*Add apps to the Apps menu.*/
		
		if (![self appShouldBeSkipped: path])
			[self addAppToMenu: path];
		} /*while*/
	
	/*Separator*/
			
	[appsMenu addItem: [NSMenuItem separatorItem]];
	
	/*Quit -- PBS 12 Sep 2002: app is now background app. Add Quit menu item.*/
	
	menuItem = [appsMenu addItemWithTitle: @"Quit TigerLaunch"
		action: @selector (terminate:) keyEquivalent: @""];

	[menuItem setTarget: NSApp];
	} /*buildAppsMenu*/
	

- (void) launchProject: (id) sender {
	
	/*
	Open the chosen project from the Projects menu.
	*/
	
	NSString *path = [sender representedObject];

	[[NSWorkspace sharedWorkspace] openFile: path];		
	} /*launchApp*/
	

- (void) launchApp: (id) sender {
	
	/*
	Launch the app chosen from the Apps menu.
	*/
	
	NSString *path = [sender representedObject];

	[[NSWorkspace sharedWorkspace] launchApplication: path];		
	} /*launchApp*/


- (void) visitAppsInFolder: (NSString *) path {
		
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	NSArray *files = [fileManager directoryContentsAtPath: path];
	NSEnumerator *enumerator = [files objectEnumerator];
	NSString *oneFile;
	
	depth++;
	
	while (oneFile = [enumerator nextObject]) {
		
		/*If it's a directory, and it's a wrapper, and
		it ends with .app, it's an app.
		
		If it's a file, and it's type is 'APPL',
		it's an app.*/
		
		BOOL flDirectory = NO;
		NSString *filePath = [path stringByAppendingPathComponent: oneFile];

		if ([oneFile hasPrefix: @"."])
			continue;
			
		[fileManager fileExistsAtPath: filePath isDirectory: &flDirectory];
		
		if (flDirectory) {
			
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath: filePath]) {
				if ([oneFile hasSuffix: @".app"])
					[appsArray addObject: filePath];
				
				else { /*it might be a packaged app without the .app suffix.*/
					
					/*PBS 11 Sep 2002:
					This is weird. I can't find an official way to determine if a packaged app
					missing a .app extension is still an app. So we look for a
					[app]/Contents/PkgInfo file and read it and see if it begins with APPL.*/
					
					NSString *packageInfoPath = [NSString stringWithFormat: @"%@/Contents/PkgInfo", filePath];
					
					if ([self fileExists: packageInfoPath]) {
						
						NSString *s = [NSString stringWithContentsOfFile: packageInfoPath];

						if ([s hasPrefix: @"APPL"]) /*is it an application?*/
							[appsArray addObject: filePath];
						
						} /*if*/
					} /*else*/
				} /*if*/
			
			else {
				
				if (depth < 3) /*Increased depth to 3 levels: PBS 17 Sep 02*/
					[self visitAppsInFolder: filePath];
				} /*else*/
			
			} /*if*/
		
		else {
		
			NSDictionary *atts = [fileManager fileAttributesAtPath: filePath traverseLink: NO];
						
			if ([atts fileHFSTypeCode] == 'APPL')
				[appsArray addObject: filePath];		
			} /*else*/
		} /*while*/
	
	depth--;
	} /*visitAppsInFolder*/
	

- (void) visitProjectsInFolder: (NSString *) path {
		
	NSFileManager *fileManager = [NSFileManager defaultManager];	
	NSArray *files = [fileManager directoryContentsAtPath: path];
	NSEnumerator *enumerator = [files objectEnumerator];
	NSString *oneFile;
	
	depth++;
	
	while (oneFile = [enumerator nextObject]) {
		
		BOOL flDirectory = NO;
		NSString *filePath = [path stringByAppendingPathComponent: oneFile];
		
		if ([oneFile hasPrefix: @"."])
			continue;
			
		[fileManager fileExistsAtPath: filePath isDirectory: &flDirectory];
		
		if (flDirectory) {
			
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath: filePath]) {
				if ([oneFile hasSuffix: @".pbproj"] || [oneFile hasSuffix:@".xcodeproj"]) /*PBS 29 June 2006: latest xcodeproj suffix*/
					[projectsArray addObject: filePath];		
				} /*if*/
			
			else {
				
				if (depth < 3) /*Increased depth to 3 levels: PBS 17 Sep 02*/
					[self visitProjectsInFolder: filePath];
				} /*else*/			
			} /*if*/
		
		else { /*a regular file -- perhaps RealBasic or CodeWarrior*/
						
			if ([oneFile hasSuffix: @".mcp"])
				[projectsArray addObject: filePath];
			
			else if ([oneFile hasSuffix: @".rbproj"])
				[projectsArray addObject: filePath];
			
			else if ([oneFile hasSuffix: @".rb"])
				[projectsArray addObject: filePath];
			
			else { /*check type/creator*/
				
				NSDictionary *fileAttributes = [fileManager fileSystemAttributesAtPath: filePath];
				OSType type = [fileAttributes fileHFSTypeCode];
				
				if (type == 'MMPr') /*CodeWarrior project file*/
					[projectsArray addObject: filePath];
				
				if (type == 'RbBF') /*RealBasic project file*/
					[projectsArray addObject: filePath];
				} /*else*/
			} /*else*/
		
		
		
		} /*while*/
	
	depth--;
	} /*visitProjectsInFolder*/


- (BOOL) appShouldBeSkipped: (NSString *) path {
	
	/*
	Should this app be excluded from the Apps menu?
	*/
	
	if ([appsToSkip containsObject: path])
		return (YES);
		
	return (NO);
	} /*appShouldBeSkipped*/
	
	
- (NSMenu *) applicationDockMenu: (NSApplication *) sender {
	
	/*
	For the dock menu, return the Apps menu.
	*/
	
	return (appsMenu);
	} /*applicationDockMenu*/


/*Table data source and delegate methods*/

- (int) numberOfRowsInTableView: (NSTableView *) tableView {
	
	if (appsArray == nil)
		return (0);
		
	return [appsArray count];
	} /*numberOfRowsInTableView*/


- (id) tableView: (NSTableView *) tableView
	objectValueForTableColumn: (NSTableColumn *) column
	row: (int) row {
	
	NSString *path = [[self getSortedAppsArray] objectAtIndex: row];
	
	/*Icon column*/
	
	if (column == iconColumn)
		return [self iconForFileAtPath: path];
	
	/*Checkbox column*/
	
	if (column == checkColumn) {
	
		if ([self appShouldBeSkipped: path])
			return [NSNumber numberWithBool: NO];
					
		return [NSNumber numberWithBool: YES];
		} /*if*/
	
	/*App name column*/
	
	if (column == appColumn)	
		return [[NSFileManager defaultManager] displayNameAtPath: path];
	
	/*App path column*/
	
	return [path stringByDeletingLastPathComponent];
	} /*tableView: objectValueForTableColumn*/


- (void) tableView: (NSTableView *) tableView willDisplayCell: (id) cell
	forTableColumn: (NSTableColumn *) column row: (int) row {
	
	[cell setFont: tableFont];
	} /*tableView: willDisplayCell*/

	
@end
