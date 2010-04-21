/*
 * Sugar.MP3Player - Javascript MP3 player
 * Copyright (c) 2009 Inge Jørgensen (elektronaut.no)
 */


// Configure SoundManager2
soundManager.debugMode = false;
soundManager.url = '/flash/soundmanager2';

(function($S){

	$($S).bind('ready postsloaded', function(){
		this.MP3Player.detectSongs();
	});

	$S.MP3Player = {
		songs:       [],
		playingSong: false,

		detectSongs: function(){
			var detectedSongs = 0;
			$('a.mp3player').each(function(){
				if($S.MP3Player.applyToLink(this)){
					detectedSongs += 1;
				}
			});
			if(detectedSongs > 0){
				$S.log('MP3Player: Detected '+detectedSongs+' new songs.');
			}
		},

		applyToLink: function(link){
			if(!link.songID){
				link.songID = 'song-'+($S.MP3Player.songs.length + 1);
				link.originalTitle = $(link).html();
				$(link).addClass('mp3player_stopped');
				$(link).click(function(){
					$S.MP3Player.toggleSong(this);
					return false;
				});
				this.songs[this.songs.length] = link;
				return link;
			}
			return false;
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
			$(this.songs).each(function(){
				$S.MP3Player.stopSong(this);
			});
		},
	
		playNextSong: function() {
			var index = false;
			for(var a = 0; a < this.songs.length; a++){
				if(this.songs[a] == this.playingSong) {
					index = a;
				}
			}
			index += 1;
			if(index >= this.songs.length){
				index = 0;
			}
			this.playSong(this.songs[index]);
		},
	
		playSong: function(song) {
			this.stopAllSongs();
			$(song).addClass('mp3player_playing').removeClass('mp3player_stopped');
			this.playingSong = song;
			song.playing = true;
			song.songObject = soundManager.createSound({id: song.songID, url: song.href});
			soundManager.play(song.songID, {onfinish: function(){
				$S.MP3Player.playNextSong();
			}});
			$(song).html(''+song.originalTitle + ' <span class="position">Loading</span>');
			song.progressInterval = setInterval(function(){
				songObj = song.songObject;
				if(songObj.position){
					var position = $S.MP3Player.msToMinsAndSeconds(songObj.position) + ' / ';
					if(songObj.loaded){
						position += $S.MP3Player.msToMinsAndSeconds(songObj.duration);
					} else {
						position += $S.MP3Player.msToMinsAndSeconds(songObj.durationEstimate);
					}
					$(song).children('.position').html(position);
				}
			}, 1000);
			$S.log('MP3Player: Playing song '+song.href);
		},

		stopSong: function(song) {
			if(song.playing){
				$(song).addClass('mp3player_stopped').removeClass('mp3player_playing');
				this.playingSong = false;
				song.playing = false;
				clearInterval(song.progressInterval);
				$(song).html(song.originalTitle);
				soundManager.stop(song.songID);
				$S.log('MP3Player: Stopping song '+song.href);
			}
		},
	
		toggleSong: function(song) {
			if(this.playingSong && this.playingSong == song){
				this.stopSong(song);
			} else {
				this.playSong(song);
			}
		}
	};	
})(Sugar);