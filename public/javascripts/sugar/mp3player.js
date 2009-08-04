// Configure SoundManager2
soundManager.debugMode = false;
soundManager.url = '/flash/soundmanager2';

$.extend(Sugar.Initializers, {
	detectSongs: function(){
		Sugar.MP3Player.detectSongs();
	}
});

$.extend(Sugar.onLoadedPosts, {
	detectSongs: function(){
		Sugar.MP3Player.detectSongs();
	}
});
	
	
Sugar.MP3Player = {
	songs: [],
	playingSong: false,

	detectSongs: function(){
		$('a.mp3player').each(function(){
			Sugar.MP3Player.applyToLink(this);
		});
	},

	applyToLink: function(link){
		if(!link.songID){
			link.songID = 'song-'+(Sugar.MP3Player.songs.length + 1);
			link.originalTitle = $(link).html();
			$(link).addClass('mp3player_stopped');
			$(link).click(function(){
				Sugar.MP3Player.toggleSong(this);
				return false;
			});
			Sugar.MP3Player.songs.push(link);
		}
	},

	msToMinsAndSeconds: function(ms){
		var minutes = Math.floor(ms / 60000);
		var seconds = Math.floor((ms - (minutes * 60000)) / 1000);
		if(seconds < 10) {
			seconds = '0'+seconds;
		}
		return minutes + ":" + seconds;
	},

	stopAllSongs: function(){
		$(Sugar.MP3Player.songs).each(function(){
			Sugar.MP3Player.stopSong(this);
		});
	},
	
	playNextSong: function() {
		var index = false;
		for(var a = 0; a < Sugar.MP3Player.songs.length; a++){
			if(Sugar.MP3Player.songs[a] == Sugar.MP3Player.playingSong) {
				index = a;
			}
		}
		index += 1;
		if(index >= Sugar.MP3Player.songs.length){
			index = 0;
		}
		Sugar.MP3Player.playSong(Sugar.MP3Player.songs[index]);
	},
	
	playSong: function(song) {
		Sugar.MP3Player.stopAllSongs();
		$(song).addClass('mp3player_playing').removeClass('mp3player_stopped');
		Sugar.MP3Player.playingSong = song;
		song.playing = true;
		song.songObject = soundManager.createSound({id: song.songID, url: song.href});
		soundManager.play(song.songID, {onfinish: function(){
			Sugar.MP3Player.playNextSong();
		}});
		$(song).html(''+song.originalTitle + ' <span class="position">Loading</span>');
		song.progressInterval = setInterval(function(){
			songObj = song.songObject;
			if(songObj.position){
				var position = Sugar.MP3Player.msToMinsAndSeconds(songObj.position) + ' / ';
				if(songObj.loaded){
					position += Sugar.MP3Player.msToMinsAndSeconds(songObj.duration);
				} else {
					position += Sugar.MP3Player.msToMinsAndSeconds(songObj.durationEstimate);
				}
				$(song).children('.position').html(position);
			}
		}, 1000);
	},

	stopSong: function(song) {
		if(song.playing){
			$(song).addClass('mp3player_stopped').removeClass('mp3player_playing');
			Sugar.MP3Player.playingSong = false;
			song.playing = false;
			clearInterval(song.progressInterval);
			$(song).html(song.originalTitle);
			soundManager.stop(song.songID);
		}
	},
	
	toggleSong: function(song) {
		if(Sugar.MP3Player.playingSong && Sugar.MP3Player.playingSong == song){
			Sugar.MP3Player.stopSong(song);
		} else {
			Sugar.MP3Player.playSong(song);
		}
	}
};