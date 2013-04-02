//
//  SIPkginfoWindowController.m
//  SUS Inspector
//
//  Created by Hannes Juutilainen on 19.3.2013.
//  Copyright (c) 2013 Hannes Juutilainen. All rights reserved.
//

#import "SIPkginfoWindowController.h"
#import "DataModelHeaders.h"

@interface SIPkginfoWindowController ()

@end

@implementation SIPkginfoWindowController

@dynamic pkginfo;

- (NSURL *)showSavePanelForPkginfo:(NSString *)fileName
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = fileName;
    savePanel.title = @"Save pkginfo";
	if ([savePanel runModal] == NSFileHandlingPanelOKButton)
	{
		return [savePanel URL];
	} else {
		return nil;
	}
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        NSArray *restartActions = [NSArray arrayWithObjects:@"RequireShutdown", @"RequireRestart", @"RecommendRestart", @"RequireLogout", @"None", nil];
        self.restartActionTemplates = [restartActions sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    }
    
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setBackgroundColor:[NSColor whiteColor]];
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    self.munki_name = self.product.productID;
    self.munki_display_name = self.product.productTitle;
    self.munki_version = self.product.productVersion;
    
    NSArray *catalogDictsFromDefaults = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMunkiCatalogs"];
    NSArray *catalogs = [catalogDictsFromDefaults valueForKeyPath:@"title"];
    
    self.munki_catalogs = catalogs;
    self.munki_unattended_install = [NSNumber numberWithBool:NO];
    
    self.munki_RestartAction = nil;
    self.munki_description = nil;
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [gregorian components:( NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    NSDate *normalizedDate = [gregorian dateFromComponents:dateComponents];
    
    NSDateComponents *offsetComponents = [[[NSDateComponents alloc] init] autorelease];
    [offsetComponents setDay:7];
    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:normalizedDate options:0];
    
    self.munki_force_install_after_date = newDate;
    self.munki_force_install_after_date_enabled = [NSNumber numberWithBool:NO];
    
}

