//
//  LeftMenuCell.m
//  Bus Time
//
//  Created by 朱 文杰 on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "LeftMenuCell.h"

@implementation LeftMenuCell

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
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIImage *bgImgFrag = [UIImage imageNamed:@"menu_cell_bg"];
    UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[bgImgFrag resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]];
    bgImgView.frame = self.contentView.frame;
    self.backgroundView = bgImgView;
    
    UIImage *hlBgImgFrag = [UIImage imageNamed:@"menu_cell_hl_bg"];
    UIImageView *hlBgImgView = [[UIImageView alloc] initWithImage:[hlBgImgFrag resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]];
    hlBgImgView.frame = self.contentView.frame;
    self.selectedBackgroundView = hlBgImgView;
    
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
