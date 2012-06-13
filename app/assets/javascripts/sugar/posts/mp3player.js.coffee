soundManager.debugMode = false
soundManager.url = "/flash/soundmanager2"

$(Sugar).bind "ready postsloaded", ->
  @MP3Player.detectSongs()

Sugar.MP3Player =
  songs: []
  playingSong: false
  detectSongs: ->
    detectedSongs = 0
    $("a.mp3player").each ->
      detectedSongs += 1  if Sugar.MP3Player.applyToLink(this)

    Sugar.log "MP3Player: Detected " + detectedSongs + " new songs."  if detectedSongs > 0

  applyToLink: (link) ->
    unless link.songID
      link.songID = "song-" + (Sugar.MP3Player.songs.length + 1)
      link.originalTitle = $(link).html()
      $(link).addClass "mp3player_stopped"
      $(link).click ->
        Sugar.MP3Player.toggleSong this
        false

      @songs[@songs.length] = link
      return link
    false

  msToMinsAndSeconds: (ms) ->
    minutes = Math.floor(ms / 60000)
    seconds = Math.floor((ms - (minutes * 60000)) / 1000)
    seconds = "0" + seconds  if seconds < 10
    minutes + ":" + seconds

  stopAllSongs: ->
    $(@songs).each ->
      Sugar.MP3Player.stopSong this

  playNextSong: ->
    index = false
    a = 0

    while a < @songs.length
      index = a  if @songs[a] is @playingSong
      a += 1
    index += 1
    index = 0  if index >= @songs.length
    @playSong @songs[index]

  playSong: (song) ->
    @stopAllSongs()
    $(song).addClass("mp3player_playing").removeClass "mp3player_stopped"
    @playingSong = song
    song.playing = true
    song.songObject = soundManager.createSound(
      id: song.songID
      url: song.href
    )
    soundManager.play song.songID,
      onfinish: ->
        Sugar.MP3Player.playNextSong()

    $(song).html "" + song.originalTitle + " <span class=\"position\">Loading</span>"
    song.progressInterval = setInterval(->
      songObj = song.songObject
      if songObj.position
        position = Sugar.MP3Player.msToMinsAndSeconds(songObj.position) + " / "
        if songObj.loaded
          position += Sugar.MP3Player.msToMinsAndSeconds(songObj.duration)
        else
          position += Sugar.MP3Player.msToMinsAndSeconds(songObj.durationEstimate)
        $(song).children(".position").html position
    , 1000)
    Sugar.log "MP3Player: Playing song " + song.href

  stopSong: (song) ->
    if song.playing
      $(song).addClass("mp3player_stopped").removeClass "mp3player_playing"
      @playingSong = false
      song.playing = false
      clearInterval song.progressInterval
      $(song).html song.originalTitle
      soundManager.stop song.songID
      Sugar.log "MP3Player: Stopping song " + song.href

  toggleSong: (song) ->
    if @playingSong and @playingSong is song
      @stopSong song
    else
      @playSong song
