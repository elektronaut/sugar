$.extend(Sugar.Initializers, {
	applySubmitMagic: function(){
		$("#replyText form").submit(function(){
			return Sugar.parseSubmit(this);
		});
	}
});

$.extend(Sugar, {

	// ---- Posting ----

	// parseSubmit() reads the contents of the posting textarea and applies it to a hidden div.
	// If there are any images, parseSubmit() will attempt to load them and update the post body
	// with proper width/height attributes. 
	parseSubmit : function(submitForm){
		var statusField = $('#button-container');
		$('#button-container').each(function(){
			if(!this.originalButton){
				this.originalButton = $(this).html();
			}
		});
		var oldPostButton = statusField.html();

		statusField.addClass('posting');
		statusField.html('Validating post..');

		var postBody = $('#compose-body').val();

		if($('#hiddenPostVerifier').length < 1) {
			$(document.body).append('<div id="hiddenPostVerifier"></div>');
		}
		var postNotifier = $('#hiddenPostVerifier');
		postNotifier.show();
		postNotifier.html(postBody);
		postNotifier.hide();

		var postImages = postNotifier.find('img');
		var loadedImages = Array();
		if(postImages.length > 0) {

			// Async loading event
			postImages.each(function(){
				$(this).load(function(){
					loadedImages.push(this);
				});
			});

			// Check loading of images
			postNotifier.cycles = 0;
			postNotifier.loadInterval = setInterval(function(){
				postNotifier.cycles += 1;
				statusField.html('Loading image '+loadedImages.length+' of '+postImages.length+'..');

				// Load failed
				if(postNotifier.cycles >= 80) {
					clearInterval(postNotifier.loadInterval);
					if(confirm("One or more of your images timed out. Post anyway?")) {
						$(loadedImages).each(function(){
							$(this).attr('height', this.height);
							$(this).attr('width', this.width);
						});
						$('#compose-body').val(postNotifier.html());
						statusField.html('Saving post...');
						Sugar.submitPost();
					} else {
						statusField.html(oldPostButton);
						statusField.removeClass('posting');
					}
				}

				// All images loaded
				if(loadedImages.length == postImages.length) {
					postImages.each(function(){
						$(this).attr('height', this.height);
						$(this).attr('width', this.width);
					});
					$('#compose-body').val(postNotifier.html());
					clearInterval(postNotifier.loadInterval);
					statusField.html('Saving post...');
					Sugar.submitPost();
				}
			}, 100);
			return false;
		} else {
			Sugar.submitPost();
			return false;
		}
	},

	// Submits post via AJAX if supported. 
	submitPost : function(){
		$("#replyText form").each(function(){
			var submitForm = this;
			var statusField = $('#button-container');
			statusField.addClass('posting');
			statusField.html('Posting, please wait..');
			if($(submitForm).hasClass('livePost')){
				var postBody = $('#compose-body').val();
				$.ajax({
					url:  submitForm.action,
					type: 'POST',
					data: {
						'post[body]': postBody,
						authenticity_token: $(this).find("input[name='authenticity_token']").val()
					},
					success: function(){
						$('#compose-body').val('');
						Sugar.loadNewPosts();
					},
					error: function(xhr, textStatus, errorThrown){
						alert(textStatus);
						if(postBody === ""){
							alert("Your post is empty!");
						} else {
							if(textStatus == 'timeout'){
								alert('Error: The request timed out.');
							} else {
								alert('There was a problem validating your post.');
							}
						}
					},
					complete: function(){
						statusField.each(function(){
							$(this).removeClass('posting');
							$(this).html(this.originalButton);
						});
					}
				});
			} else {
				submitForm.submit();
			}
		});
	}
});