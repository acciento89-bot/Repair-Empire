#import <UIKit/UIKit.h>
extern "C" void RepairImpact(){dispatch_async(dispatch_get_main_queue(), ^{UIImpactFeedbackGenerator *g=[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];[g impactOccurred];});}
