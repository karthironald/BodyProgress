# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'BodyProgress' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BodyProgress

pod 'Firebase/Analytics'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end

end
