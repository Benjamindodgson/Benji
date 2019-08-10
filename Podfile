# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Benji' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Parse'
  pod 'TwilioChatClient'
  pod 'TwilioAccessManager'
  pod 'GestureRecognizerClosures'
  pod 'ReactiveSwift'
  pod 'Koloda'

end

post_install do |installer|

    # Twilio chat client includes a prebuilt framework that is too big to source control
    # To get around this, strip the bitcode from the framework to reduce its file size
    bitcode_strip_path = `xcrun -sdk iphoneos --find bitcode_strip`.chop!

    # Find path to TwilioChatClient dependency
    path = Dir.pwd
    framework_path = "#{path}/Pods/TwilioChatClient/TwilioChatClient.framework/TwilioChatClient"

    # Strip Bitcode sections from the framework
    strip_command = "#{bitcode_strip_path} #{framework_path} -m -o #{framework_path}"
    puts "About to strip: #{strip_command}"
    system(strip_command)

end
