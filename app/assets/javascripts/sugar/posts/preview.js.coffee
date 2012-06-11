$(Sugar).bind 'ready', ->

  original_post_buttons = null

  previewPost = ->

    post_body      = $("#compose-body").val()
    preview_url    = $("#discussionLink").get()[0].href.match(/^(https?:\/\/[\w\d\.:]+\/discussions\/[\d]+)/)[1] + "/posts/preview"
    status_field   = $("#button-container")
    original_post_buttons ||= status_field.html()

    status_field.addClass "posting"
    status_field.html "Previewing post.."

    $(".posts #previewPost").animate opacity: 0.1, 'fast'
    $.ajax
      url: preview_url
      type: "POST"
      data:
        "post[body]": post_body
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

      error: (xhr, textStatus, errorThrown) ->
        alert textStatus

      complete: ->
        status_field.each ->
          $(this).removeClass "posting"
          $(this).html original_post_buttons
          $(this).find(".preview span").text "Update Preview"
          $('#replyText .preview').click ->
            previewPost()

  $('#replyText .preview').click ->
    previewPost()
