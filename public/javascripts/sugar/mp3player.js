$.extend(Sugar.Initializers, {
	loadSoundManager: function(){
		if($('a.mp3player').size() > 0){
			$.getScript('/javascripts/soundmanager2.min.js', function(){
				soundManager.debugMode = true;
				soundManager.url = '/flash/soundmanager2';
				soundManager.onload = function() {
					Sugar.MP3Player.initialize();
				};
			});
		}
	}
});


Sugar.MP3Player = {
	initialize: function(){
		$('a.mp3player').each(function(){
			$(this).addClass('mp3player_stopped');
			this.playing = false;
			$(this).click(function(){
				return false;
			});
		});
		//soundManager.createSound('helloWorld','http://cos.microhertz.net/demo/mp3/02%20Last%20Night%20I%20Killed%20a%20Porcupine.mp3');
		//soundManager.play('helloWorld');
	}
};