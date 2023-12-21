#
#  Be sure to run `pod spec lint SeaCat.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "SeaCat"
  spec.version      = "23.12.01"
  spec.summary      = "SeaCat SDK for iOS (3rd generation)."
  spec.description  = <<-DESC
  SeaCat cyber-security platform consists of a SeaCat SDK that is to be added into an mobile or IoT application, 
  the SeaCat Gateway that is to be installed into demilitarized zone (DMZ) in front of the application backend 
  servers and SeaCat PKI that is a service that provides enrolment, access and identity management. 
  It is designed to be transparent to a mobile application developers, easily operable by sysadmins and to 
  provide maximum visibility for cybersecurity teams.
                   DESC

  spec.homepage     = "https://teskalabs.com/products/seacat"
  spec.screenshots  = "https://teskalabscom.azureedge.net/media/img/product/seacat-high-level-arch.png"

  spec.license      = { :type => "BSD-3-Clause License", :file => "LICENSE" }
  spec.author       = { "TeskaLabs Ltd " => "info@teskalabs.com" }

  spec.ios.deployment_target = "12.0"
  spec.osx.deployment_target = "10.15"

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3']

  spec.source       = { :git => "https://github.com/TeskaLabs/SeaCat-iOS-G3.git", :tag => "#{spec.version}" }

  spec.source_files  = "seacat/**/*.{swift}"

end
