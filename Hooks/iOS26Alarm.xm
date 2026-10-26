#import <UIKit/UIKit.h>
#import <substrate.h>

static void styleAlarmView(UIView *view) {
    view.backgroundColor = [UIColor blackColor];
    for (UIView *sub in view.subviews) {
        if (sub.subviews.count > 0) styleAlarmView(sub);
        if ([sub isKindOfClass:[UILabel class]]) {
            UILabel *l = (UILabel *)sub;
            NSString *t = l.text;
            if (t.length >= 4 && [t rangeOfString:@":"].location != NSNotFound) {
                l.textColor = [UIColor whiteColor];
                l.font = [UIFont systemFontOfSize:l.font.pointSize weight:UIFontWeightHeavy];
            }
        }
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton *)sub;
            NSString *title = [b titleForState:UIControlStateNormal];
            if (title && [title containsString:@"稍后"]) {
                [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                b.backgroundColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1.0];
                b.layer.cornerRadius = b.bounds.size.height / 2;
                b.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
            } else if (title && [title containsString:@"停止"]) {
                [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                b.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
                b.layer.cornerRadius = b.bounds.size.height / 2;
            }
        }
    }
}

%hook CSFullscreenNotificationViewController
- (void)viewDidLoad {
    %orig;
    UIView *v = [(id)self view];
    v.backgroundColor = [UIColor blackColor];
}
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        styleAlarmView([(id)self view]);
    });
}
%end

%ctor {
    NSLog(@"iOS26Alarm injected");
}
