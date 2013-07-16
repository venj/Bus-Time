//
//  UIElementGeometry.h
//  Handy Foundation UIKit
//
//  Created by venj on 12-9-28.
//  Copyright (c) 2012年 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

// iPhone screen width
#define UI_IPHONE_SCREEN_WIDTH 320
#define UI_IPHONE_SCREEN_WIDTH_F 320.0

// Old-school iPhone screen height
#define UI_IPHONE_SCREEN_HEIGHT 480
#define UI_IPHONE_SCREEN_HEIGHT_F 480.0

// New iPhone screen height
#define UI_IPHONE_WIDE_SCREEN_HEIGHT 568
#define UI_IPHONE_WIDE_SCREEN_HEIGHT_F 568.0

// Status bar height
#define UI_IPHONE_STATUS_BAR_HEIGHT 20
#define UI_IPHONE_STATUS_BAR_HEIGHT_F 20.0

// Status bar height when phone call comming
#define UI_IPHONE_STATUS_BAR_CALLING_HEIGHT 40
#define UI_IPHONE_STATUS_BAR_CALLING_HEIGHT_F 40.0

// Toolbar height
#define UI_IPHONE_TOOL_BAR_HEIGHT 44
#define UI_IPHONE_TOOL_BAR_HEIGHT_F 44.0

// Tab bar height
#define UI_IPHONE_TAB_BAR_HEIGHT 49
#define UI_IPHONE_TAB_BAR_HEIGHT_F 49.0

// Navigation bar height
#define UI_IPHONE_NAV_BAR_HEIGHT 44
#define UI_IPHONE_NAV_BAR_HEIGHT_F 44.0

// Navigation bar with prompt height
#define UI_IPHONE_NAV_BAR_WITH_PROMPT_HEIGHT 74
#define UI_IPHONE_NAV_BAR_WITH_PROMPT_HEIGHT_F 74.0

// Navigation bar icon width and height
#define UI_IPHONE_NAV_BAR_ICON_SIDE 20
#define UI_IPHONE_NAV_BAR_ICON_SIDE_F 20.0

// Navigation tab icon width and height
#define UI_IPHONE_TAB_BAR_ICON_SIDE 30
#define UI_IPHONE_TAB_BAR_ICON_SIDE_F 30.0

// Soft keyboard height when UI is in portrait
#define UI_IPHONE_PORTRAIT_KEYBOARD_HEIGHT 216
#define UI_IPHONE_PORTRAIT_KEYBOARD_HEIGHT_F 216.0

// UIPickerView height
#define UI_IPHONE_PICKER_VIEW_HEIGHT 216
#define UI_IPHONE_PICKER_VIEW_HEIGHT_F 216.0

// Soft keyboard height when UI is in landscape
#define UI_IPHONE_LANDSCAPE_KEYBOARD_HEIGHT 162
#define UI_IPHONE_LANDSCAPE_KEYBOARD_HEIGHT_F 162.0

// Dynamic determine iPhone screen height and (future different) width
CGFloat UIiPhoneDeviceWidth();
CGFloat UIiPhoneDeviceHeight();


