Pod::Spec.new do |spec|

  spec.name         = "OLNetworking"
  spec.version      = "0.0.1"
  spec.summary      = "Бибилиотека для работы с сетью"

  spec.description  = <<-DESC

    0.0.1 Первая версия

                   DESC

  spec.homepage     = "http://idev.kz"

  spec.license      = { :type => 'Custom', :text => <<-LICENSE
    Copyright 2018
    Permission is granted to Oleg Leizer Kazahstan
    LICENSE
  }

  spec.author             = { "Oleg Leizer" => "oleizer@gmail.com" }

  spec.platform     = :ios, "10.0"
  spec.swift_version = "4.2"

  spec.source       = { :git => "github.com:oleizer/OLNetworking.git", :tag => "#{spec.version}" }

  spec.source_files  = ["**/*.{h,m,swift}"]
  spec.exclude_files  = ["**/*Tests.{swift}"]
  spec.dependency 'PromiseKit'
  spec.dependency 'Moya'


  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = [
      "**/*Tests.{swift}",
      "**/*Mock.{swift}"
    ]
    test_spec.dependency 'Nimble'
    test_spec.dependency 'Quick'
  end
end
