require 'script_bundle'

ScriptBundle.bundle 'application' do |bundle|
	bundle.add 'jquery.min.js'
	bundle.add 'rails.js', :compress => true
	bundle.add 'vendor/jquery.hotkeys.js', :compress => true
	bundle.add 'vendor/jquery.scrollTo.js'
	bundle.add 'vendor/jquery.autocomplete.js'
	bundle.add 'vendor/swfobject.js'
	bundle.add 'vendor/soundmanager2.js'
	bundle.add 'vendor/jquery.beautyOfCode.js', :compress => true
	bundle.add 'vendor/jquery.libraries.js', :compress => true
	bundle.add 'sugar/sugar.js', :compress => true
	bundle.add 'sugar/maps.js', :compress => true
	bundle.add 'sugar/mp3player.js', :compress => true
	bundle.add 'sugar/posts.js', :compress => true
	bundle.add 'sugar/hotkeys.js', :compress => true
	bundle.add 'sugar/facebook.js', :compress => true
	bundle.add 'application.js', :compress => true
end

ScriptBundle.bundle 'mobile' do |bundle|
	bundle.add 'jquery.min.js'
	bundle.add 'mobile.js', :compress => true
end