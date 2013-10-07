$(Sugar).bind 'ready', ->

  original_post_buttons = null

  previewPost = ->

    post_body      = $("#compose-body").val()
    format         = $("#compose-body").closest('form').find('.format').val()
    preview_url    = $("#discussionLink").get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/preview"

    $(Sugar).trigger 'posting-status', ['Loading preview&hellip;']

    $(".posts #previewPost").animate opacity: 0.1, 'fast'
    $.ajax
      url: preview_url
      type: "POST"
      data:
        "post[body]": post_body
        "post[format]": format
        authenticity_token: Sugar.authToken("#replyText form")

      success: (previewPost) ->
        # Inject the #ajaxPosts container so new posts
        # will be loaded above the prewview
        if $(".posts #ajaxPosts").length < 1
          $(".posts").append "<div id=\"ajaxPosts\"></div>"

        # Create the container
        if $(".posts #previewPost").length < 1
          $(".posts").append "<div id=\"previewPost\"></div>"

        $(".posts #previewPost").html(previewPost)

        # Animation
        if $(".posts #previewPost").hasClass('shown')
          $(".posts #previewPost").animate opacity: 1.0, 'fast'
        else
          $(".posts #previewPost").addClass('shown').hide().fadeIn()

        $(Sugar).trigger 'postsloaded', [$(".posts #previewPost").find('.post')]

      error: (xhr, textStatus, errorThrown) ->
        alert textStatus

      complete: ->
        $(Sugar).trigger 'posting-complete'

  $('#replyText .preview').click ->
    previewPost()