- (IBAction)htmlDescriptionToPlainText:(id)sender
{
    NSData *data = [self.product.productDescription dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *html = [[[NSAttributedString alloc] initWithHTML:data documentAttributes:nil] autorelease];
    self.munki_description = [html string];
}

- (IBAction)populateDescriptionAction:(id)sender
{
    self.munki_description = self.product.productDescription;
}

- (IBAction)clearDescriptionAction:(id)sender
{
    self.munki_description = nil;
}

- (void)savePkginfoAction:(id)sender
{
    NSString *displayNameTemplate = [self.munki_display_name stringByReplacingOccurrencesOfString:@" " withString:@" "];
    NSString *filenameTemplate = [NSString stringWithFormat:@"%@ %@ %@.plist", displayNameTemplate, self.munki_version, self.munki_name];
    NSURL *saveURL = [self showSavePanelForPkginfo:filenameTemplate];
    if (!saveURL) {
        return;
    }
    if (![[self pkginfo] writeToURL:saveURL atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        NSLog(@"Failed to write %@", [saveURL path]);
    }
}

- (void)cancelSavePkginfoAction:(id)sender
{
    [self.window close];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	// Define keys that depend on
    if ([key isEqualToString:@"pkginfo"])
    {
        NSSet *affectingKeys = [NSSet setWithObjects:
                                @"munki_name",
                                @"munki_display_name",
                                @"munki_version",
                                @"munki_catalogs",
                                @"munki_description",
                                @"munki_RestartAction",
                                @"munki_force_install_after_date_enabled",
                                @"munki_force_install_after_date",
                                @"munki_unattended_install",
                                nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
	
    return keyPaths;
}

- (NSString *)pkginfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"apple_update_metadata" forKey:@"installer_type"];
    if (self.munki_name) [dict setObject:self.munki_name forKey:@"name"];
    if (self.munki_display_name) [dict setObject:self.munki_display_name forKey:@"display_name"];
    if (self.munki_version) [dict setObject:self.munki_version forKey:@"version"];
    if (self.munki_description) [dict setObject:self.munki_description forKey:@"description"];
    if ([self.munki_catalogs count] > 0) {
        [dict setObject:self.munki_catalogs forKey:@"catalogs"];
    }
    if (self.munki_RestartAction) [dict setObject:self.munki_RestartAction forKey:@"RestartAction"];
    if ([self.munki_force_install_after_date_enabled boolValue]) {
        [dict setObject:self.munki_force_install_after_date forKey:@"force_install_after_date"];
    }
    if ([self.munki_unattended_install boolValue]) {
        [dict setValue:(id)kCFBooleanTrue forKey:@"unattended_install"];
    }
    
    NSError *error;
	id plist;
    plist = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListImmutable error:&error];
    NSString *returnString = [[[NSString alloc] initWithData:plist encoding:NSUTF8StringEncoding] autorelease];
    return returnString;
}


- (NSButton *)addPushButtonWithTitle:(NSString *)title identifier:(NSString *)identifier superView:(NSView *)superview
{
    NSButton *pushButton = [[[NSButton alloc] init] autorelease];
    [pushButton setIdentifier:identifier];
    [pushButton setBezelStyle:NSRoundedBezelStyle];
    [pushButton setFont:[NSFont systemFontOfSize:13.0]];
    [pushButton setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [pushButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:pushButton];
    if (title) [pushButton setTitle:title];
    
    [pushButton setTarget:self];
    
    return pushButton;
}

- (NSTextField *)addTextFieldWithidentifier:(NSString *)identifier superView:(NSView *)superview
{
    NSTextField *textField = [[[NSTextField alloc] init] autorelease];
    [textField setIdentifier:identifier];
    [[textField cell] setControlSize:NSRegularControlSize];
    [textField setBordered:YES];
    [textField setBezeled:YES];
    [textField setSelectable:YES];
    [textField setEditable:YES];
    [textField setFont:[NSFont systemFontOfSize:13.0]];
    [textField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:textField];
    return textField;
}

- (NSComboBox *)addComboBoxWithidentifier:(NSString *)identifier superView:(NSView *)superview
{
    NSComboBox *textField = [[[NSComboBox alloc] init] autorelease];
    [textField setIdentifier:identifier];
    [[textField cell] setControlSize:NSRegularControlSize];
    [textField setBordered:YES];
    [textField setCompletes:YES];
    [textField setBezeled:YES];
    [textField setSelectable:YES];
    [textField setEditable:YES];
    [textField setFont:[NSFont systemFontOfSize:13.0]];
    [textField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:textField];
    return textField;
}

- (NSTextField *)addLabelFieldWithTitle:(NSString *)title identifier:(NSString *)identifier superView:(NSView *)superview
{
    NSTextField *textField = [[[NSTextField alloc] init] autorelease];
    [textField setIdentifier:identifier];
    [textField setStringValue:title];
    [[textField cell] setControlSize:NSRegularControlSize];
    [textField setAlignment:NSRightTextAlignment];
    [textField setBordered:NO];
    [textField setBezeled:NO];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    [textField setDrawsBackground:NO];
    [textField setFont:[NSFont boldSystemFontOfSize:13.0]];
    [textField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addSubview:textField];
    return textField;
}

- (void)setupPkginfoPreviewView:(NSView *)parentView
{
    id nameLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Pkginfo Preview", nil) identifier:@"nameLabel" superView:parentView];
    
    NSTextView *pkginfoTextView = [[[NSTextView alloc] initWithFrame:[parentView bounds]] autorelease];
    [pkginfoTextView setIdentifier:@"pkginfoTextView"];
    [pkginfoTextView setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [pkginfoTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [pkginfoTextView setRichText:NO];
    [pkginfoTextView setDrawsBackground:YES];
    NSFont *scriptFont = [NSFont fontWithName:@"Menlo Regular" size:11];
    [pkginfoTextView setFont:scriptFont];
    NSNumber *yes = [NSNumber numberWithBool:YES];
    NSNumber *no = [NSNumber numberWithBool:NO];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:no, NSConditionallySetsEditableBindingOption, yes, NSContinuouslyUpdatesValueBindingOption, yes, NSValidatesImmediatelyBindingOption, nil];
    [pkginfoTextView bind:@"value" toObject:self withKeyPath:@"pkginfo" options:options];
    [pkginfoTextView setEditable:NO];
    [pkginfoTextView setSelectable:YES];
    NSScrollView *pkginfoScrollView = [[[NSScrollView alloc] init] autorelease];
    [pkginfoScrollView setIdentifier:@"pkginfoScrollView"];
    [pkginfoScrollView setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [pkginfoScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [pkginfoScrollView setBorderType:NSNoBorder];
    [pkginfoScrollView setHasVerticalScroller:YES];
    [pkginfoScrollView setHasHorizontalScroller:YES];
    [pkginfoScrollView setAutohidesScrollers:NO];
    [pkginfoScrollView setAutoresizesSubviews:YES];
    [pkginfoScrollView setDocumentView:pkginfoTextView];
    [parentView addSubview:pkginfoScrollView];
    
    NSDictionary *buttons = NSDictionaryOfVariableBindings(nameLabel, pkginfoTextView, pkginfoScrollView);
    
    [pkginfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pkginfoTextView(>=20)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:buttons]];
    [pkginfoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pkginfoTextView(>=20)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:buttons]];
    
    // Horizontal layout
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nameLabel]-(>=0)-|" options:NSLayoutFormatAlignAllTop metrics:nil views:buttons]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pkginfoScrollView(>=300)]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:buttons]];
    
    // Vertical layout
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nameLabel]-[pkginfoScrollView]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:buttons]];
}

