#import <UIKit/UIKit.h>
#import <substrate.h>

static void writeLog(NSString *msg) {
    NSString *line = [NSString stringWithFormat:@"%@ %@\n", [NSDate date], msg];
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
    NSString *p = @"/var/mobile/iOS26Alarm.log";
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:p];
    if (fh) { [fh seekToEndOfFile]; [fh writeData:data]; }
    else { [data writeToFile:p atomically:YES]; }
}

static BOOL styled = NO;

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

static void sweep(void) {
    for (UIWindow *win in [UIApplication sharedApplication].windows) {
        for (UIView *v in win.subviews) {
            // 找全屏黑色/红色的闹钟界面
            if (v.bounds.size.height > 500 && v.subviews.count > 3) {
                // 检查有没有"稍后提醒"或"停止"按钮
                BOOL hasAlarm = NO;
                for (UIView *sub in v.subviews) {
                    if ([sub isKindOfClass:[UIButton class]]) {
                        NSString *t = [(UIButton *)sub titleForState:UIControlStateNormal];
                        if (t && ([t containsString:@"稍后"] || [t containsString:@"停止"] || [t containsString:@"提醒"])) {
                            hasAlarm = YES; break;
                        }
                    }
                }
                if (hasAlarm && !styled) {
                    writeLog([NSString stringWithFormat:@"found alarm view %@", NSStringFromClass([v class])]);
                    styleAlarmView(v);
                    styled = YES;
                }
            }
        }
    }
}

%hook CSFullscreenNotificationViewController
- (void)viewDidLoad {
    %orig;
    writeLog(@"CSFullscreenNotificationViewController viewDidLoad");
    UIView *v = [(id)self view];
    v.backgroundColor = [UIColor blackColor];
}
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    writeLog(@"CSFullscreenNotificationViewController viewDidAppear");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        styleAlarmView([(id)self view]);
    });
}
%end

%ctor {
    writeLog(@"iOS26Alarm injected");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull t) {
            sweep();
        }];
    });
}
