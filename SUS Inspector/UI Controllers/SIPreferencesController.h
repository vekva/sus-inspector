//
//  SIPreferencesController.h
//  SUS Inspector
//
//  Created by Juutilainen Hannes on 2.4.2013.
//  Copyright (c) 2013 Hannes Juutilainen. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import <Cocoa/Cocoa.h>

@interface SIPreferencesController : NSWindowController <NSToolbarDelegate> {
    
}

@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *munkiView;
@property (weak) IBOutlet NSView *advancedView;
@property (weak) IBOutlet NSArrayController *catalogsArrayController;
@property (weak) IBOutlet NSTableView *catalogsTableView;
@property (weak) IBOutlet NSPopUpButton *distApplicationsPopUpButton;
@property (weak) IBOutlet NSPopUpButton *languagesPopupButton;
@property (weak) IBOutlet NSComboBox *languageComboBox;

@property (strong) NSToolbar *toolbar;
@property (strong) NSMutableDictionary *items;
@property (strong) NSArray *distApplications;
@property (strong) NSArray *languageIDs;

- (void)switchViews:(NSToolbarItem *)item;

- (IBAction)addNewCatalogAction:(id)sender;

@end
