# PopIMLibSDK 开发文档

## 目录
- [一、SDK 概述](#一sdk-概述)
- [二、集成准备](#二集成准备)
- [三、初始化连接](#三初始化连接)
- [四、会话管理](#四会话管理)
- [四-1、超级群管理](#四-1超级群管理)
- [五、消息相关](#五消息相关)
- [六、推送相关](#六推送相关)
- [七、日志与版本](#七日志相关)
- [八、Public 文件说明](#八public-文
件说明)
- [九、错误码参考](#九错误码参考)
- [十、常见问题](#十常见问题)
- [十一、附录](#十一附录)

## 一、SDK 概述

### 1.1 简介
PopIMLibSDK 是一套功能完备的即时通讯开发工具包，提供稳定高效的即时消息收发、会话管理、用户状态同步、推送集成等核心能力，支持 iOS 平台的 Swift 与 Objective-C 混编项目，帮助开发者快速构建具备即时通讯功能的应用。

### 1.2 核心功能
- **实时消息收发**：支持文本、图片、语音、视频、自定义消息等多种类型
- **多类型会话管理**：单聊、群聊、系统通知等会话类型
- **连接状态监听**：自动重连机制，确保连接稳定性
- **消息状态同步**：已读状态同步与未读计数管理
- **离线消息同步**：历史消息查询与离线消息自动同步
- **推送集成**：APNs 推送与自定义推送支持
- **会话管理**：置顶、免打扰、标签分类等高级功能
- **消息操作**：撤回、删除、搜索等完整消息操作

### 1.3 环境要求
- 系统版本：iOS 14.0+
- 开发工具：Xcode 16.0+
- 编程语言：Swift 5.0+ 或 Objective-C
- 依赖：无第三方框架依赖


## 二、集成准备

### 2.1 账号与配置
1. 登录 [PopIM 开发者平台](https://developer.popim.com) 注册账号并创建应用，获取 `AppKey`（应用唯一标识）。
2. 在平台配置 iOS 推送证书（用于远程推送功能）。
[推送证书配置参考](https://docs.popim.com/ios-imlib/push/apns)

### 2.2 导入 SDK

#### CocoaPods 集成
在 `Podfile` 中添加：
```ruby
use_frameworks!

target 'Example' do
    pod 'PopIMLib', '1.1.3.2'
end
```
终端执行 `pod install` 或 `pod update` 完成导入。

> 注意：暂不支持 Apple Privacy Manifest (PrivacyInfo.xcprivacy)。

### 2.3 导入 SDK 头文件
- Objective-C项目：
  ```objc
  #import <PopIMLib/PopIMLib-Swift.h>
  ```
- Swift项目：
  ```swift
  import PopIMLib
  ```

## 三、初始化连接

### 3.1 初始化 SDK


#### 3.1.1 获取单例
PopIMLibSDK 采用单例模式，所有操作通过单例实例进行：

**Swift**
```swift
import PopIMLib
let imSDK = PopIMLibSDK.shared
```

**Objective-C**
```objc
#import <PopIMLib/PopIMLib-Swift.h>
PopIMLibSDK *imSDK = [PopIMLibSDK shared];
```

#### 3.1.2 初始化配置
使用从开发者平台获取的 `AppKey` 初始化 SDK：

**Swift**
```swift
// 初始化SDK
// @param appKey 应用唯一标识，从开发者平台获取
imSDK.initWithAppKey("your_app_key")
```

**Objective-C**
```objc
// 初始化SDK
// @param appKey 应用唯一标识，从开发者平台获取
[imSDK initWithAppKey:@"your_app_key"];
```

### 3.2 连接服务器
初始化成功后，通过用户 Token 连接 IM 服务器（Token 需从业务服务端获取）：

**Swift**
```swift
// 连接IM服务器
// @param token 身份验证令牌，通过服务端API获取的用户Token
// @param userId 用户唯一标识，业务系统中的用户ID
// @note 建议在连接之前先设置连接状态监听，以便接收连接状态变化回调
imSDK.connectWithToken("user_token_xxx", userId: "user123")
```

**Objective-C**
```objc
// 连接IM服务器
// @param token 身份验证令牌，通过服务端API获取的用户Token
// @param userId 用户唯一标识，业务系统中的用户ID
// @note 建议在连接之前先设置连接状态监听，以便接收连接状态变化回调
[imSDK connectWithToken:@"user_token_xxx" userId:@"user123"];
```

### 3.3 退出服务
主动断开IM服务器连接。

**Swift**
```swift
// 主动断开连接
// @param isReceivePush 是否允许推送，默认为 true。如果设置为 false，将调用推送设备清除接口
imSDK.disConnect(isReceivePush: true)
```
**Objective-C**
```objc
// 主动断开连接
// @param isReceivePush 是否允许推送，默认为 YES。如果设置为 NO，将调用推送设备清除接口
[imSDK disConnectWithIsReceivePush:YES];
```

### 3.4 连接状态管理

#### 3.4.1 添加连接状态监听
添加连接状态变化监听，接收连接状态变化回调。

**Swift**
```swift
// 添加连接状态监听
// @param delegate 连接状态代理，需要实现PopIMConnectProtocol协议
imSDK.addConnectionStatusChangeDelegate(self)
```
**Objective-C**
```objc
// 添加连接状态监听
// @param delegate 连接状态代理，需要实现PopIMConnectProtocol协议
[imSDK addConnectionStatusChangeDelegate:self];
```

#### 3.4.2 移除连接状态监听
移除连接状态变化监听。

**Swift**
```swift
// 移除连接状态监听
// @param delegate 要移除的连接状态代理
imSDK.removeConnectionStatusChangeDelegate(self)
```
**Objective-C**
```objc
// 移除连接状态监听
// @param delegate 要移除的连接状态代理
[imSDK removeConnectionStatusChangeDelegate:self];
```

#### 3.4.3 连接状态代理方法回调
实现 `PopIMConnectProtocol` 协议监听连接状态变化：

**Swift**
```swift
extension ViewController: PopIMConnectProtocol {
    // 代理方法 - 连接状态发生改变
    func onConnectionStatusChange(status: PopIMConnectState) {
        // status: PopIMConnectState 连接状态
        switch status {
        case .unknown:
            // 初始状态
            break
        case .inConnect:
            // 连接中
            break
        case .success:
            // 连接成功
            break
        case .reconnect:
            // 断开重连
            break
        case .fail:
            // 连接失败
            break
        @unknown default:
            break
        }
    }
    
    // 代理方法 - 长连接错误回调
    // @param errMsg 错误信息
    // @param code 错误码（401：非法token，500：服务端内部错误，-1：其它错误）
    // @discussion 错误码为401或500时，长连接会自动断开且不会重试
    func onConnectionError(errMsg: String, code: Int) {
        switch code {
        case 401:
            // 非法token，需要重新获取token
            break
        case 500:
            // 服务端内部错误
            break
        default:
            // 其它错误
            break
        }
    }
}
```

**Objective-C**
```objc
@interface ViewController () <PopIMConnectProtocol>
@end

@implementation ViewController

// 代理方法 - 连接状态发生改变
- (void)onConnectionStatusChangeWithStatus:(PopIMConnectState)status {
    // status: PopIMConnectState 连接状态
    switch (status) {
        case PopIMConnectStateUnknown:
            // 初始状态
            break;
        case PopIMConnectStateInConnect:
            // 连接中
            break;
        case PopIMConnectStateSuccess:
            // 连接成功
            break;
        case PopIMConnectStateReconnect:
            // 断开重连
            break;
        case PopIMConnectStateFail:
            // 连接失败
            break;
        default:
            break;
    }
}

// 代理方法 - 长连接错误回调
// @param errMsg 错误信息
// @param code 错误码（401：非法token，500：服务端内部错误，-1：其它错误）
- (void)onConnectionErrorWithErrMsg:(NSString *)errMsg code:(NSInteger)code {
    if (code == 401) {
        // 非法token，需要重新获取token
    } else if (code == 500) {
        // 服务端内部错误
    }
}

@end
```

#### 3.4.4 主动获取连接状态
获取当前 IM 服务器连接状态。

**Swift**
```swift
// 获取当前连接状态
// @return PopIMConnectState状态枚举，返回当前连接状态
let connectState =  imSDK.getConnectStatus()
```

**Objective-C**
```objc
// 获取当前连接状态
// @return PopIMConnectState状态枚举，返回当前连接状态
PopIMConnectState connectState =  [imSDK getConnectStatus];
```

#### 3.4.5 获取连接协议标识
获取当前长连接使用的协议标识，用于 UI 显示（如 "在线-ws"、"在线-mq"）。

**Swift**
```swift
// 获取当前长连接协议标识
// @return String 协议标识（"ws" 或 "mq"）
let protocolTag = imSDK.getConnectionProtocolTag()
```

**Objective-C**
```objc
// 获取当前长连接协议标识
// @return String 协议标识（"ws" 或 "mq"）
NSString *protocolTag = [imSDK getConnectionProtocolTag];
```

## 四、会话管理


### 4.1 会话代理
通过实现 `PopIMConversationProtocol` 协议监听会话列表数据或者状态变化：

**Swift**
```swift
// 添加会话代理
imSDK.addConversationChangeDelegate(self)
// 移除会话代理
imSDK.removeConversationChangeDelegate(self)

// 遵守会话代理协议
extension ViewController: PopIMConversationProtocol {
    // 会话发生改变, 有新会话、会话状态如置顶、免打扰等发生改变都会触发这个代理
    // 收到通知后，通过 getConversationList 获取最新数据
    func conversationDidChange() {
        imSDK.getConversationList { conversations in
            // 更新会话列表
        }
    }
    
    // 点击推送的会话，需要配置后面推送设置才会回调
    // @param type 会话的类型
    // @param targetId 对方ID
    // @param pushData 发消息时传的pushData内容，原封不动返回
    func didClickPushConversation(_ type: PopIMMessageSessionType, targetId: String, pushData: String) {
        
    }
    
    // 会话属性变更回调（仅服务端推送触发，本地操作不回调）
    // @param conversationType 会话类型
    // @param targetId 会话目标ID
    // @param channelId 频道ID
    // @param changeType 变更类型（未读数/置顶/免打扰）
    // @discussion 当收到服务端 clearReadSync 导致未读数变化、或 SessionChangeNtf 导致置顶/免打扰状态变化时触发。
    // 本地主动操作（如 clearMessagesUnreadStatus、setConversationToTop、setConversationNotificationStatus）不会触发此回调。
    func conversationPropertyDidChange(conversationType: PopIMMessageSessionType, targetId: String, channelId: String, changeType: PopIMConversationPropertyChangeType) {
        switch changeType {
        case .unreadCount:
            // 未读数变更
            break
        case .topStatus:
            // 置顶状态变更
            break
        case .notificationStatus:
            // 免打扰状态变更
            break
        @unknown default:
            break
        }
    }
}
```

**Objective-C**
```objc
// 添加会话代理
[imSDK addConversationChangeDelegate:self];
// 移除会话代理
[imSDK removeConversationChangeDelegate:self];

// 遵循代理
@interface ViewController () <PopIMConversationProtocol>
@end

@implementation ViewController

// 会话发生改变
// 收到通知后，通过 getConversationList 获取最新数据
- (void)conversationDidChange {
    [imSDK getConversationListWithCompletion:^(NSArray<PopIMConversationModel *> * conversations) {
        // 更新会话列表
    }];
}

// 点击推送的会话
- (void)didClickPushConversation:(enum PopIMMessageSessionType)type targetId:(NSString *)targetId pushData:(NSString *)pushData {

}

// 会话属性变更回调（仅服务端推送触发，本地操作不回调）
- (void)conversationPropertyDidChangeWithConversationType:(PopIMMessageSessionType)conversationType targetId:(NSString *)targetId channelId:(NSString *)channelId changeType:(PopIMConversationPropertyChangeType)changeType {
    switch (changeType) {
        case PopIMConversationPropertyChangeTypeUnreadCount:
            // 未读数变更
            break;
        case PopIMConversationPropertyChangeTypeTopStatus:
            // 置顶状态变更
            break;
        case PopIMConversationPropertyChangeTypeNotificationStatus:
            // 免打扰状态变更
            break;
        default:
            break;
    }
}

@end
```

### 4.2 会话加载

#### 4.2.1 获取所有会话
获取所有会话列表，先按照置顶状态排序，再按最后一条消息时间倒序。

**Swift**
```swift
// 获取所有会话列表
// @param completion 结果回调，返回所有会话数组（[PopIMConversationModel]类型），按置顶状态和最后消息时间排序
imSDK.getConversationList { conversations in
    
}
```

**Objective-C**
```objc
// 获取所有会话列表
// @param completion 结果回调，返回所有会话数组（[PopIMConversationModel]类型），按置顶状态和最后消息时间排序
[imSDK getConversationListWithCompletion:^(NSArray<PopIMConversationModel *> * conversations) {
    
}];
```

#### 4.2.2 分页获取会话列表
根据会话类型和开始时间分页获取会话列表。

**Swift**
```swift
// 分页获取会话列表
// @param conversationTypeList 会话类型的数组，指定要查询的会话类型集合
// @param count 每页获取的数量，控制每次返回的会话数量
// @param startTime 开始时间戳，用于分页查询的起始时间点
// @param completion 结果回调，返回符合条件的会话数组 [PopIMConversationModel]
imSDK.getConversationListByPage(conversationTypeList: [.privatechat], count: 20, startTime: 0) { conversations in
    
}
```

**Objective-C**
```objc
// 分页获取会话列表
// @param conversationTypeList 会话类型的数组，指定要查询的会话类型集合
// @param count 每页获取的数量，控制每次返回的会话数量
// @param startTime 开始时间戳，用于分页查询的起始时间点
// @param completion 结果回调，返回符合条件的会话数组 [PopIMConversationModel]
[imSDK getConversationListByPageWithConversationTypeList:@[@(PopIMMessageSessionTypePrivatechat)] count:20 startTime:0 completion:^(NSArray<PopIMConversationModel *> * conversations) {
    
}];
```

#### 4.2.3 获取未读会话列表
获取有未读消息的会话列表。

**Swift**
```swift
// 获取未读会话列表
// @param conversationTypeList 会话类型集合，指定要查询的会话类型，传空数组返回全部类型的未读会话
// @param containBlocked 是否包含免打扰会话，默认为true。true：包含。false：不包含。
// @param completion 异步结果回调，返回符合条件的未读会话数组（[PopIMConversationModel]类型）
imSDK.getUnreadConversationList(conversationTypeList: [.privatechat], containBlocked: true) { conversations in
    
}
```

**Objective-C**
```objc
// 获取未读会话列表
// @param conversationTypeList 会话类型集合，指定要查询的会话类型，传空数组返回全部类型的未读会话
// @param containBlocked 是否包含免打扰会话
// @param completion 异步结果回调，返回符合条件的未读会话数组（[PopIMConversationModel]类型）
[imSDK getUnreadConversationListWithConversationTypeList:@[@(PopIMMessageSessionTypePrivatechat)] containBlocked:YES completion:^(NSArray<PopIMConversationModel *> * conversations) {
    
}];
```

#### 4.2.4 获取单个会话
根据会话类型和目标ID获取指定会话信息。

**Swift**
```swift
// 获取单个会话
// @param conversationType 会话类型，指定会话的类型（单聊/群聊/系统消息/超级群）
// @param targetId 会话对方的用户ID，目标用户或群组ID
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param completion 获取结果回调，返回会话对象（PopIMConversationModel类型），可能为nil
imSDK.getConversation(conversationType: .privatechat, targetId: "10086", channelId: "") { conversationModel in
    
}
```

**Objective-C**
```objc
// 获取单个会话
// @param conversationType 会话类型，指定会话的类型（单聊/群聊/系统消息/超级群）
// @param targetId 会话对方的用户ID，目标用户或群组ID
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param completion 获取结果回调，返回会话对象（PopIMConversationModel类型），可能为nil
[imSDK getConversationWithConversationType: PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" completion:^(PopIMConversationModel * conversationModel) {
    
}];
```

### 4.3 会话未读数管理

#### 4.3.1 清除会话未读数
清除指定会话的未读消息数，更新完成后会触发代理方法 `conversationDidChange`。

**Swift**
```swift
// 清除会话未读数
// @param conversation 会话对象，要清除未读数的会话
// @note 更新完成之后会触发delegate - conversationDidChange
imSDK.clearMessagesUnreadStatus(conversationModel)
```

**Objective-C**
```objc
// 清除会话未读数
// @param conversation 会话对象，要清除未读数的会话
// @note 更新完成之后会触发delegate - conversationDidChange
[imSDK clearMessagesUnreadStatus:conversationModel];
```

#### 4.3.2 获取所有会话总未读消息数
获取所有会话的未读消息总数。

**Swift**
```swift
// 获取所有会话总未读消息数
// @param containBlocked 是否包含免打扰会话的未读消息数，默认为true。true：包含。false：不包含。
// @param completion 获取的结果回调
imSDK.getTotalUnreadCount(containBlocked: true) { totalUnreadCount in
    
}
```

**Objective-C**
```objc
// 获取所有会话总未读消息数（默认包含免打扰）
[imSDK getTotalUnreadCountWithCompletion:^(NSInteger totalUnreadCount) {
    
}];

// 获取所有会话总未读消息数（指定是否包含免打扰）
// @param containBlocked 是否包含免打扰会话的未读消息数
[imSDK getTotalUnreadCountWithContainBlocked:YES completion:^(NSInteger totalUnreadCount) {
    
}];
```

#### 4.3.3 获取单个会话的未读数
获取指定会话的未读消息数。

**Swift**
```swift
// 获取单个会话的未读数
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 获取的结果
imSDK.getUnreadCount(conversationType: .privatechat, targetId: "10086") { unreadCount in
    
}
```

**Objective-C**
```objc
// 获取单个会话的未读数
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 获取的结果
[imSDK getUnreadCountWithConversationType: PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(NSInteger unreadCount) {
    
}];
```

#### 4.3.4 按会话类型获取总未读消息数
根据指定的会话类型列表，获取这些类型会话的未读消息总数。

**Swift**
```swift
// 按会话类型获取总未读消息数
// @param conversationTypeList 会话类型列表
// @param containBlocked 是否包含免打扰的会话
// @param completion 获取的结果回调
imSDK.getUnreadCount(conversationTypeList: [.privatechat], containBlocked: false) { totalUnreadCount in
    
}
```

**Objective-C**
```objc
// 按会话类型获取总未读消息数
// @param conversationTypeList 会话类型列表
// @param containBlocked 是否包含免打扰的会话
// @param completion 获取的结果回调
[imSDK getUnreadCountWithConversationTypeList:@[@(PopIMMessageSessionTypePrivatechat)] containBlocked:NO completion:^(NSInteger totalUnreadCount) {
    
}];
```

#### 4.3.5 获取单个会话的@消息数量
获取指定会话的@消息数量。

**Swift**
```swift
// 获取单个会话的@消息数量
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @return 返回@消息数量，如果会话不存在返回0
let mentionedCount = imSDK.getMentionedCount(conversationType: .privatechat, targetId: "10086")
```

**Objective-C**
```objc
// 获取单个会话的@消息数量
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @return 返回@消息数量，如果会话不存在返回0
NSInteger mentionedCount = [imSDK getMentionedCountWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086"];
```

#### 4.3.6 获取第一条未读消息
获取指定会话中最旧的一条未读消息。

**Swift**
```swift
// 获取第一条未读消息（最旧的未读消息）
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 获取结果回调，返回最旧的一条未读消息，若无未读消息则返回 nil
imSDK.getFirstUnreadMessage(conversationType: .privatechat, targetId: "10086") { messageModel in
    
}
```

**Objective-C**
```objc
// 获取第一条未读消息（最旧的未读消息）
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 获取结果回调，返回最旧的一条未读消息，若无未读消息则返回 nil
[imSDK getFirstUnreadMessageWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(PopIMMessageModel * _Nullable messageModel) {
    
}];
```

#### 4.3.7 获取所有未读@消息
从本地获取被at提醒的未读消息（跨所有会话类型），结果按 sendTime 升序排列（从旧到新）。

**Swift**
```swift
// 获取所有未读@消息
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getUnreadMentionedMessages { messages in
    
}
```

**Objective-C**
```objc
// 获取所有未读@消息
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
[imSDK getUnreadMentionedMessagesWithCompletion:^(NSArray<PopIMMessageModel *> * messages) {
    
}];
```

#### 4.3.8 获取指定会话的未读@消息
获取指定会话中未读的@消息。

**Swift**
```swift
// 获取指定会话的未读@消息
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param count 最大@消息条数，有效值范围 [1, 100]
// @param desc true 拉取最新的 count 条数据, false 拉取最旧的 count 条数据
// @param completion 获取未读@消息的回调，消息列表按照时间顺序从旧到新
imSDK.getUnreadMentionedMessages(conversationType: .groupchat, targetId: "group_123", count: 20, desc: false) { messages in
    
}
```

**Objective-C**
```objc
// 获取指定会话的未读@消息
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param count 最大@消息条数，有效值范围 [1, 100]
// @param desc YES 拉取最新的 count 条数据, NO 拉取最旧的 count 条数据
// @param completion 获取未读@消息的回调，消息列表按照时间顺序从旧到新
[imSDK getUnreadMentionedMessagesWithConversationType:PopIMMessageSessionTypeGroupchat targetId:@"group_123" count:20 desc:NO completion:^(NSArray<PopIMMessageModel *> * messages) {
    
}];
```

#### 4.3.9 获取@我的未读会话列表
获取@我的未读会话列表（mentionedCount > 0 的会话），结果按 updateTime 升序排列。

**Swift**
```swift
// 获取@我的未读会话列表
// @param conversationTypeList 要查询的会话类型数组
// @param topPriority 是否置顶优先，默认值为 true
// @param timestamp 查询的开始时间，传 0 表示查询最新时间的会话，单位：毫秒
// @param count 获取的数量，有效值范围 [1, 100]，默认值为 0（表示最多100条）
// @param completion 异步结果回调，返回对应的会话数组
imSDK.getUnreadMentionMeConversationList(conversationTypeList: [.groupchat], topPriority: true, timestamp: 0, count: 0) { conversations in
    
}
```

**Objective-C**
```objc
// 获取@我的未读会话列表
// @param conversationTypeList 要查询的会话类型数组
// @param topPriority 是否置顶优先
// @param timestamp 查询的开始时间，传 0 表示查询最新时间的会话，单位：毫秒
// @param count 获取的数量，有效值范围 [1, 100]，0 表示最多100条
// @param completion 异步结果回调，返回对应的会话数组
[imSDK getUnreadMentionMeConversationListWithTypes:@[@(PopIMMessageSessionTypeGroupchat)] topPriority:YES timestamp:0 count:0 completion:^(NSArray<PopIMConversationModel *> * conversations) {
    
}];
```

### 4.4 会话操作

#### 4.4.1 删除指定会话
删除指定的会话，删除成功后会触发代理方法 `conversationDidChange`。

**Swift**
```swift
// 删除指定会话
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 会话对方的用户ID
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
imSDK.removeConversation(conversationType: .privatechat, targetId: "10086", channelId: "") { isSuccess in
    
}
```

**Objective-C**
```objc
// 删除指定会话
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 会话对方的用户ID
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
[imSDK removeConversationWithConversationType: PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" completion:^(BOOL isSuccess) {
    
}];
```

#### 4.4.2 按会话类型删除
根据会话类型列表，批量删除符合条件的会话，删除成功后会触发代理方法 `conversationDidChange`。

**Swift**
```swift
// 按会话类型删除
// @param conversationTypeList 会话类型列表
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
imSDK.clearConversations(conversationTypeList: [.privatechat]) { isSuccess in
    
}
```

**Objective-C**
```objc
// 按会话类型删除
// @param conversationTypeList 会话类型列表
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
[imSDK clearConversationsWithConversationTypeList:@[@(PopIMMessageSessionTypePrivatechat)] completion:^(BOOL isSuccess) {
    
}];
```

#### 4.4.3 搜索符合条件的会话
根据关键词、会话类型和消息类型搜索符合条件的会话。

**Swift**
```swift
// 搜索符合条件的会话
// @param conversationTypeList 会话类型集合
// @param messageType 消息类型集合
// @param keyword 搜索关键词
// @param completion 结果回调，返回搜索结果数组（PopIMSearchConversationResult 包含 conversation 和 matchCount）
imSDK.searchConversations(conversationTypeList: [.privatechat], messageType: [.text], keyword: "搜索关键词") { results in
    for result in results {
        let conversation = result.conversation  // 匹配的会话
        let matchCount = result.matchCount      // 该会话中匹配的消息数量
    }
}
```

**Objective-C**
```objc
// 搜索符合条件的会话
// @param conversationTypeList 会话类型集合
// @param messageType 消息类型集合
// @param keyword 搜索关键词
// @param completion 结果回调，返回搜索结果数组（PopIMSearchConversationResult 包含 conversation 和 matchCount）
[imSDK searchConversationsWithConversationTypeList:@[@(PopIMMessageSessionTypePrivatechat)] messageType:@[@(PopIMMessageTypeText)] keyword:@"搜索关键词" completion:^(NSArray<PopIMSearchConversationResult *> * results) {
    for (PopIMSearchConversationResult *result in results) {
        PopIMConversationModel *conversation = result.conversation;  // 匹配的会话
        NSInteger matchCount = result.matchCount;                    // 该会话中匹配的消息数量
    }
}];
```

#### 4.4.4 设置会话置顶
设置会话的置顶状态，置顶成功后会触发代理方法 `conversationDidChange`，会话列表会自动排序。

**Swift**
```swift
// 设置会话置顶
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param isTop 是否置顶
// @param completion 置顶的结果回调 (success, errorMessage, errorCode)，处理完之后会话列表会自动排序并触发delegate - conversationDidChange
imSDK.setConversationToTop(conversationType: .privatechat, targetId: "10086", isTop: true) { (isSuccess, errorMsg, errorCode) in
    if isSuccess {
        // 置顶成功
    } else {
        // 置顶失败，errorMsg: 错误信息，errorCode: 错误码
    }
}
```

**Objective-C**
```objc
// 设置会话置顶
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param isTop 是否置顶
// @param completion 置顶的结果回调 (success, errorMessage, errorCode)，处理完之后会话列表会自动排序并触发delegate - conversationDidChange
[imSDK setConversationToTopWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" isTop:YES completion:^(BOOL isSuccess, NSString *errorMsg, NSInteger errorCode) {
    if (isSuccess) {
        // 置顶成功
    } else {
        // 置顶失败
    }
}];
```

#### 4.4.5 获取会话置顶状态
获取指定会话的置顶状态。

**Swift**
```swift
// 获取会话置顶状态
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 置顶的状态回调，返回是否为置顶状态
imSDK.getConversationTopStatus(conversationType: .privatechat, targetId: "10086") { isTop in
    
}
```

**Objective-C**
```objc
// 获取会话置顶状态
// @param conversationType 会话类型
// @param targetId 会话对方的用户ID
// @param completion 置顶的状态回调，返回是否为置顶状态
[imSDK getConversationTopStatusWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(BOOL isTop) {
    
}];
```

### 4.5 会话草稿

#### 4.5.1 保存会话草稿
保存指定会话的文本消息草稿。

**Swift**
```swift
// 保存会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param content 草稿的内容
// @param completion 保存的结果回调
// completion Bool: true 保存成功，false保存失败
imSDK.saveTextMessageDraft(conversationType: .privatechat, targetId: "10086", content: "草稿内容") { isSuccess in
    
}
```

**Objective-C**
```objc
// 保存会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param content 草稿的内容
// @param completion 保存的结果回调
// completion Bool: true 保存成功，false保存失败
[imSDK saveTextMessageDraftWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" content:@"草稿内容" completion:^(BOOL isSuccess) {
    
}];
```

#### 4.5.2 获取会话草稿
获取指定会话的文本消息草稿。

**Swift**
```swift
// 获取会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param completion 获取结果回调
// completion String?: 草稿的字符串，没设置返回nil
imSDK.getTextMessageDraft(conversationType: .privatechat, targetId: "10086") { draftContent in
    
}
```

**Objective-C**
```objc
// 获取会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param completion 获取结果回调
// completion String?: 草稿的字符串，没设置返回nil
[imSDK getTextMessageDraftWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(NSString * _Nullable draftContent) {
    
}];
```

#### 4.5.3 删除会话草稿
删除指定会话的文本消息草稿。

**Swift**
```swift
// 删除会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param completion 删除的结果回调
// completion Bool: true 删除成功，false 删除失败
imSDK.clearTextMessageDraft(conversationType: .privatechat, targetId: "10086") { isSuccess in
    
}
```

**Objective-C**
```objc
// 删除会话草稿
// @param conversationType 会话类型
// @param targetId 对方userId
// @param completion 删除的结果回调
// completion Bool: true 删除成功，false 删除失败
[imSDK clearTextMessageDraftWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(BOOL isSuccess) {
    
}];
```

### 4.6 会话免打扰

#### 4.6.1 设置会话免打扰
设置会话的免打扰状态，设置后该会话将不会显示消息推送通知。

**Swift**
```swift
// 设置会话免打扰
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 对方userId
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param isBlocked 是否屏蔽消息提醒
// @param successBlock 成功回调
// @param errorBlock 失败回调，(String - 错误的提示文本)
imSDK.setConversationNotificationStatus(conversationType: .privatechat, targetId: "10086", channelId: "", isBlocked: true) { status in
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 设置会话免打扰
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 对方userId
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param isBlocked 是否屏蔽消息提醒
// @param successBlock 成功回调
// @param errorBlock 失败回调，(String - 错误的提示文本)
[imSDK setConversationNotificationStatusWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" isBlocked:YES successBlock:^(NSInteger status) {
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.6.2 获取会话免打扰状态
获取会话的免打扰状态。

**Swift**
```swift
// 获取会话免打扰状态
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 对方userId
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param successBlock 成功回调,  （String = "0"设置了免打扰，反之未设置）
// @param errorBlock 失败回调，(String - 错误的提示文本)
imSDK.getConversationNotificationStatus(conversationType: .privatechat, targetId: "10086", channelId: "") { status in
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 获取会话免打扰状态
// @param conversationType 会话类型（单聊/群聊/系统消息/超级群）
// @param targetId 对方userId
// @param channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// @param successBlock 成功回调,  （String = "0"设置了免打扰，反之未设置）
// @param errorBlock 失败回调，(String - 错误的提示文本)
[imSDK getConversationNotificationStatusWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" successBlock:^(NSString * status) {
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

### 4.7 会话标签

#### 4.7.1 添加会话标签
创建一个新的会话标签。

**Swift**
```swift
// 添加会话标签
// @param tagInfo 标签信息，包含标签名称等信息的PopIMConversationTag对象
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
let tagInfo = PopIMConversationTag()
tagInfo.tagName = "重要"
imSDK.addTag(tagInfo: tagInfo) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 添加会话标签
// @param tagInfo 标签信息，包含标签名称等信息的PopIMConversationTag对象
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
PopIMConversationTag *tagInfo = [[PopIMConversationTag alloc] init];
tagInfo.tagName = @"重要";
[imSDK addTagWithTagInfo:tagInfo successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.2 移除会话标签
删除指定的会话标签。

**Swift**
```swift
// 移除会话标签
// @param tagId 标签ID，要删除的标签唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.removeTag(tagId: "tag_id") {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 移除会话标签
// @param tagId 标签ID，要删除的标签唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK removeTagWithTagId:@"tag_id" successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.3 编辑会话标签
修改指定标签的名称等信息。

**Swift**
```swift
// 编辑会话标签
// @param tagInfo 标签信息，包含标签ID和更新后的标签名称等信息的PopIMConversationTag对象
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
let tagInfo = PopIMConversationTag()
tagInfo.tagId = "tag_id"
tagInfo.tagName = "新标签名"
imSDK.updateTag(tagInfo: tagInfo) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 编辑会话标签
// @param tagInfo 标签信息，包含标签ID和更新后的标签名称等信息的PopIMConversationTag对象
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
PopIMConversationTag *tagInfo = [[PopIMConversationTag alloc] init];
tagInfo.tagId = @"tag_id";
tagInfo.tagName = @"新标签名";
[imSDK updateTagWithTagInfo:tagInfo successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.4 获取标签信息列表
获取所有的标签信息列表。

**Swift**
```swift
// 获取标签信息列表
// @param complate 回调结果，返回标签数组（[PopIMConversationTag]?类型），可能为nil
imSDK.getTags { tags in
    
}
```

**Objective-C**
```objc
// 获取标签信息列表
// @param complate 回调结果，返回标签数组（[PopIMConversationTag]?类型），可能为nil
[imSDK getTagsWithComplate:^(NSArray<PopIMConversationTag *> * _Nullable tags) {
    
}];
```

#### 4.7.5 将一个或多个会话添加到指定标签
将指定的会话添加到某个标签下进行分组管理。

**Swift**
```swift
// 将一个或多个会话添加到指定标签
// @param tagId 标签ID，目标标签的唯一标识
// @param conversationIdentifierList 添加的会话集合，PopIMConversationModel数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.addConversationsToTag(tagId: "tag_id", conversationIdentifierList: [conversationModel]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 将一个或多个会话添加到指定标签
// @param tagId 标签ID，目标标签的唯一标识
// @param conversationIdentifierList 添加的会话集合，PopIMConversationModel数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK addConversationsToTagWithTagId:@"tag_id" conversationIdentifierList:@[conversationModel] successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.6 从指定标签下移除会话
从某个标签下移除指定的会话。

**Swift**
```swift
// 从指定标签下移除会话
// @param tagId 标签ID，目标标签的唯一标识
// @param conversationIdentifierList 要移除的会话集合，PopIMConversationModel数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.removeConversationsFromTag(tagId: "tag_id", conversationIdentifierList: [conversationModel]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 从指定标签下移除会话
// @param tagId 标签ID，目标标签的唯一标识
// @param conversationIdentifierList 要移除的会话集合，PopIMConversationModel数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK removeConversationsFromTagWithTagId:@"tag_id" conversationIdentifierList:@[conversationModel] successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.7 为指定会话中移除标签
从指定会话中移除某些标签。

**Swift**
```swift
// 为指定会话中移除标签
// @param conversationModel 会话模型，目标会话对象
// @param tagIds 要移除的标签ID数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.removeTagsFromConversation(conversationModel, tagIds: ["tag_id1", "tag_id2"]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 为指定会话中移除标签
// @param conversationModel 会话模型，目标会话对象
// @param tagIds 要移除的标签ID数组
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK removeTagsFromConversation:conversationModel tagIds:@[@"tag_id1", @"tag_id2"] successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.8 获取指定会话的所有标签
获取指定会话的所有标签信息。

**Swift**
```swift
// 获取指定会话的所有标签
// @param conversationModel 会话模型，目标会话对象
// @param complate 回调结果，返回标签数组（[PopIMConversationTag]?类型），可能为nil
imSDK.getTagsFromConversation(conversationModel) { tags in
    
}
```

**Objective-C**
```objc
// 获取指定会话的所有标签
// @param conversationModel 会话模型，目标会话对象
// @param complate 回调结果，返回标签数组（[PopIMConversationTag]?类型），可能为nil
[imSDK getTagsFromConversation:conversationModel complate:^(NSArray<PopIMConversationTag *> * _Nullable tags) {
    
}];
```

#### 4.7.9 分页获取标签的会话
根据标签ID分页获取该标签下的会话列表。

**Swift**
```swift
// 分页获取标签的会话
// @param tagId 标签ID，目标标签的唯一标识
// @param timestamp 会话的时间戳，获取此时间戳之前的会话列表
// @param count 获取的数量，当实际取回的会话数量小于count值时，表明已取完数据
// @param complate 异步回调，返回会话列表（[PopIMConversationModel]?类型），可能为nil
imSDK.getConversationsFromTagByPage(tagId: "tag_id", timestamp: 0, count: 20) { conversations in
    
}
```

**Objective-C**
```objc
// 分页获取标签的会话
// @param tagId 标签ID，目标标签的唯一标识
// @param timestamp 会话的时间戳，获取此时间戳之前的会话列表
// @param count 获取的数量，当实际取回的会话数量小于count值时，表明已取完数据
// @param complate 异步回调，返回会话列表（[PopIMConversationModel]?类型），可能为nil
[imSDK getConversationsFromTagByPageWithTagId:@"tag_id" timestamp:0 count:20 complate:^(NSArray<PopIMConversationModel *> * _Nullable conversations) {
    
}];
```

#### 4.7.10 按标签获取未读消息数
获取指定标签下所有会话的总未读消息数。

**Swift**
```swift
// 按标签获取未读消息数
// @param tagId 标签ID，目标标签的唯一标识
// @param complate 异步回调，返回未读数量（Int类型）
imSDK.getUnreadCountByTag(tagId: "tag_id") { unreadCount in
    
}
```

**Objective-C**
```objc
// 按标签获取未读消息数
// @param tagId 标签ID，目标标签的唯一标识
// @param complate 异步回调，返回未读数量（Int类型）
[imSDK getUnreadCountByTagWithTagId:@"tag_id" complate:^(NSInteger unreadCount) {
    
}];
```

#### 4.7.11 清除标签对应会话的未读消息数
清除指定标签下所有会话的未读消息数。

**Swift**
```swift
// 清除标签对应会话的未读消息数
// @param tagId 标签ID，目标标签的唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.clearMessagesUnreadStatusByTag(tagId: "tag_id") {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 清除标签对应会话的未读消息数
// @param tagId 标签ID，目标标签的唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK clearMessagesUnreadStatusByTagWithTagId:@"tag_id" successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.12 清除标签下所有会话
清除指定标签下的所有会话。

**Swift**
```swift
// 清除标签下所有会话
// @param tagId 标签ID，目标标签的唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
imSDK.clearConversationsByTag(tagId: "tag_id") {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 清除标签下所有会话
// @param tagId 标签ID，目标标签的唯一标识
// @param successBlock 成功回调，无返回值
// @param errorBlock 失败回调，返回错误信息（String类型）
[imSDK clearConversationsByTagWithTagId:@"tag_id" successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 4.7.13 会话标签变更监听
通过实现 `PopIMConversationTagProtocol` 协议监听会话标签变更事件。当用户在其它端添加、移除、编辑会话上的标签时，会触发回调。

**Swift**
```swift
// 添加会话标签变更监听
imSDK.addConversationTagDelegate(self)
// 移除会话标签变更监听
imSDK.removeConversationTagDelegate(self)

// 遵守会话标签代理协议
extension ViewController: PopIMConversationTagProtocol {
    // 会话标签变更回调
    // @param conversationType 会话类型
    // @param targetId 会话目标ID
    // @param busChannel 业务频道（超级群使用，其他类型可为空）
    // @discussion 收到通知后，建议调用 getTagsFromConversation 方法从服务端获取指定会话的最新标签数据
    func onConversationTagChanged(conversationType: PopIMMessageSessionType, targetId: String, busChannel: String) {
        // 标签发生变更，重新获取最新标签数据
    }
}
```

**Objective-C**
```objc
// 添加会话标签变更监听
[imSDK addConversationTagDelegate:self];
// 移除会话标签变更监听
[imSDK removeConversationTagDelegate:self];

// 遵循代理
@interface ViewController () <PopIMConversationTagProtocol>
@end

@implementation ViewController

// 会话标签变更回调
- (void)onConversationTagChangedWithConversationType:(PopIMMessageSessionType)conversationType targetId:(NSString *)targetId busChannel:(NSString *)busChannel {
    // 标签发生变更，重新获取最新标签数据
}

@end
```

## 四-1、超级群管理


### 4-1.1 超级群概述

超级群（UltraGroup）是一种支持频道（Channel）功能的大型群组，适用于需要多频道管理的场景。每个超级群可以包含多个频道，不同频道之间的消息相互独立。

**核心概念：**
- **超级群**：会话类型为 `PopIMMessageSessionType.ultraGroup`（值为 6）
- **频道ID（channelId）**：用于标识超级群中的不同频道
- **默认频道**：当 `channelId` 为空字符串时，SDK 会自动使用默认频道 `"YCDefault"`

### 4-1.2 频道ID说明

在使用超级群相关 API 时，`channelId` 参数的处理规则如下：

- **传空字符串**：当 `channelId` 参数传入空字符串 `""` 时，SDK 会自动使用默认频道 `"YCDefault"`
- **传入具体值**：当 `channelId` 参数传入具体频道ID时，使用指定的频道

**注意**：此规则仅适用于超级群（`conversationType == .ultraGroup`），对于其他会话类型（单聊、群聊、系统消息），`channelId` 参数会被忽略。

### 4-1.3 获取超级群会话

根据会话类型、目标ID和频道ID获取指定超级群会话信息。

**Swift**
```swift
// 获取超级群会话
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param completion 获取结果回调，返回会话对象（PopIMConversationModel类型），可能为nil
imSDK.getConversation(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "") { conversationModel in
    // 使用默认频道
}

// 获取指定频道的会话
imSDK.getConversation(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "channel_001") { conversationModel in
    // 使用指定频道
}
```

**Objective-C**
```objc
// 获取超级群会话（使用默认频道）
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param completion 获取结果回调，返回会话对象（PopIMConversationModel类型），可能为nil
[imSDK getConversationWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" completion:^(PopIMConversationModel * conversationModel) {
    // 使用默认频道
}];

// 获取指定频道的会话
[imSDK getConversationWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"channel_001" completion:^(PopIMConversationModel * conversationModel) {
    // 使用指定频道
}];
```

### 4-1.4 获取超级群历史消息

获取指定超级群频道的历史消息列表。

**Swift**
```swift
// 获取超级群历史消息
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param oldestMessageId 用于控制分页的边界，以此 messageId 为界，获取发送时间更小的 count 条消息。不设置或者设置成空，表示获取最新的 count 条消息。
// @param count 需要获取的消息数量，按照消息发送时间从新到旧排列
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getHistoryMessages(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", oldestMessageId: nil, count: 50) { resultMessages in
    // 处理消息列表
}
```

**Objective-C**
```objc
// 获取超级群历史消息
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param oldestMessageId 用于控制分页的边界，可选
// @param count 需要获取的消息数量
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
[imSDK getHistoryMessagesWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    // 处理消息列表
}];
```

### 4-1.5 删除超级群会话

删除指定的超级群会话，删除成功后会触发代理方法 `conversationDidChange`。

**Swift**
```swift
// 删除超级群会话
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
imSDK.removeConversation(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "") { isSuccess in
    
}
```

**Objective-C**
```objc
// 删除超级群会话
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param completion 删除的结果回调，处理完之后会话列表会自动删除列表数据并触发delegate - conversationDidChange
[imSDK removeConversationWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" completion:^(BOOL isSuccess) {
    
}];
```

### 4-1.6 设置超级群免打扰

设置超级群频道的免打扰状态，设置后该频道将不会显示消息推送通知。

**Swift**
```swift
// 设置超级群免打扰
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param isBlocked 是否屏蔽消息提醒
// @param successBlock 成功回调
// @param errorBlock 失败回调，(String - 错误的提示文本)
imSDK.setConversationNotificationStatus(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", isBlocked: true) { status in
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 设置超级群免打扰
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param isBlocked 是否屏蔽消息提醒
// @param successBlock 成功回调
// @param errorBlock 失败回调，(String - 错误的提示文本)
[imSDK setConversationNotificationStatusWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" isBlocked:YES successBlock:^(NSInteger status) {
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

### 4-1.7 获取超级群免打扰状态

获取超级群频道的免打扰状态。

**Swift**
```swift
// 获取超级群免打扰状态
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param successBlock 成功回调,  （String = "0"设置了免打扰，反之未设置）
// @param errorBlock 失败回调，(String - 错误的提示文本)
imSDK.getConversationNotificationStatus(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "") { status in
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 获取超级群免打扰状态
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param successBlock 成功回调,  （String = "0"设置了免打扰，反之未设置）
// @param errorBlock 失败回调，(String - 错误的提示文本)
[imSDK getConversationNotificationStatusWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" successBlock:^(NSString * status) {
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

### 4-1.8 删除超级群消息

彻底删除超级群频道中的消息（本地和远程）。

**Swift**
```swift
// 彻底删除超级群消息
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param messages 消息ID列表
// @param completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.deleteRemoteMessage(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", messages: ["message_id_1", "message_id_2"]) { isSuccess in
    
}
```

**Objective-C**
```objc
// 彻底删除超级群消息
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param messages 消息ID列表
// @param completion 删除的的回调
// completion Bool 操作是不是成功
[imSDK deleteRemoteMessageWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" messages:@[@"message_id_1", @"message_id_2"] completion:^(BOOL isSuccess) {
    
}];
```

### 4-1.9 清除超级群历史消息

彻底清除超级群频道的历史消息。

**Swift**
```swift
// 彻底清除超级群历史消息
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param recordTime 时间戳。默认删除小于等于recordTime的消息。如果传0，则删除所有消息
// @param completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.clearRemoteHistoryMessages(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", recordTime: 0) { isSuccess in
    
}
```

**Objective-C**
```objc
// 彻底清除超级群历史消息
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param recordTime 时间戳。默认删除小于等于recordTime的消息。如果传0，则删除所有消息
// @param completion 删除的的回调
// completion Bool 操作是不是成功
[imSDK clearRemoteHistoryMessagesWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" recordTime:0 completion:^(BOOL isSuccess) {
    
}];
```

### 4-1.10 设置超级群消息扩展

设置超级群频道中消息的扩展信息。

**Swift**
```swift
// 设置超级群消息扩展
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param msgId 消息id
// @param extraKeyVal 消息拓展的内容
// @param successBlock 成功回调
// @param errorBlock 失败的回调
imSDK.setMessageExtra(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", msgId: "msg_123", extraKeyVal: ["key": "value"]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 设置超级群消息扩展
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param msgId 消息id
// @param extraKeyVal 消息拓展的内容
// @param successBlock 成功回调
// @param errorBlock 失败的回调
[imSDK setMessageExtraWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" msgId:@"msg_123" extraKeyVal:@{@"key": @"value"} successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

### 4-1.11 删除超级群消息扩展

删除超级群频道中消息的扩展信息。

**Swift**
```swift
// 删除超级群消息扩展
// @param conversationType 会话类型，传入 .ultraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param msgId 消息id
// @param keyArray 删除的key集合
// @param successBlock 成功回调
// @param errorBlock 失败的回调
imSDK.removeMessageExpansionForkeyArray(conversationType: .ultraGroup, targetId: "ultragroup_123", channelId: "", msgId: "msg_123", keyArray: ["key1", "key2"]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**
```objc
// 删除超级群消息扩展
// @param conversationType 会话类型，传入 PopIMMessageSessionTypeUltraGroup
// @param targetId 超级群ID
// @param channelId 频道ID，传空字符串将使用默认频道（YCDefault）
// @param msgId 消息id
// @param keyArray 删除的key集合
// @param successBlock 成功回调
// @param errorBlock 失败的回调
[imSDK removeMessageExpansionForkeyArrayWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" msgId:@"msg_123" keyArray:@[@"key1", @"key2"] successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

## 五、消息相关


### 5.0 自定义消息管理 API

#### 5.0.1 注册自定义消息类

注册自定义消息类，用于发送和解析自定义消息。

**Swift**

```swift
// 注册自定义消息类
// @param messageClass 自定义消息类（必须遵循 PopIMMessageContentProtocol 协议）
PopIMLibSDK.shared.registerCustomMessage(messageClass: MyCustomMessage.self)
```

**Objective-C**

```objc
// 注册自定义消息类
// @param messageClass 自定义消息类（必须遵循 PopIMMessageContentProtocol 协议）
[[PopIMLibSDK shared] registerCustomMessageWithMessageClass:[MyCustomMessage class]];
```

#### 5.0.2 获取自定义消息类

根据 `msgType` 获取已注册的自定义消息类。

**Swift**

```swift
// 获取自定义消息类
// @param msgType 消息类型标识
// @return 自定义消息类，如果未注册返回 nil
if let customClass = PopIMLibSDK.shared.getCustomMessageTemplate(msgType: "MyApp:CustomMsg") {
    // 使用自定义消息类
}
```

**Objective-C**

```objc
// 获取自定义消息类
// @param msgType 消息类型标识
// @return 自定义消息类，如果未注册返回 nil
Class customClass = [[PopIMLibSDK shared] getCustomMessageTemplateWithMsgType:@"MyApp:CustomMsg"];
if (customClass) {
    // 使用自定义消息类
}
```

### 5.1 添加消息代理

**Swift**
```swift
// 添加消息代理
imSDK.addMessageDelegate(self)
// 移除消息代理
imSDK.removeMessageDelegate(self)

// 遵守消息代理协议
extension ViewController: PopIMMessageProtocol {
    /**
     * 接收到新消息
     * @param messages 新消息列表
     * @param offline 是不是离线消息
     */
    func onReceived(_ messages: [PopIMMessageModel], offline: Bool) {
        
    }
    
    /**
     * 消息撤回的回调
     * @param messages 撤回的消息
     */
    func messageDidRecall(messages: [PopIMMessageModel]) {
        
    }
    
    /**
     * 消息删除
     * @param messages 删除消息集合
     */
    func didDeleteMessages(_ messages: [PopIMMessageModel]) {
        
    }
    
    /**
     * 离线消息接收完成
     */
    func onOfflineMessageSyncCompleted() {
        
    }
    
    /**
     * 超级群新消息接收（同步过程中）
     * @param messages 新消息列表
     * @param targetId 超级群ID
     * @param channelId 频道ID
     */
    func onUltraGroupReceived(_ messages: [PopIMMessageModel], targetId: String, channelId: String) {
        
    }
    
    /**
     * 超级群消息同步完成
     * @param targetId 超级群ID
     * @param channelId 频道ID
     */
    func onUltraGroupSyncCompleted(targetId: String, channelId: String) {
        
    }
}
```

**Objective-C**
```objc
// 添加消息代理
[imSDK addMessageDelegate:self];
// 移除消息代理
[imSDK removeMessageDelegate:self];

// 遵循代理
@interface ViewController () <PopIMMessageProtocol>
@end

@implementation ViewController

/// 接收到新消息
/// @param messages 新消息列表
/// @param offline 是不是离线消息
- (void)onReceived:(NSArray<PopIMMessageModel *> * _Nonnull)messages offline:(BOOL)offline {
    
}

/// 消息撤回的回调
/// @param messages 撤回的消息
- (void)messageDidRecallWithMessages:(NSArray<PopIMMessageModel *> * _Nonnull)messages {
    
}

/// 消息删除
/// @param messages 删除消息集合
- (void)didDeleteMessages:(NSArray<PopIMMessageModel *> * _Nonnull)messages {
    
}

/// 离线消息接收完成
- (void)onOfflineMessageSyncCompleted {
    
}

/// 超级群新消息接收（同步过程中）
/// @param messages 新消息列表
/// @param targetId 超级群ID
/// @param channelId 频道ID
- (void)onUltraGroupReceived:(NSArray<PopIMMessageModel *> * _Nonnull)messages targetId:(NSString *)targetId channelId:(NSString *)channelId {
    
}

/// 超级群消息同步完成
/// @param targetId 超级群ID
/// @param channelId 频道ID
- (void)onUltraGroupSyncCompletedWithTargetId:(NSString *)targetId channelId:(NSString *)channelId {
    
}

@end
```

### 5.2 发送消息

#### 5.2.1 PopIMMessageSend - 消息发送基类
消息发送基类，主要管理消息接收人信息、消息扩展、消息推送等。所有消息发送都需要使用这个基类，并设置对应的消息内容：

**Swift**
```swift
let messageSend = PopIMMessageSend()
// 必填-对方ID，目标用户或群组ID
messageSend.targetId = "10086"
// 必填-会话类型，默认私聊（.privatechat）
// 可选值：.privatechat(单聊) / .groupchat(群聊) / .system(系统消息) / .ultraGroup(超级群)
messageSend.conversationType = PopIMMessageSessionType.privatechat
// 非必填-频道ID，如果是超级群channelId不传或者传"", 将使用默认频道发送
messageSend.channelId = ""
// 必填-消息内容，需要设置具体的消息内容类型
// messageSend.content = textContent    // 文本消息内容
// messageSend.content = imageContent   // 图片消息内容
// messageSend.content = voiceContent   // 语音消息内容
// messageSend.content = videoContent   // 视频消息内容
// 可选-消息扩展标识，0-非扩展，1-扩展。如果extra不为空，expansion必须为1
messageSend.expansion = 1
// 可选-消息扩展信息，设置的内容会原封不动保存在消息体中
messageSend.extra = "自定义扩展信息"
// 可选-是否启用推送，默认false不推送
messageSend.enablePush = true
// 可选-推送标题，不填或填空则不推送
messageSend.pushTitle = "推送标题"
// 可选-推送内容，不填或填空则不推送
messageSend.pushContent = "推送内容"
// 可选-推送自定义数据，点击推送时原封不动通过didClickPushConversation回调返回
messageSend.pushData = "自定义推送数据"
```

**Objective-C**
```objc
PopIMMessageSend *messageSend = [PopIMMessageSend new];
// 必填-对方ID，目标用户或群组ID
messageSend.targetId = @"10086";
// 必填-会话类型，默认私聊（PopIMMessageSessionTypePrivatechat）
// 可选值：PopIMMessageSessionTypePrivatechat(单聊) / PopIMMessageSessionTypeGroupchat(群聊) / PopIMMessageSessionTypeSystem(系统消息) / PopIMMessageSessionTypeUltraGroup(超级群)
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;
// 非必填-频道ID，如果是超级群channelId不传或者传"", 将使用默认频道发送
messageSend.channelId = @"";
// 必填-消息内容，需要设置具体的消息内容类型
// messageSend.content = textContent;    // 文本消息内容
// messageSend.content = imageContent;   // 图片消息内容
// messageSend.content = voiceContent;   // 语音消息内容
// messageSend.content = videoContent;   // 视频消息内容
// 可选-消息扩展标识，0-非扩展，1-扩展。如果extra不为空，expansion必须为1
messageSend.expansion = 1;
// 可选-消息扩展信息，设置的内容会原封不动保存在消息体中
messageSend.extra = @"自定义扩展信息";
// 可选-是否启用推送，默认false不推送
messageSend.enablePush = YES;
// 可选-推送标题，不填或填空则不推送
messageSend.pushTitle = @"推送标题";
// 可选-推送内容，不填或填空则不推送
messageSend.pushContent = @"推送内容";
// 可选-推送自定义数据，点击推送时原封不动通过didClickPushConversation回调返回
messageSend.pushData = @"自定义推送数据";
```

#### 5.2.2 文本消息发送构建

**Swift**

```swift
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

let textContent = PopIMTextMessageContent()
textContent.content = "消息内容"
// 可选-@用户列表
textContent.atUserList = ["user1", "user2"]

messageSend.content = textContent
```

**Objective-C**

```objc
PopIMMessageSend *messageSend = [PopIMMessageSend new];
messageSend.targetId = @"10086";
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;

PopIMTextMessageContent *textContent = [PopIMTextMessageContent new];
textContent.content = @"消息内容";
// 可选-@用户列表
textContent.atUserList = @[@"user1", @"user2"];

messageSend.content = textContent;
```

#### 5.2.3 图片消息发送构建

**Swift**

```swift
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

let imageContent = PopIMImageMessageContent()
// 必填-缩略图URL地址,业务自己管理
imageContent.thumImageUrl = "https://example.com/thumb.jpg"
// 必填-原图图片URL地址,业务自己管理
imageContent.imageUrl = "https://example.com/image.jpg"
// 必填-缩略图的宽度
imageContent.thumWidth = 120
// 必填-缩略图的高度
imageContent.thumHeight = 160

messageSend.content = imageContent
```

**Objective-C**

```objc
PopIMMessageSend *messageSend = [PopIMMessageSend new];
messageSend.targetId = @"10086";
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;

PopIMImageMessageContent *imageContent = [PopIMImageMessageContent new];
// 必填-缩略图URL地址,业务自己管理
imageContent.thumImageUrl = @"https://example.com/thumb.jpg";
// 必填-原图图片URL地址,业务自己管理
imageContent.imageUrl = @"https://example.com/image.jpg";
// 必填-缩略图的宽度
imageContent.thumWidth = 120;
// 必填-缩略图的高度
imageContent.thumHeight = 160;

messageSend.content = imageContent;
```

#### 5.2.4 视频消息发送构建

**Swift**

```swift
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

let videoContent = PopIMVideoMessageContent()
// 必填-封面图链接
videoContent.thumImageUrl = "https://example.com/cover.jpg"
// 必填-缩略图的宽度
videoContent.thumWidth = 120
// 必填-缩略图的高度
videoContent.thumHeight = 160
// 视频文件链接
videoContent.videoUrl = "https://example.com/video.mp4"
// 视频时长
videoContent.duration = 15
// 视频大小,单位b
videoContent.size = 1200

messageSend.content = videoContent
```

**Objective-C**

```objc
PopIMMessageSend *messageSend = [PopIMMessageSend new];
messageSend.targetId = @"10086";
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;

PopIMVideoMessageContent *videoContent = [PopIMVideoMessageContent new];
// 必填-封面图链接
videoContent.thumImageUrl = @"https://example.com/cover.jpg";
// 必填-缩略图的宽度
videoContent.thumWidth = 120;
// 必填-缩略图的高度
videoContent.thumHeight = 160;
// 视频文件链接
videoContent.videoUrl = @"https://example.com/video.mp4";
// 视频时长
videoContent.duration = 15;
// 视频大小,单位b
videoContent.size = 1200;

messageSend.content = videoContent;
```

#### 5.2.5 语音消息发送构建

**Swift**

```swift
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

let voiceContent = PopIMVoiceMessageContent()
// 必填-语音URL地址,业务自己管理
voiceContent.remoteUrl = "https://example.com/voice.mp3"
// 必填-语音时长
voiceContent.duration = 10

messageSend.content = voiceContent
```

**Objective-C**

```objc
PopIMMessageSend *messageSend = [PopIMMessageSend new];
messageSend.targetId = @"10086";
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;

PopIMVoiceMessageContent *voiceContent = [PopIMVoiceMessageContent new];
// 必填-语音URL地址,业务自己管理
voiceContent.remoteUrl = @"https://example.com/voice.mp3";
// 必填-语音时长
voiceContent.duration = 10;

messageSend.content = voiceContent;
```

#### 5.2.6 自定义消息发送构建

自定义消息允许开发者定义自己的消息类型，实现业务特定的消息格式。自定义消息需要：

1. **创建自定义消息类**：继承 `PopIMCustomMessageContent` 并实现 `PopIMCustomMessageProtocol` 协议
2. **注册自定义消息类**：在发送前注册自定义消息类型
3. **构建并发送消息**：使用自定义消息类构建消息并发送

**步骤 1：创建自定义消息类**

**Swift**

```swift
import UIKit

// 自定义消息类，继承自 PopIMCustomMessageContent
class MyCustomMessage: PopIMCustomMessageContent {
    // 消息类型标识（msgType），必须唯一
    static let msgType = "MyApp:CustomMsg"
    
    // 必需的初始化器
    required init(originString: String) {
        super.init(originString: originString)
    }
    
    required init() {
        super.init()
    }
    
    // 返回消息类型标识
    override func msgType() -> String {
        return MyCustomMessage.msgType
    }
    
    // 是否保存到数据库（默认 true）
    override func shouldSaveToDatabase() -> Bool {
        return true
    }
    
    // 是否计入未读数（默认 true）
    override func shouldCountUnread() -> Bool {
        return true
    }
    
    // 解析自定义数据（从 JSON 中提取业务属性）
    func parseCustomData() -> [String: Any]? {
        guard !originString.isEmpty else { return nil }
        // 使用工具类将 JSON 字符串转换为字典
        return PopIMDemoFuncTool.mapDictionary(jsonString: originString)
    }
    
    // 设置自定义数据（将业务属性序列化为 JSON）
    func setCustomData(_ customData: [String: Any]) {
        if let jsonString = PopIMDemoFuncTool.mapJSONString(dic: customData) {
            self.originString = jsonString
        }
    }
}
```

**Objective-C**

```objc
#import <Foundation/Foundation.h>
#import "YCIMProject-Swift.h"

// 前向声明 Swift 中定义的协议和类
@protocol PopIMMessageContentProtocol;
@class PopMentionedInfo;

NS_ASSUME_NONNULL_BEGIN

/// Objective-C 自定义消息类示例
/// 遵循 PopIMMessageContentProtocol 协议，实现协议要求的方法和属性
@interface PopIMOCCustomMessage : NSObject <PopIMMessageContentProtocol>

/// 字符串属性示例
@property (nonatomic, copy) NSString *stringLa;

/// 整数属性示例
@property (nonatomic, assign) int intLa;

/// 字典属性示例
@property (nonatomic, copy) NSDictionary *dicLa;

/// 选填-at的用户集合
@property (nonatomic, strong, nullable) PopMentionedInfo *mentionedInfo;

/// 嵌套对象示例（支持 NSObject 类型的递归序列化）
@property (nonatomic, strong, nullable) PopIMOCSDKTest1 *text1;

@end

NS_ASSUME_NONNULL_END
```

```objc
#import "PopIMOCCustomMessage.h"
#import "YCIMProject-Swift.h"

@implementation PopIMOCCustomMessage

// MARK: - PopIMMessageContentProtocol 实现

/// 指定该消息的消息类型
+ (NSString *)msgType {
    return @"OC:TestCustomMsg";
}

/// 指定该消息是否入库
+ (BOOL)shouldSaveToDatabase {
    return NO;  // 示例：不入库
}

/// 指定该消息是否计数
+ (BOOL)shouldCountUnread {
    return NO;  // 示例：不计入未读数
}

// MARK: - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        _mentionedInfo = nil;
    }
    return self;
}

@end
```

**注意：** Objective-C 自定义消息类需要：
- 继承自 `NSObject` 并遵循 `PopIMMessageContentProtocol` 协议
- 实现类方法 `+msgType`、`+shouldSaveToDatabase`、`+shouldCountUnread`
- 属性支持基本类型（String、Int、Bool、Double、Float、Array、Dictionary）和 NSObject 类型（支持递归序列化）
- 在头文件中使用前向声明，避免导入 Swift 头文件

**步骤 2：注册自定义消息类**

在应用启动时（如 `AppDelegate` 或会话列表加载时）注册自定义消息类：

**Swift**

```swift
// 注册自定义消息类
// @param messageClass 自定义消息类的类型
PopIMLibSDK.shared.registerCustomMessage(messageClass: MyCustomMessage.self)
```

**Objective-C**

```objc
// 注册自定义消息类（传递类类型）
// @param messageClass 自定义消息类的类型（必须遵循 PopIMMessageContentProtocol 协议）
PopIMLibSDK *sdk = [PopIMLibSDK shared];
[sdk registerCustomMessageWithMessageClass:[PopIMOCCustomMessage class]];
```

**步骤 3：构建并发送自定义消息**

**Swift**

```swift
// 1. 创建消息发送对象
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

// 2. 创建自定义消息内容
let customMessage = MyCustomMessage()
// 设置自定义数据（JSON 格式）
let customData: [String: Any] = [
    "data": "这是自定义消息内容",
    "timestamp": Int(Date().timeIntervalSince1970 * 1000),
    "type": "custom",
    "extra": [
        "key1": "value1",
        "key2": "value2"
    ]
]
customMessage.setCustomData(customData)

// 3. 设置消息内容
messageSend.content = customMessage

// 4. 发送消息
PopIMLibSDK.shared.sendMessage(message: messageSend) { messageModel in
    print("自定义消息发送成功: \(messageModel.messageId)")
} errorBlock: { (errorMsg, messageModel) in
    print("自定义消息发送失败: \(errorMsg)")
}
```

**Objective-C**

```objc
// 1. 创建消息发送对象
PopIMMessageSend *customMessageSend = [[PopIMMessageSend alloc] init];
customMessageSend.targetId = @"test_target_id";
customMessageSend.conversationType = PopIMMessageSessionTypePrivatechat;
customMessageSend.channelId = @"";

// 2. 创建自定义消息内容并设置属性
// SDK 会自动将属性序列化为 JSON（支持基本类型和 NSObject 类型的递归序列化）
PopIMOCCustomMessage *sendCustomContent = [[PopIMOCCustomMessage alloc] init];
sendCustomContent.stringLa = @"1";
sendCustomContent.intLa = 2;
sendCustomContent.dicLa = @{@"1": @"2"};

// 3. 设置嵌套对象（支持 NSObject 类型的递归序列化）
PopIMOCSDKTest1 *text1 = [[PopIMOCSDKTest1 alloc] init];
PopIMOCSDKTest2 *text2 = [[PopIMOCSDKTest2 alloc] init];
text2.test2Str = @"test2Str";
text1.test2 = text2;
sendCustomContent.text1 = text1;

// 4. 设置消息内容
customMessageSend.content = sendCustomContent;

// 5. 发送消息
PopIMLibSDK *sdk = [PopIMLibSDK shared];
[sdk sendMessageWithMessage:customMessageSend
                successBlock:^(PopIMMessageModel * _Nonnull message) {
    NSLog(@"自定义消息发送成功: %@", message.msgId);
} errorBlock:^(NSString * _Nonnull errorMsg, PopIMMessageModel * _Nullable message) {
    NSLog(@"自定义消息发送失败: %@", errorMsg);
}];
```

**完整测试示例（testCustomMessage）：**

```objc
+ (void)testCustomMessage {
    NSLog(@"=== 测试自定义消息相关方法（重点） ===");
    
    PopIMLibSDK *sdk = [PopIMLibSDK shared];
    
    // 1. 注册自定义消息类（新方式：传递类类型）
    [sdk registerCustomMessageWithMessageClass:[PopIMOCCustomMessage class]];
    
    // 2. 创建并发送自定义消息
    PopIMMessageSend *customMessageSend = [[PopIMMessageSend alloc] init];
    customMessageSend.targetId = @"test_target_id";
    customMessageSend.conversationType = PopIMMessageSessionTypePrivatechat;
    customMessageSend.channelId = @"";
    
    // 创建自定义消息内容并设置数据
    PopIMOCCustomMessage *sendCustomContent = [[PopIMOCCustomMessage alloc] init];
    sendCustomContent.stringLa = @"1";
    sendCustomContent.intLa = 2;
    sendCustomContent.dicLa = @{@"1": @"2"};
    
    // 设置嵌套对象（支持递归序列化）
    PopIMOCSDKTest1 *text1 = [[PopIMOCSDKTest1 alloc] init];
    PopIMOCSDKTest2 *text2 = [[PopIMOCSDKTest2 alloc] init];
    text2.test2Str = @"test2Str";
    text1.test2 = text2;
    sendCustomContent.text1 = text1;
    
    customMessageSend.content = sendCustomContent;
    
    // 发送消息
    [sdk sendMessageWithMessage:customMessageSend
                    successBlock:^(PopIMMessageModel * _Nonnull message) {
        NSLog(@"✓ 自定义消息发送成功: %@", message.msgId);
    } errorBlock:^(NSString * _Nonnull errorMsg, PopIMMessageModel * _Nullable message) {
        NSLog(@"✗ 自定义消息发送失败: %@", errorMsg);
    }];
    
    // 3. 获取已注册的自定义消息类
    Class retrievedClass = [sdk getCustomMessageTemplateWithMsgType:@"OC:TestCustomMsg"];
    if (retrievedClass) {
        NSLog(@"✓ 成功获取自定义消息类: %@", NSStringFromClass(retrievedClass));
    } else {
        NSLog(@"✗ 未找到注册的自定义消息类");
    }
}
```

**属性序列化说明：**

- SDK 会自动将自定义消息类的属性序列化为 JSON 字符串
- 支持基本类型：`String`、`Int`、`Bool`、`Double`、`Float`、`Array`、`Dictionary`
- 支持 NSObject 类型：会自动递归序列化嵌套对象的属性
- 不需要手动设置 `originString`，SDK 会在发送时自动生成

**注意事项：**

- `msgType` 必须唯一，建议使用格式：`"AppName:MessageType"`（如 `"MyApp:CustomMsg"`）
- 自定义消息的 `originString` 必须是有效的 JSON 字符串
- `msgCategory` 字段由后端控制，发送时不需要设置（后端会自动设置为 `5`）
- 自定义消息类必须在发送前注册，否则接收端无法正确解析

#### 5.2.7 实际发送消息

**Swift**

```swift
// @param message 需要设置的是PopIMMessageSend对象，并已设置好对应的消息内容
// @param successBlock 消息发送成功后的回调
// @result successBlock messageModel 消息数据model
// @param errorBlock 消息发送失败的回调
// @result msg 消息发送失败具体的错误信息
// @result messageModel 消息发送失败返回的消息数据model，可能为空
imSDK.sendMessage(message: messageSend) { messageModel in
    print("消息发送成功: \(messageModel.messageId)")
} errorBlock: { (msg, messageModel) in
    print("消息发送失败: \(msg)")
}
```

**Objective-C**

```objc
// @param message 需要设置的是PopIMMessageSend对象，并已设置好对应的消息内容
// @param successBlock 消息发送成功后的回调
// @result successBlock messageModel 消息数据model
// @param errorBlock 消息发送失败的回调
// @result msg 消息发送失败具体的错误信息
// @result messageModel 消息发送失败返回的消息数据model，可能为空
[imSDK sendMessageWithMessage:messageSend successBlock:^(PopIMMessageModel * messageModel) {
    NSLog(@"消息发送成功: %@", messageModel.messageId);
} errorBlock:^(NSString * msg, PopIMMessageModel * messageModel) {
    NSLog(@"消息发送失败: %@", msg);
}];
```

#### 5.2.8 完整消息发送示例

以下是一个完整的文本消息发送示例，展示了从创建消息到发送的完整流程：

**Swift**

```swift
// 1. 创建消息发送对象
let messageSend = PopIMMessageSend()
messageSend.targetId = "10086"
messageSend.conversationType = .privatechat

// 2. 创建文本消息内容
let textContent = PopIMTextMessageContent()
textContent.content = "Hello, World!"
textContent.atUserList = ["user1", "user2"] // 可选：@用户列表

// 3. 设置消息内容
messageSend.content = textContent

// 4. 发送消息
PopIMLibSDK.shared.sendMessage(message: messageSend) { messageModel in
    print("消息发送成功，消息ID: \(messageModel.messageId)")
} errorBlock: { (errorMsg, messageModel) in
    print("消息发送失败: \(errorMsg)")
}
```

**Objective-C**

```objc
// 1. 创建消息发送对象
PopIMMessageSend *messageSend = [PopIMMessageSend new];
messageSend.targetId = @"10086";
messageSend.conversationType = PopIMMessageSessionTypePrivatechat;

// 2. 创建文本消息内容
PopIMTextMessageContent *textContent = [PopIMTextMessageContent new];
textContent.content = @"Hello, World!";
textContent.atUserList = @[@"user1", @"user2"]; // 可选：@用户列表

// 3. 设置消息内容
messageSend.content = textContent;

// 4. 发送消息
[[PopIMLibSDK shared] sendMessageWithMessage:messageSend successBlock:^(PopIMMessageModel * messageModel) {
    NSLog(@"消息发送成功，消息ID: %@", messageModel.messageId);
} errorBlock:^(NSString * errorMsg, PopIMMessageModel * messageModel) {
    NSLog(@"消息发送失败: %@", errorMsg);
}];
```

### 5.3 自定义消息解析

当接收到自定义消息时，SDK 会根据消息的 `msgTypeValue` 查找已注册的自定义消息类，并自动解析消息内容。

#### 5.3.1 自定义消息接收流程

1. **消息接收**：SDK 通过 `PopIMMessageProtocol` 的 `onReceived` 方法接收消息
2. **自动解析**：SDK 根据消息的 `msgTypeValue` 和 `msgCategory == 5` 判断是否为自定义消息
3. **实例化**：如果已注册对应的自定义消息类，SDK 会使用 `init(originString:)` 创建实例
4. **保存与计数**：根据自定义消息类的 `shouldSaveToDatabase()` 和 `shouldCountUnread()` 决定是否保存和计数

#### 5.3.2 接收自定义消息示例

**Swift**

```swift
extension ViewController: PopIMMessageProtocol {
    func onReceived(_ messages: [PopIMMessageModel], offline: Bool) {
        for message in messages {
            // 判断是否为自定义消息
            if message.msgCategory == 5 || (message.msgType == .unknown && !message.msgTypeValue.isEmpty) {
                // 检查消息内容是否为自定义消息类型
                if let customContent = message.content as? MyCustomMessage {
                    // 解析自定义数据
                    if let customData = customContent.parseCustomData() {
                        let data = customData["data"] as? String ?? ""
                        print("收到自定义消息: \(data)")
                    }
                } else {
                    // 如果未注册，message.content 会是 PopIMCustomMessageContent 基类实例
                    // 可以直接访问 originString
                    print("收到未注册的自定义消息: \(message.content.originString)")
                }
            }
        }
    }
}
```

**Objective-C**

```objc
- (void)onReceived:(NSArray<PopIMMessageModel *> *)messages offline:(BOOL)offline {
    for (PopIMMessageModel *message in messages) {
        // 判断是否为自定义消息
        if (message.msgCategory == 5 || (message.msgType == PopIMMessageTypeUnknown && message.msgTypeValue.length > 0)) {
            // 检查消息内容是否为已注册的自定义消息类型
            if ([message.content isKindOfClass:[PopIMOCCustomMessage class]]) {
                PopIMOCCustomMessage *customContent = (PopIMOCCustomMessage *)message.content;
                // 直接访问属性（SDK 已自动解析）
                NSLog(@"收到自定义消息:");
                NSLog(@"  - stringLa: %@", customContent.stringLa);
                NSLog(@"  - intLa: %d", customContent.intLa);
                NSLog(@"  - dicLa: %@", customContent.dicLa);
                
                // 访问嵌套对象
                if (customContent.text1 && customContent.text1.test2) {
                    NSLog(@"  - text1.test2.test2Str: %@", customContent.text1.test2.test2Str);
                }
            } else if ([message.content isKindOfClass:[PopIMCustomMessageContent class]]) {
                // 如果未注册，使用基类访问 originString
                PopIMCustomMessageContent *customContent = (PopIMCustomMessageContent *)message.content;
                NSLog(@"收到未注册的自定义消息: %@", customContent.originString);
            }
        }
    }
}
```

**属性解析说明：**

- SDK 会自动将接收到的 JSON 字符串解析为自定义消息类的属性
- 支持基本类型和 NSObject 类型的递归解析
- 如果自定义消息类已注册，`message.content` 会是具体的自定义消息类实例
- 如果未注册，`message.content` 会是 `PopIMCustomMessageContent` 基类实例，可以访问 `originString` 获取原始 JSON

#### 5.3.3 自定义消息显示

在会话列表和聊天详情页中，自定义消息会自动解析并显示：

- **会话列表**：显示自定义消息 JSON 中的 `data` 字段文本（如果存在）
- **聊天详情页**：以文本消息样式显示自定义消息的 `data` 字段文本

**自定义消息 JSON 格式示例：**

```json
{
  "data": "这是自定义消息内容",
  "timestamp": 1763023008202,
  "type": "custom",
  "extra": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

#### 5.3.4 自定义消息协议说明

`PopIMCustomMessageProtocol` 协议定义了自定义消息必须实现的方法：

- **`init(originString: String)`**：从 JSON 字符串创建实例
- **`shouldSaveToDatabase() -> Bool`**：是否保存到本地数据库（默认 `true`）
- **`shouldCountUnread() -> Bool`**：是否计入未读数（默认 `true`）
- **`msgType() -> String`**：返回消息类型标识（必须实现）

### 5.4 插入消息

**Swift**

```swift
// 参数 conversationType 会话类型
// 参数 targetId 会话对象userId
// 参数 sentStatus 发送状态
// 参数 content 消息的内容
// 参数 sentTime 发送时间
// 参数 direction 消息方向（.send 发送 / .receive 接收）
// 参数 completion 插入结果
// completion PopIMMessageModel? 返回的消息，如果报错会返回nil
imSDK.insertMessage(conversationType: .privatechat, targetId: "10086", sentStatus: .success, content: textContent, sentTime: Int(Date().timeIntervalSince1970), direction: .send) { messageModel in
    
}
```

**Objective-C**

```objc
// 参数 conversationType 会话类型
// 参数 targetId 会话对象userId
// 参数 sentStatus 发送状态
// 参数 content 消息的内容
// 参数 sentTime 发送时间
// 参数 direction 消息方向（PopIMMessageDirectionSend / PopIMMessageDirectionReceive）
// 参数 completion 插入结果
[imSDK insertMessageWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" sentStatus:PopIMMessageSendStatusSuccess content:textContent sentTime:(NSInteger)[[NSDate date] timeIntervalSince1970] direction:PopIMMessageDirectionSend completion:^(PopIMMessageModel * _Nullable messageModel) {
    
}];
```

### 5.5 删除消息

#### 5.5.1 仅从本地删除指定消息

**Swift**

```swift
// 参数 messageIds 需要删除的消息id集合
// 参数 completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.deleteMessages(["message_id_1", "message_id_2"]) { isSuccess in
    
}
```

**Objective-C**

```objc
[imSDK deleteMessages:@[@"message_id_1", @"message_id_2"] completion:^(BOOL isSuccess) {
    
}];
```

#### 5.5.2 仅从本地删除会话全部历史消息

**Swift**

```swift
// 参数 conversationType 会话类型
// 参数 targetId 会话对方userId
// 参数 completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.clearMessages(conversationType: .privatechat, targetId: "10086") { isSuccess in
    
}
```

**Objective-C**

```objc
[imSDK clearMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" completion:^(BOOL isSuccess) {
    
}];
```

#### 5.5.3 彻底删除消息（本地和远程）

**Swift**

```swift
// 参数 conversationType 会话类型（单聊/群聊/系统消息/超级群）
// 参数 targetId 会话对方userId
// 参数 channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// 参数 messages 消息ID列表
// 参数 completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.deleteRemoteMessage(conversationType: .privatechat, targetId: "10086", channelId: "", messages: ["message_id_1", "message_id_2"]) { isSuccess in
    
}
```

**Objective-C**

```objc
[imSDK deleteRemoteMessageWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" messages:@[@"message_id_1", @"message_id_2"] completion:^(BOOL isSuccess) {
    
}];
```

#### 5.5.4 彻底清除会话的消息

**Swift**

```swift
// 参数 conversationType 会话类型（单聊/群聊/系统消息/超级群）
// 参数 targetId 会话对方userId
// 参数 channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// 参数 recordTime 时间戳。默认删除小于等于recordTime的消息。如果传0，则删除所有消息
// 参数 completion 删除的的回调
// completion Bool 操作是不是成功
imSDK.clearRemoteHistoryMessages(conversationType: .privatechat, targetId: "10086", channelId: "", recordTime: 0) { isSuccess in
    
}
```

**Objective-C**

```objc
[imSDK clearRemoteHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" recordTime:0 completion:^(BOOL isSuccess) {
    
}];
```

### 5.6 撤回消息

**Swift**

```swift
// 参数 message 需要撤回的消息
// 参数 successBlock 撤回成功的回调
// 参数 errorBlock 撤回失败的回调
imSDK.recallMessage(messageModel) { handleMessage in
    
} errorBlock: { (msg, handleMessage) in
    
}
```

**Objective-C**

```objc
[imSDK recallMessage:messageModel successBlock:^(PopIMMessageModel * handleMessage) {
    
} errorBlock:^(NSString * msg, PopIMMessageModel * handleMessage) {
    
}];
```

### 5.7 获取消息

#### 5.7.1 获取历史消息

**Swift**

```swift
// 参数 conversationType 会话类型（单聊/群聊/系统消息/超级群）
// 参数 targetId 会话的对象
// 参数 channelId 频道ID（超级群使用，传空字符串将使用默认频道YCDefault，其他会话类型可忽略）
// 参数 oldestMessageId 用于控制分页的边界，以此 messageId 为界，获取发送时间更小的 count 条消息。不设置或者设置成空，表示获取最新的 count 条消息。
// 参数 count 需要获取的消息数量，按照消息发送时间从新到旧排列
// 参数 completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getHistoryMessages(conversationType: .privatechat, targetId: "10086", channelId: "", oldestMessageId: nil, count: 50) { resultMessages in
    
}
```

**Objective-C**

```objc
// 获取历史消息（不包含 channelId，用于私聊和群聊）
[imSDK getHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];

// 获取历史消息（包含 channelId，用于超级群）
// @param channelId 频道ID，传空字符串将使用默认频道YCDefault
[imSDK getHistoryMessagesWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

#### 5.7.2 筛选历史消息

**Swift**

```swift
// 参数 conversationType 会话类型
// 参数 targetId 会话的对象
// 参数 messageType 消息类型
// 参数 oldestMessageId 用于控制分页的边界
// 参数 isForward 查询方向 true 为向前，false 为向后
// 参数 count 需要获取的消息数量
// 参数 completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.filterHistoryMessages(conversationType: .privatechat, targetId: "10086", messageType: .text, oldestMessageId: nil, isForward: false, count: 50) { resultMessages in
    
}
```

**Objective-C**

```objc
[imSDK filterHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" messageType:PopIMMessageTypeText oldestMessageId:nil isForward:NO count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

#### 5.7.3 搜索消息

**Swift**

```swift
// 参数 conversationType 会话类型
// 参数 targetId 会话对方userId
// 参数 keyword 关键字。传空默认为是查全部符合条件的消息。
// 参数 objectNameList 消息类型集合
// 参数 startTime 开始时间戳
// 参数 endTime 结束时间戳
// 参数 offset 偏移量
// 参数 limit 限制数量
// 参数 completion 搜索结果回调
imSDK.searchMessages(conversationType: .privatechat, targetId: "10086", keyword: "搜索关键词", objectNameList: [.text], startTime: nil, endTime: nil, offset: 0, limit: 50) { resultMessages in
    
}
```

**Objective-C**

```objc
[imSDK searchMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" keyword:@"搜索关键词" objectNameList:@[@(PopIMMessageTypeText)] startTime:nil endTime:nil offset:0 limit:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

#### 5.7.4 获取单条消息
根据消息ID获取单条消息。

**Swift**

```swift
// 获取单条消息
// @param msgId 消息id
// @param completion 获取的结果回调，返回消息对象，可能为nil
imSDK.getMessage(msgId: "message_id") { messageModel in
    
}
```

**Objective-C**

```objc
// 获取单条消息
// @param msgId 消息id
// @param completion 获取的结果回调，返回消息对象，可能为nil
[imSDK getMessageWithMsgId:@"message_id" completion:^(PopIMMessageModel * _Nullable messageModel) {
    
}];
```

#### 5.7.5 只获取远程消息
从服务器获取消息，保存到数据库，返回所有从服务器获取的消息。

**Swift**

```swift
// 只获取远程消息
// @param conversationType 会话类型
// @param targetId 会话的对象
// @param channelId 频道ID（超级群使用，默认为空）
// @param oldestMessageId 用于控制分页的边界，不设置或者设置成空，表示获取最新的 count 条消息
// @param count 需要获取的消息数量
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getRemoteHistoryMessages(conversationType: .privatechat, targetId: "10086", channelId: "", oldestMessageId: nil, count: 50) { resultMessages in
    
}
```

**Objective-C**

```objc
// 只获取远程消息（私聊/群聊）
[imSDK getRemoteHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];

// 只获取远程消息（超级群，包含 channelId）
[imSDK getRemoteHistoryMessagesWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

#### 5.7.6 只获取本地消息
仅从本地数据库查询，不请求远程。

**Swift**

```swift
// 只获取本地消息
// @param conversationType 会话类型
// @param targetId 会话的对象
// @param channelId 频道ID（超级群使用，默认为空）
// @param oldestMessageId 用于控制分页的边界，不设置或者设置成空，表示获取最新的 count 条消息
// @param count 需要获取的消息数量
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getLocalHistoryMessages(conversationType: .privatechat, targetId: "10086", channelId: "", oldestMessageId: nil, count: 50) { resultMessages in
    
}
```

**Objective-C**

```objc
// 只获取本地消息（私聊/群聊）
[imSDK getLocalHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];

// 只获取本地消息（超级群，包含 channelId）
[imSDK getLocalHistoryMessagesWithConversationType:PopIMMessageSessionTypeUltraGroup targetId:@"ultragroup_123" channelId:@"" oldestMessageId:nil count:50 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

#### 5.7.7 根据时间获取前后消息
根据指定时间戳获取该时间点前后各 n 条消息。

**Swift**

```swift
// 根据时间查询 - 返回指定时间前后各n条消息
// @param conversationType 会话类型
// @param targetId 会话的对象
// @param sentTime 指定的时间戳
// @param beforeCount 获取该时间之前的消息数量
// @param afterCount 获取该时间之后的消息数量
// @param completion 异步回调，返回获取到的消息实体 PopIMMessageModel 数组
imSDK.getHistoryMessages(conversationType: .privatechat, targetId: "10086", sentTime: 1700000000000, beforeCount: 10, afterCount: 10) { resultMessages in
    
}
```

**Objective-C**

```objc
// 根据时间查询 - 返回指定时间前后各n条消息
[imSDK getHistoryMessagesWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" sentTime:1700000000000 beforeCount:10 afterCount:10 completion:^(NSArray<PopIMMessageModel *> * resultMessages) {
    
}];
```

### 5.8 设置消息接收状态
设置消息的已读状态。

**Swift**

```swift
// 设置消息接收状态
// @param msgId 消息id
// @param receivedStatusInfo 接收状态信息（PopReceivedStatusInfo对象）
// @param completion 操作结果回调
let statusInfo = PopReceivedStatusInfo()
statusInfo.isRead = 1  // 0-未读，1-已读
imSDK.setMessageReceivedStatus(msgId: "message_id", receivedStatusInfo: statusInfo) { isSuccess in
    
}
```

**Objective-C**

```objc
// 设置消息接收状态
// @param msgId 消息id
// @param receivedStatusInfo 接收状态信息（PopReceivedStatusInfo对象）
// @param completion 操作结果回调
PopReceivedStatusInfo *statusInfo = [[PopReceivedStatusInfo alloc] init];
statusInfo.isRead = 1;  // 0-未读，1-已读
[imSDK setMessageReceivedStatusWithMsgId:@"message_id" receivedStatusInfo:statusInfo completion:^(BOOL isSuccess) {
    
}];
```

### 5.9 消息扩展

消息扩展允许在已发送的消息上附加额外的键值对信息，适用于投票、接龙、表情回应等场景。

#### 5.9.1 添加消息扩展监听

**Swift**

```swift
// 添加消息扩展监听
imSDK.setMessageExpansionListener(self)
// 移除消息扩展监听
imSDK.removeMessageExpansionListener(self)

// 遵守消息扩展代理协议
extension ViewController: PopMessageExpansionDelegate {
    // 消息扩展添加/更新
    // @param expansionDic 消息扩展信息中更新的键值对（非全量数据）
    // @param message 消息内容
    // @discussion 如果想获取全部的键值对，请使用 message 的 extra 属性处理
    func messageExpansionDidUpdate(expansionDic: [String: Any], message: PopIMMessageModel) {
        
    }
    
    // 消息扩展删除
    // @param keyArray 删除的key集合（非全量数据）
    // @param message 消息内容
    func messageExpansionDidRemove(keyArray: [String], message: PopIMMessageModel) {
        
    }
}
```

**Objective-C**

```objc
// 添加消息扩展监听
[imSDK setMessageExpansionListener:self];
// 移除消息扩展监听
[imSDK removeMessageExpansionListener:self];

// 遵循代理
@interface ViewController () <PopMessageExpansionDelegate>
@end

@implementation ViewController

// 消息扩展添加/更新
- (void)messageExpansionDidUpdateWithExpansionDic:(NSDictionary<NSString *, id> *)expansionDic message:(PopIMMessageModel *)message {
    
}

// 消息扩展删除
- (void)messageExpansionDidRemoveWithKeyArray:(NSArray<NSString *> *)keyArray message:(PopIMMessageModel *)message {
    
}

@end
```

#### 5.9.2 设置消息扩展

**Swift**

```swift
// 设置消息扩展
// @param conversationType 会话类型
// @param targetId 会话对方userId
// @param channelId 频道ID（超级群使用，其他类型传空字符串）
// @param msgId 消息id
// @param extraKeyVal 消息扩展的内容（键值对）
// @param successBlock 成功回调，成功会走新消息更新的逻辑
// @param errorBlock 失败的回调
imSDK.setMessageExtra(conversationType: .privatechat, targetId: "10086", channelId: "", msgId: "msg_123", extraKeyVal: ["key": "value"]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**

```objc
// 设置消息扩展
[imSDK setMessageExtraWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" msgId:@"msg_123" extraKeyVal:@{@"key": @"value"} successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

#### 5.9.3 删除消息扩展

**Swift**

```swift
// 删除消息扩展
// @param conversationType 会话类型
// @param targetId 会话对方userId
// @param channelId 频道ID（超级群使用，其他类型传空字符串）
// @param msgId 消息id
// @param keyArray 删除的key集合
// @param successBlock 成功回调
// @param errorBlock 失败的回调
imSDK.removeMessageExpansionForkeyArray(conversationType: .privatechat, targetId: "10086", channelId: "", msgId: "msg_123", keyArray: ["key1", "key2"]) {
    
} errorBlock: { errorMsg in
    
}
```

**Objective-C**

```objc
// 删除消息扩展
[imSDK removeMessageExpansionForkeyArrayWithConversationType:PopIMMessageSessionTypePrivatechat targetId:@"10086" channelId:@"" msgId:@"msg_123" keyArray:@[@"key1", @"key2"] successBlock:^{
    
} errorBlock:^(NSString * errorMsg) {
    
}];
```

## 六、推送相关


### 6.1 获取推送权限并自动请求推送token

**Swift**

```swift
// 如果项目中已经集成UIApplication.shared.registerForRemoteNotifications()，这里可以不用调用
imSDK.registerForRemoteNotifications()
```

**Objective-C**

```objc
// 获取推送权限并自动请求推送token
// 如果项目中已经集成UIApplication.shared.registerForRemoteNotifications()，这里可以不用调用
[imSDK registerForRemoteNotifications];
```

### 6.2 推送设备上报

在AppDelegate中添加推送注册方法

**Swift**

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // 注册设备成功
    PopIMLibSDK.shared.setDeviceTokenData(deviceToken)
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // 注册设备失败
    PopIMLibSDK.shared.didFailToRegisterForRemoteNotificationsWithError(error)
}
```

**Objective-C**

```objc
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 注册设备成功
    [[PopIMLibSDK shared] setDeviceTokenData:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // 注册设备失败
    [[PopIMLibSDK shared] didFailToRegisterForRemoteNotificationsWithError:error];
}
```

### 6.3 处理推送点击事件

如果使用imSDK.registerForRemoteNotifications()请求推送权限，则不用再特殊处理。反之则需要在 UNUserNotificationCenter.current().delegate的代理方法中上报。
点击的处理结果会以 PopIMConversationProtocol - didClickPushConversation 回调

**Swift**

```swift
// UNUserNotificationCenterDelegate
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) { 
    PopIMLibSDK.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    completionHandler()
}
```

**Objective-C**

```objc
// UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    [[PopIMLibSDK shared] userNotificationCenter:center didReceive:response withCompletionHandler:completionHandler];
    completionHandler();
}
```

### 6.4 推送到达率统计

推送到达率统计用于追踪推送消息是否成功送达用户设备。通过在 Notification Service Extension 中集成 `PopIMApnsLib`，当系统收到远程推送时，Extension 会在展示通知前调用 SDK 上报到达事件，从而实现推送到达率的精确统计。

#### 6.4.1 在项目创建通知拓展服务（Notification Service Extension）

1. 在 Xcode 中选择 **File → New → Target...**
2. 选择 **Notification Service Extension**，点击 Next
3. 填写 Extension 名称（如 `NotificationServiceExtension`），点击 Finish
4. Xcode 会自动生成 `NotificationService.swift`（或 `.m`）文件

> ⚠️ **注意**：Extension 的 Bundle Identifier 必须以主 App 的 Bundle Identifier 为前缀，例如主 App 为 `com.example.app`，则 Extension 应为 `com.example.app.NotificationServiceExtension`。

#### 6.4.2 导入 PopIMApnsLib

在 `Podfile` 中为 Extension target 添加依赖：
```ruby
use_frameworks!

target 'Example' do
    pod 'PopIMLib', '1.1.3.2'

    # 消息推送的拓展服务导入通知上报sdk
    target 'NotificationServiceExtension' do
        pod 'PopIMApnsLib', '1.0.2'
    end
end
```
终端执行 `pod install` 或 `pod update` 完成导入。

#### 6.4.3 在通知拓展服务中使用 PopIMApnsLib
 
在 `NotificationService` 文件中导入 `PopIMApnsLib`，并在收到推送时调用 `PopIMApnsLibSDK.didReceive(userInfo:)` 进行到达上报。

**Swift**

```swift
import UserNotifications
import PopIMApnsLib

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // 推送到达上报
        PopIMApnsLibSDK.didReceive(userInfo: request.content.userInfo as? [String: Any] ?? [:])
        
        if let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
```

**Objective-C**

```objc
#import <PopIMApnsLib/PopIMApnsLib-Swift.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // 推送到达上报
    [PopIMApnsLibSDK didReceiveWithUserInfo:request.content.userInfo];
    
    self.contentHandler(self.bestAttemptContent);
}

@end
```

## 七、日志与版本


### 7.1 添加日志

**Swift**

```swift
// 添加自定义日志
imSDK.addLogWithText("自定义日志信息")
```

**Objective-C**

```objc
// 添加自定义日志
[imSDK addLogWithText:@"自定义日志信息"];
```

### 7.2 获取日志目录路径
获取 SDK 日志文件所在目录路径。受元数据 config 中 `businessLogUpload` 控制：开启时返回目录路径，关闭或未下发时返回空字符串。

**Swift**

```swift
// 获取日志目录路径
let logPath = imSDK.getLogDirectoryPath()
```

**Objective-C**

```objc
// 获取日志目录路径
NSString *logPath = [imSDK getLogDirectoryPath];
```

### 7.3 获取版本信息

**Swift**

```swift
// 获取SDK版本号
let version = imSDK.getVersion()
// 获取SDK构建版本号
let buildVersion = imSDK.getBuildVersion()
```

**Objective-C**

```objc
// 获取SDK版本号
NSString *version = [imSDK getVersion];
// 获取SDK构建版本号
NSString *buildVersion = [imSDK getBuildVersion];
```

## 八、Public 文件说明

### 8.1 会话信息model
**PopIMConversationModel - 会话信息模型**
```swift
@objcMembers public class PopIMConversationModel: NSObject {
    //targetId单聊和群聊可能会重复，需要跟type、channelId聚合成唯一建
    public var targetId_type_channelId: String {
        return "\(targetId)_\(type.rawValue)_\(channelId)"
    }
    //会话类型，1-单聊、2-群聊、3-系统消息、6-超级群
    public var type: PopIMMessageSessionType = .privatechat
    //当前用户 id
    public var userId: String = ""
    //目标 id
    public var targetId: String = ""
    //频道ID（超级群使用）
    public var channelId: String = ""
    //序号
    public var seq: Int = 0
    //是否置顶
    public var isTop: Bool = false
    //是不是已删除
    public var isDelete: Bool = false
    //会话中头像的 url
    public var portraitUrl: String = ""
    //会话中目标的名称
    public var targetName: String = ""
    //最后一条消息（完整消息对象）
    public var lastMessage: PopIMMessageModel?
    //新消息数
    public var newMessageNum: Int = 0
    //会话@消息数量
    public var mentionedCount: Int = 0
    //---相关-设置
    //自动删除天数
    public var autoDeleteDay: Int = 0
    //会话的免打扰状态：消息状态设置：0- 免打扰， 空或者1- 提醒状态
    public var notificationStatus: String = ""
    //草稿
    public var draft: String = ""
    //更新时间
    public var updateTime: Int = 0
}
```

### 8.2 会话标签model
**PopIMConversationTag - 会话标签模型**
```swift
@objcMembers public class PopIMConversationTag: NSObject {
    //签唯一标识，字符型，长度不超过 10 个字
    public var tagId: String = ""
    //长度不超过 15 个字，标签名称可以重复
    public var tagName: String = ""
    //时间戳由 SDK 内部协议栈提供
    public var timestamp: Int = 0
    //标签对应的会话最大数量
    public var maxCount: Int = 0
    //标签对应的会话数量
    public var count: Int = 0
    
    public static func create(tagId: String, tagName: String) -> PopIMConversationTag {
        let tag = PopIMConversationTag()
        tag.tagId = tagId
        tag.tagName = tagName
        tag.timestamp = PopIMFuncTool.currentTimeInterval()
        return tag
    }
}
```
### 8.3 消息详情model
**PopIMMessageModel - 消息基础模型**
```swift
@objcMembers public class PopIMMessageModel: NSObject {
    //targetId单聊和群聊可能会重复，需要跟type、channelId聚合成唯一建
    public var targetId_type_channelId: String {
        return "\(targetId)_\(sessionType.rawValue)_\(channelId)"
    }
    //会话类型，1-单聊、2-群聊、3-系统消息、6-超级群
    public var sessionType: PopIMMessageSessionType = .privatechat
    //会话最大seq
    public var sessionSeq: String = ""
    //目标 id
    public var targetId: String = ""
    //频道ID（超级群使用）
    public var channelId: String = ""
    //消息类型
    public var msgType: PopIMMessageType = .unknown
    //客户端ID
    public var clientMsgId: String = ""
    //实际内容
    public var content: PopIMMessageContentProtocol = PopIMMessageContent()
    //是否为提醒消息 0-否;1-是 为1时参考content的mentionInfo
    public var isMentioned: Int = 0
    //发送方业务方Uid
    public var fromBizUid: String = ""
    //消息ID
    public var msgId: String = ""
    //发送时间-毫秒时间
    public var sendTime: Int = 0
    //过期时间
    public var expireTime: Int = 0
    //会话中头像的 url
    public var portraitUrl: String = ""
    //会话中目标的名称
    public var targetName: String = ""
    //发送状态： 成功0， 发送中1， 失败2
    public var sendStatus: PopIMMessageSendStatus = .success
    //删除状态 0未删除，1-已删除
    public var deleteStatus: Int = 0
    //是不是已读: 0-未读，1-已读
    public var isRead: Int = 0
    //0-不是离线，1-离线，默认0
    public var isOffLine: Int = 0
    //消息接收时间
    public var receivedTime: Int = 0
    //是否为拓展信息 0-否;1-是 为1时可以参考extra的拓展信息
    public var expansion: Int = 0
    //消息扩展
    public var extra:String = ""
    //消息类别： 1内容类消息-正常的单聊、群聊等用户之间发送的消息， 2-通知类消息， 3-信令类消息， 5-自定义消息
    public var msgCategory: Int = 1
    //消息类型字符串（msgTypeValue），用于自定义消息
    public var msgTypeValue: String = ""
    //消息方向: 0-发送，1-接收
    public var direction: PopIMMessageDirection
    
    public static func createWithInfoDic(_ dic: [String: Any]) -> PopIMMessageModel {
        return create(dic: dic)
    }
}
```

### 8.4 消息发送的对象
**PopIMMessageSend - 消息发送对象**
```swift
@objcMembers public class PopIMMessageSend: NSObject {
    //非必填，扩展标识：0-非扩展，1-扩展。如果extra不为空，expansion必须为1
    public var expansion: Int = 0
    //消息的扩展信息，设置的内容会原封不动保存在消息体中，可以用于传递自定义消息等
    public var extra: String = ""
    //选填-是不是需要push-默认是false-不推送
    public var enablePush: Bool = false
    //选填-推送的标题，不填或者填空，不会推送
    public var pushTitle: String = ""
    //选填-推送的内容，不填或者填空，不会推送
    public var pushContent: String = ""
    //选填-推送自定义数据，点击推送时原封不动通过didClickPushConversation回调返回
    public var pushData: String = ""
    //必填-对方ID
    public var targetId: String = ""
    //必填-会话类型
    public var conversationType: PopIMMessageSessionType = .privatechat
    //非必填，频道ID，如果是超级群channelId不传或者传"", 将使用默认频道发送
    public var channelId: String = ""
    //消息内容
    public var content:PopIMMessageContentProtocol?
}
```

### 8.5 会话搜索结果model
**PopIMSearchConversationResult - 会话搜索结果模型**
```swift
@objcMembers public class PopIMSearchConversationResult: NSObject {
    //匹配的会话
    public var conversation: PopIMConversationModel
    //该会话中匹配的消息数量
    public var matchCount: Int = 0
}
```

### 8.6 @提醒信息model
**PopMentionedInfo - @提醒信息模型**
```swift
@objcMembers public class PopMentionedInfo: NSObject {
    //@类型：1-@所有人，2-@指定用户
    public var type: PopIMMentionedType = .all
    //@的用户ID列表
    public var userIdList: [String] = []
    //自定义@通知文本
    public var mentionedContent: String?
}
```

### 8.7 消息接收状态model
**PopReceivedStatusInfo - 消息接收状态信息**
```swift
@objcMembers public class PopReceivedStatusInfo: NSObject {
    //是不是已读: 0-未读，1-已读
    public var isRead: Int = 0
}
```

### 8.8 消息相关content

#### 8.8.1 消息基础content，其他文本content、图片content都是基继承这个
**PopIMMessageContent - 消息基础content**
```swift
@objcMembers
public class PopIMMessageContent: NSObject {
    //原始数据
    public var originString: String = ""
}
```

#### 8.8.2 文本消息内容content
**PopIMMessageContent - 文本内容content**
```swift
@objcMembers public class PopIMTextMessageContent: PopIMMessageContent {
    //必填-消息内容-必传且不能为空
    public var content: String = ""
    //选填-at的用户集合
    public var atUserList: [String]?
}
```

#### 8.8.3 图片消息内容content
**PopIMImageMessageContent - 图片消息content**
```swift
@objcMembers public class PopIMImageMessageContent: PopIMMessageContent {
    //必填-缩略图URL地址,业务自己管理,可以为空
    public var thumImageUrl: String = ""
    //必填-原图图片URL地址,业务自己管理
    public var imageUrl: String = ""
    //必填-缩略图的宽度。
    public var thumWidth: Int = 0
    //必填-缩略图的宽度。
    public var thumHeight: Int = 0
}
```

#### 8.8.4 语音消息内容content
**PopIMVoiceMessageContent - 语音消息content**
```swift
@objcMembers public class PopIMVoiceMessageContent: PopIMMessageContent {
    //必填-语音URL地址,业务自己管理
    public var remoteUrl: String = ""
    //必填-原图图片URL地址,业务自己管理
    public var duration: Int = 0
}
```

#### 8.8.5 视频消息内容content
**PopIMVideoMessageContent - 视频消息content**
```swift
@objcMembers public class PopIMVideoMessageContent: PopIMMessageContent {
    //必填-封面图链接
    public var thumImageUrl: String = ""
    //必填-封面宽度
    public var thumWidth: Int = 0
    //缩略图的高度。
    public var thumHeight: Int = 0
    //视频链接
    public var videoUrl: String = ""
    //视频时长
    public var duration: Int = 0
    //视频大小,单位b
    public var size: Int = 0
}
```

#### 8.8.6 自定义消息协议和基类
**PopIMMessageContentProtocol - 消息内容协议**
```swift
@objc public protocol PopIMMessageContentProtocol: NSObjectProtocol {
    /// 指定该消息是否入库
    static func shouldSaveToDatabase() -> Bool
    
    /// 指定该消息是否计数
    static func shouldCountUnread() -> Bool
    
    /// 指定该消息的消息类型
    static func msgType() -> String
    
    /// 选填-at的用户集合
    var mentionedInfo: PopMentionedInfo? { get set }
}
```

**PopIMCustomMessageContent - 自定义消息内容基类（Swift）**
```swift
@objcMembers open class PopIMCustomMessageContent: PopIMMessageContent {
    /// 必需的初始化器，用于通过类型创建实例
    public required override init()
    
    /// 从 originString 创建自定义消息实例
    /// - Parameter originString: 原始 JSON 字符串
    public required init(originString: String)
    
    // MARK: - PopIMMessageContentProtocol 默认实现
    // 子类需要重写这些类方法来指定自己的行为
    open override class func msgType() -> String {
        return ""
    }
    
    open override class func shouldSaveToDatabase() -> Bool {
        return true
    }
    
    open override class func shouldCountUnread() -> Bool {
        return true
    }
}
```

**Objective-C 自定义消息类要求：**
- 继承自 `NSObject` 并遵循 `PopIMMessageContentProtocol` 协议
- 实现类方法：`+msgType`、`+shouldSaveToDatabase`、`+shouldCountUnread`
- 属性支持基本类型（String、Int、Bool、Double、Float、Array、Dictionary）和 NSObject 类型（支持递归序列化）
- 不需要手动实现 `originString`，SDK 会自动序列化属性为 JSON

**属性序列化说明：**
- SDK 会自动将自定义消息类的属性序列化为 JSON 字符串
- 支持基本类型：`String`、`Int`、`Bool`、`Double`、`Float`、`Array`、`Dictionary`
- 支持 NSObject 类型：会自动递归序列化嵌套对象的属性
- 在发送时，SDK 会自动调用 `getPropertiesDictionary` 获取所有属性并转换为 JSON
- 在接收时，SDK 会自动调用 `setPropertiesFromDictionary` 将 JSON 解析为属性值

### 8.9 枚举类型

#### 8.9.1 会话类型枚举
```swift
@objc public enum PopIMMessageSessionType: Int,CaseIterable {
    case privatechat   = 1    //私聊
    case groupchat     = 2    //群聊
    case system        = 3     //官方通知
    case ultraGroup    = 6    //超级群
}
```

#### 8.9.2 发送状态
```swift
@objc public enum PopIMMessageSendStatus: Int {
    case success   = 0 //成功
    case sending   = 1 //发送中
    case fail      = 2 //失败
}
```

#### 8.9.3 消息方向
```swift
@objc public enum PopIMMessageDirection: Int {
    case send      = 0 //发送
    case receive   = 1 //接收
}
```

#### 8.9.4 消息类型
```swift
@objc public enum PopIMMessageType: Int {
    case unknown        = -1   //未知消息
    case text           =  0  //正常的文本
    case image          =  1  //正常的图片
    case delntf         =  2  //消息删除通知
    case revokeNtf      =  3  //消息撤回通知
    case referenceMsg   =  4  //消息引用
    case msgExNtf       =  5  //扩展消息
    case combineMsg     =  6  //合并消息
    case voiceMsg       =  7   //语音消息
    case videoMsg       =  8   //视频消息
    case lbsMsg         =  9    //位置消息
}
```

#### 8.9.5 连接状态
```swift
@objc public enum PopIMConnectState: Int {
    case unknown    = -1 //未知
    case inConnect  = 0 //连接中
    case success    = 1 //连接成功
    case reconnect  = 2  //断开重连
    case fail       = 3  //链接失败
}
```

#### 8.9.6 服务错误码
```swift
@objc public enum PopIMServiceErrorCode: Int {
    case other                 = -1000  //其它错误
    case appkeyUnavailable     = -1001  //appKey本地验证不通过
    case tokenUnavailable      = -1002  //token本地验证不通过
    case userIdUnavailable     = -1003  //userId本地验证不通过
    case alreadyconnect        = -1004  //已连接，请不要重复连接
    case insufficientMemory    = -1005  //内存不足
    case invalidToken          = 401    //非法token
    case serverError           = 500    //服务端内部错误
}
```

#### 8.9.7 @提醒类型
```swift
@objc public enum PopIMMentionedType: Int {
    case all   = 1  //at所有人
    case user  = 2  //at部份人
}
```

#### 8.9.8 会话属性变更类型
```swift
@objc public enum PopIMConversationPropertyChangeType: Int {
    case unreadCount        = 1  //未读数变更（clearReadSync）
    case topStatus          = 2  //置顶状态变更（SessionChangeNtf）
    case notificationStatus = 3  //免打扰状态变更（SessionChangeNtf）
}
```

## 九、错误码参考

| 错误码 | 描述 | 解决方案 |
|--------|------|----------|
| 1001 | 初始化失败 | 检查 AppKey 是否正确，网络是否可用 |
| 1002 | 连接超时 | 检查网络环境，延长超时时间配置 |
| 1003 | Token 无效 | 重新获取 Token 并重新连接 |
| 2001 | 消息发送失败 | 检查会话 ID 是否正确，网络是否正常 |
| 2002 | 不支持的消息类型 | 确认消息类型是否在 SDK 支持范围内 |
| 3001 | 推送 Token 注册失败 | 检查推送证书配置，确保应用开启推送权限 |


## 十、常见问题

### 10.1 集成问题

1. **Q：Swift 与 Objective-C 混编时，提示"找不到类定义"？**  
   A：确保桥接文件正确导入 `#import <PopIMLib/PopIMLib-Swift.h>`，并在 Xcode 中配置桥接文件路径。

2. **Q：CocoaPods 集成失败？**  
   A：检查网络连接，确保 GitLab 访问权限，使用 Personal Access Token 而不是登录密码。

### 10.2 连接问题

3. **Q：消息发送成功但对方收不到？**  
   A：检查双方是否已连接服务器（`onConnectionStatusChanged` 确认状态为 `success`），会话类型与目标 ID 是否匹配。

4. **Q：连接频繁断开？**  
   A：检查网络稳定性，确保应用在后台时保持网络连接，考虑实现网络状态监听。

### 10.3 消息问题

5. **Q：离线消息如何同步？**  
   A：SDK 会在连接成功后自动同步离线消息，无需额外调用接口，可通过 `onReceived` 监听离线消息。

6. **Q：消息发送失败？**  
   A：检查网络连接状态，确认目标用户ID正确，验证消息内容格式是否符合要求。

### 10.4 推送问题

7. **Q：推送不显示？**  
   A：检查推送证书配置，确认应用推送权限已开启，验证设备Token是否正确上报。

8. **Q：推送点击无响应？**  
   A：确保实现了 `UNUserNotificationCenterDelegate` 代理方法，并正确调用 SDK 的处理方法。

### 10.5 调试问题

9. **Q：如何开启日志调试？**  
   A：使用 `imSDK.addLogWithText()` 方法添加自定义日志，或通过 Xcode 控制台查看 SDK 内部日志。

10. **Q：如何排查性能问题？**  
    A：使用 Xcode Instruments 工具分析内存使用和网络请求，检查是否有内存泄漏或频繁的网络调用。


## 十一、附录

- **SDK 版本历史**：[查看更新日志](https://developer.popim.com/docs/sdk/changelog)
- **完整 API 文档**：[在线文档](https://developer.popim.com/docs/sdk/api)
- **Demo 下载**：[GitHub 仓库](https://github.com/popim/PopIMLibDemo)
- **技术支持**：support@popim.com


**最后更新时间**：2026 年 7 月 10 日

---

## 十二、自定义消息完整示例

### 12.1 完整自定义消息实现示例

以下是一个完整的自定义消息实现示例，包括定义、注册、发送和接收：

**Swift - 自定义消息类定义**

```swift
import UIKit

class MyCustomMessage: PopIMCustomMessageContent {
    static let msgType = "MyApp:CustomMsg"
    
    required init(originString: String) {
        super.init(originString: originString)
    }
    
    required init() {
        super.init()
    }
    
    override class func msgType() -> String {
        return MyCustomMessage.msgType
    }
    
    override class func shouldSaveToDatabase() -> Bool {
        return true
    }
    
    override class func shouldCountUnread() -> Bool {
        return true
    }
    
    // 业务方法：解析自定义数据
    func parseCustomData() -> [String: Any]? {
        guard !originString.isEmpty else { return nil }
        return PopIMDemoFuncTool.mapDictionary(jsonString: originString)
    }
    
    // 业务方法：设置自定义数据
    func setCustomData(_ customData: [String: Any]) {
        if let jsonString = PopIMDemoFuncTool.mapJSONString(dic: customData) {
            self.originString = jsonString
        }
    }
}
```

**Objective-C - 自定义消息类定义（PopIMOCCustomMessage）**

```objc
// PopIMOCCustomMessage.h
#import <Foundation/Foundation.h>
#import "YCIMProject-Swift.h"

// 前向声明 Swift 中定义的协议和类
@protocol PopIMMessageContentProtocol;
@class PopMentionedInfo;

NS_ASSUME_NONNULL_BEGIN

/// Objective-C 自定义消息类示例
/// 遵循 PopIMMessageContentProtocol 协议，实现协议要求的方法和属性
@interface PopIMOCCustomMessage : NSObject <PopIMMessageContentProtocol>

/// 字符串属性示例
@property (nonatomic, copy) NSString *stringLa;

/// 整数属性示例
@property (nonatomic, assign) int intLa;

/// 字典属性示例
@property (nonatomic, copy) NSDictionary *dicLa;

/// 选填-at的用户集合
@property (nonatomic, strong, nullable) PopMentionedInfo *mentionedInfo;

/// 嵌套对象示例（支持 NSObject 类型的递归序列化）
@property (nonatomic, strong, nullable) PopIMOCSDKTest1 *text1;

@end

NS_ASSUME_NONNULL_END
```

```objc
// PopIMOCCustomMessage.m
#import "PopIMOCCustomMessage.h"
#import "YCIMProject-Swift.h"

@implementation PopIMOCCustomMessage

// MARK: - PopIMMessageContentProtocol 实现

/// 指定该消息的消息类型
+ (NSString *)msgType {
    return @"OC:TestCustomMsg";
}

/// 指定该消息是否入库
+ (BOOL)shouldSaveToDatabase {
    return NO;  // 示例：不入库
}

/// 指定该消息是否计数
+ (BOOL)shouldCountUnread {
    return NO;  // 示例：不计入未读数
}

// MARK: - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        _mentionedInfo = nil;
    }
    return self;
}

@end
```

**Swift - 注册和发送**

```swift
// 在应用启动时注册（如 AppDelegate 或会话列表加载时）
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 注册自定义消息类
    PopIMLibSDK.shared.registerCustomMessage(messageClass: MyCustomMessage.self)
    return true
}

// 发送自定义消息
func sendCustomMessage() {
    let messageSend = PopIMMessageSend()
    messageSend.targetId = "10086"
    messageSend.conversationType = .privatechat
    
    let customMessage = MyCustomMessage()
    let customData: [String: Any] = [
        "data": "这是自定义消息内容",
        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        "type": "custom",
        "extra": [
            "key1": "value1",
            "key2": "value2"
        ]
    ]
    customMessage.setCustomData(customData)
    
    messageSend.content = customMessage
    
    PopIMLibSDK.shared.sendMessage(message: messageSend) { messageModel in
        print("自定义消息发送成功")
    } errorBlock: { (errorMsg, _) in
        print("自定义消息发送失败: \(errorMsg)")
    }
}
```

**Objective-C - 注册和发送（testCustomMessage 示例）**

```objc
+ (void)testCustomMessage {
    NSLog(@"=== 测试自定义消息相关方法（重点） ===");
    
    PopIMLibSDK *sdk = [PopIMLibSDK shared];
    
    // 1. 注册自定义消息类（新方式：传递类类型）
    [sdk registerCustomMessageWithMessageClass:[PopIMOCCustomMessage class]];
    
    // 2. 创建并发送自定义消息
    PopIMMessageSend *customMessageSend = [[PopIMMessageSend alloc] init];
    customMessageSend.targetId = @"test_target_id";
    customMessageSend.conversationType = PopIMMessageSessionTypePrivatechat;
    customMessageSend.channelId = @"";
    
    // 创建自定义消息内容并设置属性
    // SDK 会自动将属性序列化为 JSON（支持基本类型和 NSObject 类型的递归序列化）
    PopIMOCCustomMessage *sendCustomContent = [[PopIMOCCustomMessage alloc] init];
    sendCustomContent.stringLa = @"1";
    sendCustomContent.intLa = 2;
    sendCustomContent.dicLa = @{@"1": @"2"};
    
    // 设置嵌套对象（支持 NSObject 类型的递归序列化）
    PopIMOCSDKTest1 *text1 = [[PopIMOCSDKTest1 alloc] init];
    PopIMOCSDKTest2 *text2 = [[PopIMOCSDKTest2 alloc] init];
    text2.test2Str = @"test2Str";
    text1.test2 = text2;
    sendCustomContent.text1 = text1;
    
    customMessageSend.content = sendCustomContent;
    
    // 发送消息
    [sdk sendMessageWithMessage:customMessageSend
                    successBlock:^(PopIMMessageModel * _Nonnull message) {
        NSLog(@"✓ 自定义消息发送成功: %@", message.msgId);
    } errorBlock:^(NSString * _Nonnull errorMsg, PopIMMessageModel * _Nullable message) {
        NSLog(@"✗ 自定义消息发送失败: %@", errorMsg);
    }];
    
    // 3. 获取已注册的自定义消息类
    Class retrievedClass = [sdk getCustomMessageTemplateWithMsgType:@"OC:TestCustomMsg"];
    if (retrievedClass) {
        NSLog(@"✓ 成功获取自定义消息类: %@", NSStringFromClass(retrievedClass));
    } else {
        NSLog(@"✗ 未找到注册的自定义消息类");
    }
}
```

**Swift - 接收自定义消息**

```swift
extension ViewController: PopIMMessageProtocol {
    func onReceived(_ messages: [PopIMMessageModel], offline: Bool) {
        for message in messages {
            if message.msgCategory == 5 || (message.msgType == .unknown && !message.msgTypeValue.isEmpty) {
                if let customContent = message.content as? MyCustomMessage {
                    if let customData = customContent.parseCustomData() {
                        let data = customData["data"] as? String ?? ""
                        print("收到自定义消息: \(data)")
                    }
                }
            }
        }
    }
}
```

**Objective-C - 接收自定义消息**

```objc
- (void)onReceived:(NSArray<PopIMMessageModel *> *)messages offline:(BOOL)offline {
    for (PopIMMessageModel *message in messages) {
        // 判断是否为自定义消息
        if (message.msgCategory == 5 || (message.msgType == PopIMMessageTypeUnknown && message.msgTypeValue.length > 0)) {
            // 检查消息内容是否为已注册的自定义消息类型
            if ([message.content isKindOfClass:[PopIMOCCustomMessage class]]) {
                PopIMOCCustomMessage *customContent = (PopIMOCCustomMessage *)message.content;
                // 直接访问属性（SDK 已自动解析）
                NSLog(@"收到自定义消息:");
                NSLog(@"  - stringLa: %@", customContent.stringLa);
                NSLog(@"  - intLa: %d", customContent.intLa);
                NSLog(@"  - dicLa: %@", customContent.dicLa);
                
                // 访问嵌套对象（支持递归解析）
                if (customContent.text1 && customContent.text1.test2) {
                    NSLog(@"  - text1.test2.test2Str: %@", customContent.text1.test2.test2Str);
                }
            } else if ([message.content isKindOfClass:[PopIMCustomMessageContent class]]) {
                // 如果未注册，使用基类访问 originString
                PopIMCustomMessageContent *customContent = (PopIMCustomMessageContent *)message.content;
                NSLog(@"收到未注册的自定义消息: %@", customContent.originString);
            }
        }
    }
}
```

### 12.2 自定义消息字段说明

#### 12.2.1 PopIMMessageModel 新增字段

- **`msgCategory: Int`**：消息类别
  - `1`：内容类消息（正常的单聊、群聊等用户之间发送的消息）
  - `2`：通知类消息
  - `3`：信令类消息
  - `5`：自定义消息（由后端控制，发送时不需要设置）

- **`msgTypeValue: String`**：消息类型字符串，用于自定义消息
  - 自定义消息的 `msgTypeValue` 由自定义消息类的 `msgType()` 方法返回
  - 用于标识和解析自定义消息类型

#### 12.2.2 PopIMConversationModel 相关字段

- **`lastMessage: PopIMMessageModel?`**：最后一条消息（完整消息对象）
  - 当会话的最后一条消息是自定义消息时，可以通过 `lastMessage?.msgTypeValue` 获取消息的 `msgTypeValue`
  - 用于在会话列表中正确解析和显示自定义消息

### 12.3 自定义消息 JSON 格式

自定义消息的 `originString` 必须是有效的 JSON 字符串。建议格式：

```json
{
  "data": "这是自定义消息内容",
  "timestamp": 1763023008202,
  "type": "custom",
  "extra": {
    "key1": "value1",
    "key2": "value2"
  }
}
```

**字段说明：**
- `data`：消息的主要内容，会在会话列表和聊天详情页显示
- `timestamp`：时间戳（可选）
- `type`：消息类型标识（可选）
- `extra`：扩展信息（可选）

### 12.4 属性序列化和解析

**自动序列化：**
- SDK 会自动将自定义消息类的属性序列化为 JSON 字符串
- 支持基本类型：`String`、`Int`、`Bool`、`Double`、`Float`、`Array`、`Dictionary`
- 支持 NSObject 类型：会自动递归序列化嵌套对象的属性
- 在发送时，SDK 会自动调用 `getPropertiesDictionary` 获取所有属性并转换为 JSON
- 不需要手动设置 `originString`，SDK 会在发送时自动生成

**自动解析：**
- SDK 会自动将接收到的 JSON 字符串解析为自定义消息类的属性
- 支持基本类型和 NSObject 类型的递归解析
- 在接收时，SDK 会自动调用 `setPropertiesFromDictionary` 将 JSON 解析为属性值
- 如果自定义消息类已注册，`message.content` 会是具体的自定义消息类实例
- 如果未注册，`message.content` 会是 `PopIMCustomMessageContent` 基类实例，可以访问 `originString` 获取原始 JSON

### 12.5 注意事项

1. **msgType 唯一性**：`msgType` 必须全局唯一，建议使用格式：`"AppName:MessageType"`（如 `"MyApp:CustomMsg"`）
2. **注册时机**：自定义消息类必须在发送前注册，建议在应用启动时统一注册
3. **属性类型**：只支持基本类型（String、Int、Bool、Double、Float、Array、Dictionary）和 NSObject 类型（支持递归序列化）
4. **Objective-C 头文件**：在 `.h` 文件中使用前向声明，避免导入 Swift 头文件，在 `.m` 文件中导入 Swift 头文件
5. **msgCategory**：自定义消息的 `msgCategory` 由后端控制，发送时不需要设置
6. **未注册处理**：如果接收到的自定义消息未注册，SDK 会使用 `PopIMCustomMessageContent` 基类实例，可以直接访问 `originString` 获取原始 JSON 数据
7. **不入库但通知**：如果 `shouldSaveToDatabase()` 返回 `false`，消息不会保存到数据库，但仍会通过 `onReceived` 回调通知到外部
