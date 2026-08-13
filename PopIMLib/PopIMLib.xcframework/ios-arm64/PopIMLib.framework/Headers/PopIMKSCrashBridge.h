//
//  PopIMKSCrashBridge.h
//  PopIMLib
//
//  KSCrash ObjC → Swift 桥接层
//  将 KSCrash 的核心 API 封装为 Swift 可直接调用的 ObjC 类
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// KSCrash 崩溃监控类型（对应 KSCrashMonitorType）
typedef NS_OPTIONS(NSUInteger, PopIMCrashMonitorType) {
    PopIMCrashMonitorTypeMachException     = 1 << 0,
    PopIMCrashMonitorTypeSignal            = 1 << 1,
    PopIMCrashMonitorTypeCPPException      = 1 << 2,
    PopIMCrashMonitorTypeNSException       = 1 << 3,
    PopIMCrashMonitorTypeMainThreadDeadlock= 1 << 4,
    PopIMCrashMonitorTypeUserReported      = 1 << 5,
    PopIMCrashMonitorTypeSystem            = 1 << 6,
    PopIMCrashMonitorTypeApplicationState  = 1 << 7,
    PopIMCrashMonitorTypeZombie            = 1 << 8,
    PopIMCrashMonitorTypeMemoryTermination = 1 << 9,
};

/// KSCrash 报告清理策略
typedef NS_ENUM(NSUInteger, PopIMCrashReportCleanupPolicy) {
    PopIMCrashReportCleanupPolicyNever,
    PopIMCrashReportCleanupPolicyOnSuccess,
    PopIMCrashReportCleanupPolicyAlways,
};

/// KSCrash Swift 桥接类
@interface PopIMKSCrashBridge : NSObject

/// 安装 KSCrash 崩溃监控
/// @param monitors 要启用的监控类型（位掩码）
/// @param maxReportCount 最大报告数量
/// @param cleanupPolicy 报告清理策略
/// @param enableSwapCxaThrow 是否启用 C++ cxa_throw 替换
/// @param userInfo 附加到崩溃报告的自定义信息
/// @param error 错误信息
/// @return 是否安装成功
+ (BOOL)installWithMonitors:(PopIMCrashMonitorType)monitors
             maxReportCount:(NSInteger)maxReportCount
              cleanupPolicy:(PopIMCrashReportCleanupPolicy)cleanupPolicy
        enableSwapCxaThrow:(BOOL)enableSwapCxaThrow
                   userInfo:(nullable NSDictionary<NSString *, id> *)userInfo
                      error:(NSError * _Nullable * _Nullable)error;

/// 更新崩溃报告中的用户信息
/// @param userInfo 新的用户信息字典
+ (void)updateUserInfo:(nullable NSDictionary<NSString *, id> *)userInfo;

/// 获取所有待发送的崩溃报告 ID
/// @return 报告 ID 数组（NSNumber 包裹的 int64）
+ (NSArray<NSNumber *> *)pendingReportIDs;

/// 获取指定 ID 的崩溃报告内容
/// @param reportID 报告 ID
/// @return 崩溃报告字典，如果不存在返回 nil
+ (nullable NSDictionary<NSString *, id> *)reportForID:(int64_t)reportID;

/// 删除指定 ID 的崩溃报告
/// @param reportID 报告 ID
+ (void)deleteReportWithID:(int64_t)reportID;

/// 删除所有崩溃报告
+ (void)deleteAllReports;

/// 上次启动是否崩溃
+ (BOOL)crashedLastLaunch;

@end

NS_ASSUME_NONNULL_END
