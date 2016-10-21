//
//  PrivateMessageViewController.m
//  LiveVideoDemo
//
//  Created by 伯明利 on 16/10/13.
//  Copyright © 2016年 bomingli. All rights reserved.
//

#import "PrivateMessageViewController.h"
#import "ChatViewController.h"

@interface PrivateMessageViewController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource>

@end

@implementation PrivateMessageViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"私信";
    
    self.delegate = self;
    self.dataSource = self;
    
    [self tableViewDidTriggerHeaderRefresh];
    
    self.tableView.frame = self.view.bounds;
    [self removeEmptyConversationsFromDB];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceive:) name:NOTIFICATION_MESSAGEDIDRECEIVE object:nil];
}

- (void)messageReceive:(NSNotification *)sender {
    [self refreshAndSortView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGEDIDRECEIVE object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshAndSortView];
}


- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EMClient sharedClient].chatManager deleteConversations:needRemoveConversations isDeleteMessages:YES completion:nil];
    }
}



#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel
{
    ChatViewController *chatVC = [[ChatViewController alloc] initWithConversationChatter:conversationModel.conversation.conversationId conversationType:conversationModel.conversation.type];
    [self.navigationController pushViewController:chatVC animated:YES];
}
                                                               
#pragma mark - EaseConversationListViewControllerDataSource

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController modelForConversation:(EMConversation *)conversation {
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
    if (model.conversation.type == EMConversationTypeChat) {
        model.avatarImage = [UIImage imageNamed:@"icon0"];
    } else if (model.conversation.type == EMConversationTypeGroupChat) {
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"subject"])
        {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.conversationId]) {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.subject forKey:@"subject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        NSDictionary *ext = conversation.ext;
        model.title = [ext objectForKey:@"subject"];
        imageName = [[ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        model.avatarImage = [UIImage imageNamed:imageName];
    }
    return model;
}

//最后一条消息展示时间样例
- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
    if (lastMessage) {
        latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    return latestMessageTime;
}

@end
