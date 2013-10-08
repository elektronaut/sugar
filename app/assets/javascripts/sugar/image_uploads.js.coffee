$(Sugar).bind 'ready modified', ->

  $('#compose-body').filedrop
    allowedfiletypes: ['image/jpeg', 'image/png', 'image/gif']
    maxfiles: 25
    maxfilesize: 2
    beforeSend: (file, i, done, e) ->
      return false
    uploadStarted: ->
      console.log 'starting upload'
    uploadFinished: ->
      console.log 'finished uploading'

