#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ==============================
// ⚠️ 请在这里修改你的后台地址
// 必须保留 http:// 或 https://
// ==============================
#define API_URL @"http://你的宝塔IP或域名/status.php"

__attribute__((constructor)) static void entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 获取包名
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        // 拼接请求地址
        NSString *urlString = [NSString stringWithFormat:@"%@?id=%@", API_URL, bundleID];
        NSURL *url = [NSURL URLWithString:urlString];
        
        // 发起请求
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // 如果请求失败或网络不通，默认让用户通过（防止误杀），或者你可以改为 exit(0) 强制退出
            if (error || !data) return;
            
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            // 如果服务器返回 EXPIRED，则弹窗并退出
            if ([result containsString:@"EXPIRED"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                   message:@"授权已过期，请联系管理员续费"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                        exit(0);
                    }]];
                    
                    // 尝试找到显示的窗口弹窗
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    [window.rootViewController presentViewController:alert animated:YES completion:nil];
                });
            }
        }] resume];
    });
}
