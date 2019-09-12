
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "CalendarDateRangePicker"
  s.version      = "1.7"
  s.summary      = "A calendar date range picker view controller in Swift for iOS."

  s.description  = <<-DESC
  This is a calendar date range picker view controller written in Swift for iOS. The typical use case is where you want the user to input a date range, i.e. a start date and an end date. This view controller allows this in an intuitive way, and is easy to use by implementing the delegate methods. See the example project for a taste.
                   DESC

  s.homepage     = "https://github.com/Ljuka/CalendarDateRangePicker"
  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Ljuka" => "ljubom94@gmail.com" }

  # ――― Platform Specifics ―――――――――――――――――――――――――――――――――――――――――――――――――――――――
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.swift_version = "5"
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/Ljuka/CalendarDateRangePicker.git" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files = 'CalendarDateRangePickerViewController/Classes/**/*'

end
