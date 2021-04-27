#
# Be sure to run `pod lib lint YWNetWorking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'YWNetWorking'
    s.version          = '0.3.1'
    s.summary          = 'iOS networking'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = "灵活定制的网络请求框架"
    
    s.homepage         = 'https://github.com/flyOfYW/YWNetWorking'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'flyOfYW' => '1498627884@qq.com' }
    s.source           = { :git => 'https://github.com/flyOfYW/YWNetWorking.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '9.0'
    
    #  s.source_files = 'YWNetWorking/Classes/YWNetWorking/**/*'
#    s.public_header_files = 'YWNetWorking/Classes/YWNetWorking/YWNetworkingProtocol.h'
#    s.source_files = 'YWNetWorking/Classes/YWNetWorking/YWNetworkingProtocol.h'
    
    
    s.subspec 'NetStatus' do |ns|
        ns.source_files = 'YWNetworking/Classes/YWNetworking/NetStatus/*.{h,m}'
        ns.public_header_files = 'YWNetWorking/Classes/YWNetWorking/NetStatus/YWApiNetStatus.h'
    end
    
    s.subspec 'NetWork' do |ns|
        ns.source_files = 'YWNetworking/Classes/YWNetworking/NetWork/**/*'
        ns.dependency 'YWNetWorking/NetStatus'
        ns.dependency 'AFNetworking'
    end

    
    # s.resource_bundles = {
    #   'YWNetWorking' => ['YWNetWorking/Assets/*.png']
    # }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    #    s.frameworks = 'CoreTelephony'
end
