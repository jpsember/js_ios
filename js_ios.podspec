#
# Be sure to run `pod lib lint js_ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "js_ios"
  s.version          = "0.1.0"
  s.summary          = "Jeff's fundamental iOS library"
  s.description      = <<-DESC
                       Various classes to facilitate iOS development and testing

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://bitbucket.org/jpsember/js_ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jeff Sember" => "jpsember@gmail.com" }
  s.source           = { :git => "https://jpsember@bitbucket.org/jpsember/js_ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

  # For now, include the test resources in the resource bundle; ideally we would like this to
  # only be included for the Example test target...
  s.resources = 'Example/test_resources'

  s.frameworks = 'XCTest'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
