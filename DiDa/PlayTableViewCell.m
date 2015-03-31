//
//  PlayTableViewCell.m
//  DiDa
//
//  Created by Bruce Yee on 10/29/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "PlayTableViewCell.h"
#import "AppDelegate.h"

@implementation PlayTableViewCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        DLog(@"");
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)touchDeleteButton:(id)sender {
//    DLog(@"%@ %d", [sender class], self.tag);
    [delegate touchedDeleteButton:self.tag title:memoLabel.text isInView:YES];
}

- (IBAction)touchShareButton:(id)sender {
    [delegate touchedShareButton:self.tag title:memoLabel.text];
}

- (IBAction)touchDetailButton:(id)sender {
    [delegate touchedDetailButton:self.tag title:memoLabel.text];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    long seconds = ti % 60;
    if (ti < 60) {
        return [NSString stringWithFormat:@"0:%02li", seconds];
    }
    long minutes = (ti / 60) % 60;
    if (ti < 60 * 60) {
        return [NSString stringWithFormat:@"%02li:%02li", minutes, seconds];
    }
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li", hours, minutes, seconds];
}

- (void)configureWithRecord:(Record *)record {
    UIImage *img = [UIImage imageNamed:@"mark"];
    [playSlider setThumbImage:img forState:UIControlStateNormal];
    pathString = record.path;
    audioDuration = [record.length doubleValue];
    playSlider.minimumValue = 0.0;
    playSlider.maximumValue = audioDuration;
    playSlider.value = 0.0;
//    [delegate setCurrentTimeOfPlayer:playSlider.value];
    NSString *endTimeString = [self stringFromTimeInterval:audioDuration];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    startLabel.text = @"0:00";
    [playSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    memoLabel.text = record.memo;
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-d HH:mm:ss"];
    [formatter setTimeZone:timezone];
    NSString *correctDate = [formatter stringFromDate:record.date];
    dateLabel.text = correctDate;
    if (record.unit && record.unit.length != 0) {
        locationLabel.text = record.unit;
        locateImageView.hidden = NO;
    } else {
        locationLabel.text = @"";
        locateImageView.hidden = YES;
    }
    secondsLabel.text = [NSString stringWithFormat:@"%.1f", [record.length floatValue]];
}

- (IBAction)touchPlayButton:(id)sender {
    [self.delegate touchedPlayButton:self.tag path:pathString sender:sender];
    if (playButton.selected == YES) {
        playButton.selected = NO;
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    } else {
        playButton.selected = YES;
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
}

- (IBAction)sliderChanged:(id)sender {
    [delegate setCurrentTimeOfPlayer:playSlider.value];
    NSTimeInterval timeValue = audioDuration - playSlider.value;
    if (timeValue < 0) {
        timeValue = 0.0;
    }
    NSString *endTimeString = [self stringFromTimeInterval:timeValue];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    NSString *startTimeString = [self stringFromTimeInterval:playSlider.value];
    startLabel.text = startTimeString;
}

- (void)updateSlider {
    NSTimeInterval currentTime = [delegate getCurrentTimeOfPlayer];
    BOOL isPlaying = [delegate isPlaying];
    playSlider.value = currentTime;
    NSTimeInterval timeValue = audioDuration - currentTime;
    if (timeValue < 0) {
        timeValue = 0.0;
    }
    NSString *endTimeString = [self stringFromTimeInterval:timeValue];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    NSString *startTimeString = [self stringFromTimeInterval:currentTime];
    startLabel.text = startTimeString;
    if (isPlaying) {
        playButton.selected = YES;
    } else {
        playButton.selected = NO;
    }
}

@end