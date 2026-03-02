#import "MWMEditorCategoryCell.h"
#import "MWMEditorCommon.h"
#import "SwiftBridge.h"

CGFloat const kDetailShortRightSpace = 16;

@interface MWMEditorCategoryCell ()

@property(weak, nonatomic) IBOutlet UIImageView *accessoryIcon;
@property(weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property(weak, nonatomic) IBOutlet UILabel *detail;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *detailRightSpace;
@property(weak, nonatomic) id<MWMEditorCellProtocol> delegate;

@end

@implementation MWMEditorCategoryCell

- (void)configureWithDelegate:(id<MWMEditorCellProtocol>)delegate
                         icon:(UIImage *)icon
                  detailTitle:(NSString *)detail
                   isCreating:(BOOL)isCreating {
  self.delegate = delegate;
  self.detail.text = detail;
  self.categoryIcon.image = icon;
  self.accessoryIcon.hidden = NO;
  self.selectedBackgroundView = [[UIView alloc] init];
  self.selectedBackgroundView.styleName = @"PressBackground";
}

- (IBAction)cellTap {
  [self.delegate cellDidPressButton:self];
}

@end
