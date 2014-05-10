//
//  BusInfoCell.m
//  BusTime
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusInfoCell.h"

@implementation BusInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone || self.contentView.frame.size.width <= 320) {
        CGRect contentViewFrame = self.contentView.frame;
        CGRect textLabelFrame = self.textLabel.frame;
        CGRect detailedTextLabelFrame = self.detailTextLabel.frame;
        CGRect newTextLabelFrame = CGRectMake(textLabelFrame.origin.x, textLabelFrame.origin.y - textLabelFrame.size.height / 2, textLabelFrame.size.width, textLabelFrame.size.height);
        self.textLabel.frame = newTextLabelFrame;
        CGRect newDetailedTextLabelFrame = CGRectMake(textLabelFrame.origin.x, textLabelFrame.origin.y + textLabelFrame.size.height / 2, contentViewFrame.size.width - 40, detailedTextLabelFrame.size.height);
        self.detailTextLabel.frame = newDetailedTextLabelFrame;
        self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        CGRect newContentViewFrame = CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, contentViewFrame.size.width, contentViewFrame.size.height + detailedTextLabelFrame.size.height);
        self.contentView.frame = newContentViewFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