- (void)setupPkginfoView:(NSView *)parentView
{
    
    /*
     Binding options
     */
    NSDictionary *textFieldOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSContinuouslyUpdatesValueBindingOption, nil];
    
    /*
     Name field
     */
    id nameLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Name", nil) identifier:@"nameLabel" superView:parentView];
    id nameField = [self addTextFieldWithidentifier:@"nameField" superView:parentView];
    [nameField setEnabled:NO];
    [nameField bind:@"value" toObject:self withKeyPath:@"munki_name" options:textFieldOptions];
    
    /*
     Display name field
     */
    id displayNameLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Display Name", nil) identifier:@"displayNameLabel" superView:parentView];
    id displayNameField = [self addTextFieldWithidentifier:@"displayNameField" superView:parentView];
    [displayNameField bind:@"value" toObject:self withKeyPath:@"munki_display_name" options:textFieldOptions];
    
    
    /*
     Display name field
     */
    id versionLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Version", nil) identifier:@"versionLabel" superView:parentView];
    id versionField = [self addTextFieldWithidentifier:@"versionField" superView:parentView];
    [versionField bind:@"value" toObject:self withKeyPath:@"munki_version" options:textFieldOptions];
    
    
    
    /*
     Catalogs token field
     */
    id catalogsLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Catalogs", nil) identifier:@"catalogsLabel" superView:parentView];
    NSTokenField *catalogsTokenField = self.catalogsTokenField;
    [catalogsTokenField setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [catalogsTokenField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [catalogsTokenField setDelegate:self];
    [parentView addSubview:catalogsTokenField];
    [catalogsTokenField bind:@"value" toObject:self withKeyPath:@"munki_catalogs" options:textFieldOptions];
    
    
    
    /*
     Restart Action field
     */
    id restartActionLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Restart Action", nil) identifier:@"restartActionLabel" superView:parentView];
    id restartActionField = [self addComboBoxWithidentifier:@"restartActionField" superView:parentView];
    [restartActionField bind:@"value" toObject:self withKeyPath:@"munki_RestartAction" options:textFieldOptions];
    [restartActionField bind:@"contentValues" toObject:self withKeyPath:@"restartActionTemplates" options:nil];
    
    /*
     Unattended install label and check box
     */
    id unattendedLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Unattended Install", nil) identifier:@"unattendedLabel" superView:parentView];
    [unattendedLabel setHidden:YES];
    NSButton *unattendedButton = [[[NSButton alloc] init] autorelease];
    [unattendedButton setButtonType:NSSwitchButton];
    [unattendedButton setTitle:NSLocalizedString(@"Unattended Install", nil)];
    [unattendedButton setIdentifier:@"unattendedButton"];
    [unattendedButton setStringValue:NSLocalizedString(@"Unattended Install", nil)];
    [unattendedButton setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [unattendedButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [unattendedButton bind:@"value" toObject:self withKeyPath:@"munki_unattended_install" options:nil];
    [parentView addSubview:unattendedButton];
    
    /*
     Force install after date
     */
    id forceAfterLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Force After", nil) identifier:@"forceAfterLabel" superView:parentView];
    
    NSDatePicker *forceAfterDatePicker = [[[NSDatePicker alloc] init] autorelease];
    [forceAfterDatePicker setIdentifier:@"forceAfterDatePicker"];
    [forceAfterDatePicker setDatePickerStyle:NSTextFieldAndStepperDatePickerStyle];
    [forceAfterDatePicker setDatePickerElements:( NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag)];
    [[forceAfterDatePicker cell] setControlSize:NSRegularControlSize];
    [forceAfterDatePicker setBordered:YES];
    [forceAfterDatePicker setBezeled:YES];
    [forceAfterDatePicker setDrawsBackground:YES];
    [forceAfterDatePicker setFont:[NSFont systemFontOfSize:13.0]];
    [forceAfterDatePicker setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [forceAfterDatePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forceAfterDatePicker bind:@"value" toObject:self withKeyPath:@"munki_force_install_after_date" options:textFieldOptions];
    [forceAfterDatePicker bind:@"enabled" toObject:self withKeyPath:@"munki_force_install_after_date_enabled" options:nil];
    [parentView addSubview:forceAfterDatePicker];
    
    NSButton *forceAfterCheckBox = [[[NSButton alloc] init] autorelease];
    [forceAfterCheckBox setButtonType:NSSwitchButton];
    [forceAfterCheckBox setImagePosition:NSImageOnly];
    [forceAfterCheckBox setIdentifier:@"forceAfterCheckBox"];
    [forceAfterCheckBox setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [forceAfterCheckBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forceAfterCheckBox bind:@"value" toObject:self withKeyPath:@"munki_force_install_after_date_enabled" options:nil];
    [parentView addSubview:forceAfterCheckBox];
    
    /*
     Description text view
     */
    id descriptionLabel = [self addLabelFieldWithTitle:NSLocalizedString(@"Description", nil) identifier:@"descriptionLabel" superView:parentView];
    
    NSScrollView *descriptionScroll = [[[NSScrollView alloc] initWithFrame:[parentView bounds]] autorelease];
    NSSize contentSize = [descriptionScroll contentSize];
    [descriptionScroll setIdentifier:@"descriptionScroll"];
    [descriptionScroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [descriptionScroll setTranslatesAutoresizingMaskIntoConstraints:NO];
    [descriptionScroll setBorderType:NSBezelBorder];
    [descriptionScroll setHasVerticalScroller:YES];
    [descriptionScroll setHasHorizontalScroller:NO];
    [descriptionScroll setAutohidesScrollers:NO];
    
    NSTextView *descriptionTextView = [[[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)] autorelease];
    [descriptionTextView setIdentifier:@"descriptionTextView"];
    [descriptionTextView setAutoresizingMask:NSViewWidthSizable];
    [descriptionTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [descriptionTextView setRichText:NO];
    [descriptionTextView setDrawsBackground:YES];
    
    [descriptionTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
    [descriptionTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [descriptionTextView setVerticallyResizable:YES];
    [descriptionTextView setHorizontallyResizable:NO];
    [descriptionTextView setAutoresizingMask:NSViewWidthSizable];
    [[descriptionTextView textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
    [[descriptionTextView textContainer] setWidthTracksTextView:YES];
    
    NSNumber *yes = [NSNumber numberWithBool:YES];
    NSNumber *no = [NSNumber numberWithBool:NO];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:no, NSConditionallySetsEditableBindingOption, yes, NSContinuouslyUpdatesValueBindingOption, yes, NSValidatesImmediatelyBindingOption, nil];
    [descriptionTextView bind:@"value" toObject:self withKeyPath:@"munki_description" options:options];
    
    [descriptionScroll setDocumentView:descriptionTextView];
    [parentView addSubview:descriptionScroll];
    
    NSPopUpButton *descriptionPopupButton = self.descriptionPopupButton;
    [descriptionPopupButton setIdentifier:@"descriptionPopupButton"];
    [descriptionPopupButton setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [descriptionPopupButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [descriptionPopupButton setImagePosition:NSImageOnly];
    [parentView addSubview:descriptionPopupButton];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(nameLabel, nameField,
                                                         displayNameLabel, displayNameField,
                                                         versionLabel, versionField,
                                                         catalogsLabel, catalogsTokenField,
                                                         restartActionField, restartActionLabel,
                                                         unattendedLabel, unattendedButton,
                                                         forceAfterLabel, forceAfterCheckBox, forceAfterDatePicker,
                                                         descriptionLabel, descriptionTextView, descriptionScroll, descriptionPopupButton);
    
    /*
     Create a correct key view loop
     */
    [self.window setInitialFirstResponder:displayNameField];
    [displayNameField setNextKeyView:versionField];
    [versionField setNextKeyView:catalogsTokenField];
    [catalogsTokenField setNextKeyView:restartActionField];
    [restartActionField setNextKeyView:descriptionTextView];
    [descriptionTextView setNextKeyView:displayNameField];
    
    
    /*
     Text field layout
     */
    
    // Horizontal layout
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nameLabel]-[nameField(>=20)]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[displayNameLabel]-[displayNameField(>=20)]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[versionLabel]-[versionField(>=20)]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[catalogsLabel]-[catalogsTokenField(>=20)]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[restartActionLabel]-[restartActionField(>=20)]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[forceAfterLabel]-[forceAfterCheckBox]-[forceAfterDatePicker(>=20)]-[unattendedButton]-|" options:0 metrics:nil views:views]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:forceAfterLabel
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:forceAfterDatePicker
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.f constant:0.f]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:forceAfterCheckBox
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:forceAfterDatePicker
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.f constant:0.f]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:unattendedButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:forceAfterDatePicker
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.f constant:0.f]];
    
    [descriptionScroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[descriptionTextView(>=20)]|" options:0 metrics:nil views:views]];
    [descriptionScroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[descriptionTextView(>=20)]|" options:0 metrics:nil views:views]];
    [descriptionScroll setContentHuggingPriority:NSLayoutPriorityDefaultLow - 1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descriptionLabel]-[descriptionScroll(>=20)]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[descriptionPopupButton(38@200)]-(>=20)-|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:descriptionPopupButton
                                                           attribute:NSLayoutAttributeRight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:descriptionScroll
                                                           attribute:NSLayoutAttributeRight
                                                          multiplier:1.f constant:0.f]];
    
    
    /*
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:descriptionScroll
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:savePkginfoButton
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f constant:-8.0]];
    */
    
    
    
    // Vertical layout
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nameField]-[displayNameField]-[versionField]-[catalogsTokenField]-[restartActionField]-(16)-[forceAfterCheckBox]-(16)-[descriptionScroll(>=200)]"
                                                                        options:NSLayoutFormatAlignAllLeading
                                                                        metrics:nil
                                                                          views:views]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionScroll]-(2)-[descriptionPopupButton]|"
                                                                       options:NSLayoutFormatAlignAllTrailing
                                                                       metrics:nil
                                                                         views:views]];
    
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.window center];
    
    [self.window bind:@"title" toObject:self withKeyPath:@"product.productTitleWithVersion" options:nil];
    
    /*
     Configure the main split view
     */
    NSSplitView *splitView = self.splitView;
    [splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [splitView setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
    [splitView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSView *contentView = [[self window] contentView];
    
    /*
     Configure the 'Save Pkginfo...' and 'Cancel' buttons
     */
    NSButton *savePkginfoButton = [self addPushButtonWithTitle:NSLocalizedString(@"Save Pkginfo...", nil) identifier:@"savePkginfoButton" superView:contentView];
    [savePkginfoButton setAction:@selector(savePkginfoAction:)];
    [savePkginfoButton setKeyEquivalent:@"s"];
    [savePkginfoButton setKeyEquivalentModifierMask:NSCommandKeyMask];
    NSButton *cancelButton = [self addPushButtonWithTitle:NSLocalizedString(@"Cancel", nil) identifier:@"cancelButton" superView:contentView];
    [cancelButton setAction:@selector(cancelSavePkginfoAction:)];
    [cancelButton setKeyEquivalent:@"\e"]; // escape
    
    /*
     Window layout
     */
    NSDictionary *topLevelComponents = NSDictionaryOfVariableBindings(splitView, savePkginfoButton, cancelButton);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[cancelButton]-[savePkginfoButton]-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:topLevelComponents]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[splitView]-(20)-[savePkginfoButton]-|" options:0 metrics:nil views:topLevelComponents]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[splitView]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:topLevelComponents]];
    
    /*
     Split view children layout
     */
    NSView *leftSubView = self.leftSubView;
    [leftSubView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [leftSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSView *rightSubView = self.rightSubView;
    [rightSubView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [rightSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self setupPkginfoPreviewView:rightSubView];
    [self setupPkginfoView:leftSubView];
}


# pragma mark -
# pragma mark NSTokenFieldDelegate methods

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
    NSArray *catalogDictsFromDefaults = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultMunkiCatalogs"];
    NSArray *catalogs = [catalogDictsFromDefaults valueForKeyPath:@"title"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[d] %@", substring];
    NSArray *matchingCatalogs = [catalogs filteredArrayUsingPredicate:predicate];
    return matchingCatalogs;
}




@end
