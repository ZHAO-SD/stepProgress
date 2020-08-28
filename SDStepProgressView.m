


#import "SDStepProgressView.h"

@interface SDStepProgressView()

///未完成的线
@property (nonatomic, strong)UIView *lineUndo;
///已完成的线
@property (nonatomic, strong)UIView *lineDone;
///保存灰色圆圈
@property (nonatomic, strong)NSMutableArray *cricleMarks;
///保存第几步标题
@property (nonatomic, strong)NSMutableArray *titleLabels;
///圆圈步骤
@property (nonatomic, strong)UILabel *indicatorLabel;

@end


@implementation SDStepProgressView

- (instancetype)initWithFrame:(CGRect)frame Titles:(nonnull NSArray *)titles
{
    if (self = [super initWithFrame:frame]){
        _stepIndex = 0;
        
        _titles = titles;
        
        [self setupUI];
    }
    return self;
}

-(void)setTitles:(NSArray *)titles{
    _titles = titles;
    
    [self setupUI];
    
    [self layoutSubviews];
}

#pragma mark - 初始化UI
-(void)setupUI{
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    
    //未完成的线
    self.lineUndo = [[UIView alloc]init];
    self.lineUndo.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.lineUndo];
    
    //已完成的线
    self.lineDone = [[UIView alloc]init];
    self.lineDone.backgroundColor = TINTCOLOR;
    [self addSubview:self.lineDone];
    
    for (NSString *title in self.titles){
        //底部第几步
        UILabel *stepLabel = [[UILabel alloc]init];
        stepLabel.text = title;
        stepLabel.numberOfLines = 0;
        stepLabel.adjustsFontSizeToFitWidth = YES;
        stepLabel.textColor = [UIColor lightGrayColor];
        stepLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:stepLabel];
        [self.titleLabels addObject:stepLabel];
        
        //圆形
        UIView *cricle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 13)];
        cricle.backgroundColor = [UIColor lightGrayColor];
        cricle.layer.cornerRadius = 13.f / 2;
        [self addSubview:cricle];
        [self.cricleMarks addObject:cricle];
    }
    //当前步 圆圈数字
    self.indicatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.indicatorLabel.textColor = TINTCOLOR;
    self.indicatorLabel.backgroundColor = [UIColor whiteColor];
    self.indicatorLabel.layer.cornerRadius = 23.f / 2;
    self.indicatorLabel.layer.borderColor = [TINTCOLOR CGColor];
    self.indicatorLabel.layer.borderWidth = 1;
    self.indicatorLabel.layer.masksToBounds = YES;
    [self addSubview:self.indicatorLabel];
    
    self.stepIndex = 0;
}




#pragma mark - method

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //最多显示10个
    NSInteger count = self.titles.count > 10 ? 10 : self.titles.count;
    //每个的宽度
    NSInteger perWidth = self.frame.size.width / count;
    //滚动范围
    [self setContentSize:CGSizeMake(perWidth*self.titles.count, 0)];
    
    //灰色线frame
    self.lineUndo.frame = CGRectMake(perWidth*0.5, self.frame.size.height / 4, self.contentSize.width - perWidth, 3);
    
    CGFloat startX = self.lineUndo.frame.origin.x;
    
    for (int i = 0; i < self.titles.count; i++){
        //取出灰色的圆
        UIView *cricle = [self.cricleMarks objectAtIndex:i];
        if (cricle != nil){
            //设置位置
            cricle.center = CGPointMake(i * perWidth + startX, self.lineUndo.center.y);
        }
        
        //取出标题
        UILabel *titleLabel = [self.titleLabels objectAtIndex:i];
        if (titleLabel != nil){
            //设置位置
            titleLabel.frame = CGRectMake(perWidth * i, self.frame.size.height / 2, self.contentSize.width / _titles.count, self.frame.size.height / 2);
            
            titleLabel.numberOfLines = 2;
        }
    }
    
    self.stepIndex = _stepIndex;
}

- (NSMutableArray *)cricleMarks{
    if (_cricleMarks == nil){
        _cricleMarks = [NSMutableArray arrayWithCapacity:self.titles.count];
    }
    return _cricleMarks;
}

- (NSMutableArray *)titleLabels{
    if (_titleLabels == nil){
        _titleLabels = [NSMutableArray arrayWithCapacity:self.titles.count];
    }
    return _titleLabels;
}

#pragma mark - public method

- (void)setStepIndex:(NSInteger)stepIndex{
    if (stepIndex >= 0 && stepIndex < self.titles.count){
        _stepIndex = stepIndex;
        
        //屏幕宽度内最多显示10个
        NSInteger count = self.titles.count > 10 ? 10 : self.titles.count;
        CGFloat perWidth = self.frame.size.width / count;
        
        self.indicatorLabel.text = [NSString stringWithFormat:@"%zd", stepIndex + 1];
        self.indicatorLabel.center = ((UIView *)[self.cricleMarks objectAtIndex:stepIndex]).center;
        
        self.lineDone.frame = CGRectMake(self.lineUndo.frame.origin.x, self.lineUndo.frame.origin.y, perWidth * stepIndex, self.lineUndo.frame.size.height);
        
        for (int i = 0; i < self.titles.count; i++){
            UIView *cricle = [self.cricleMarks objectAtIndex:i];
            if (cricle != nil){
                if (i <= stepIndex){
                    cricle.backgroundColor = TINTCOLOR;
                }else{
                    cricle.backgroundColor = [UIColor lightGrayColor];
                }
            }
            
            UILabel *titleLabel = [self.titleLabels objectAtIndex:i];
            if (titleLabel != nil){
                if (i <= stepIndex){
                    titleLabel.textColor = TINTCOLOR;
                }else{
                    titleLabel.textColor = [UIColor lightGrayColor];
                }
            }
        }
    }
}

- (void)setStepIndex:(NSInteger)stepIndex Animation:(BOOL)animation{
    if (stepIndex >= 0 && stepIndex < self.titles.count){
        if (animation){
            [UIView animateWithDuration:0.5 animations:^{
                self.stepIndex = stepIndex;
            }];
        }else{
            self.stepIndex = stepIndex;
        }
        
        //最大允许滚动的距离
        CGFloat maxOffsetX = self.contentSize.width - self.bounds.size.width;
        //最小就是0
        CGFloat minOffsetX = 0;
        //可以滚动的范围
        CGFloat needScrollOffsetX = 41*stepIndex - self.bounds.size.width * 0.5;

        if (needScrollOffsetX < maxOffsetX && needScrollOffsetX >minOffsetX) {

            [self setContentOffset:CGPointMake(needScrollOffsetX, 0) animated:YES];

        }else if(needScrollOffsetX >= maxOffsetX){

            [self setContentOffset:CGPointMake(maxOffsetX, 0) animated:YES];
            
        }else if(needScrollOffsetX <= minOffsetX){

            [self setContentOffset:CGPointMake(minOffsetX, 0) animated:YES];
        }
        
        
    }
    
    
    
    
}


@end
