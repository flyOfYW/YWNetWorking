+ v0.0.1
    + 网络检测功能
        + 根据项目是否包含AFNetworkReachabilityManager和Reachability的库来选择自动选择网络检测功能
    
    
+ v0.1.0
    + 加入系统CoreTelephony库，判断网络类型
        + 网络类型：GPRS，2G，3G，4G
    + 基本请求功能（GET/POST/PUT/DELETE）

    
+ v0.1.1
    + 新增config管理和日志管理
    + 依据config参数控制请求时是否自动检验网络状态
    + 加入结构体优化delegate响应方法的状态
    
    
+ v0.1.2
    + 通过YWServiceProtocol协议开放AFHTTPSessionManager的权限，更灵活使用
    + 新增开放对返回的数据数据权限，可以让开发者更灵活控制成功和失败回调的去向
    + 新增超时重试功能
    
    
+ v0.1.3
    + 新增拦截器（可作一些特殊情况处理）
    + 新增登录和刷新token的通知，供业务层处理
    + 新增回调失败前的拦截器api，供开发者选择性处理（如刷新token的时候，告诉框架不需要走回调了，等刷新token成功后，在调用重试api，即可展示数据）
    + 新增回调成功前的拦截器api，供开发者选择性处理
    + 新增config清理内存api
    + 新增取消请求任务api
    
+ v0.1.4
    + 新增NSCache缓存
    + 新增清除缓存Cache的API
    
+ v0.1.6
   + 支持cocopod引入
   
+ v0.1.7
   + 新增缓存限制条数
