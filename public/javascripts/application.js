Event.observe(window, 'load', function() { 

	// Make the search mode selection box work
	Event.observe($('search_mode'), 'change', function(e) {
		Event.element(e).parentNode.action = Event.element(e).value;
	});

	// Apply magic to compose textarea
	if( $('compose-body') ) {
		var textarea = new Control.TextArea('compose-body');  
		var toolbar = new Control.TextArea.ToolBar(textarea);  
		toolbar.container.id = 'compose-toolbar'; //for css styles  

		//buttons  
		toolbar.addButton('Bold',function(){  
		    this.wrapSelection('<strong>','</strong>');  
		},{  
		    id: 'compose_bold_button'  
		});  

		toolbar.addButton('Italics',function(){  
		    this.wrapSelection('<em>','</em>');  
		},{  
		    id: 'compose_italics_button'  
		});  


		toolbar.addButton('Link',function(){  
		    var selection = this.getSelection();
		    var response = prompt('Enter link URL','');  
		    if(response == null)  
		        return;  
		    this.replaceSelection(
				'<a href="' + 
				(response == '' ? 'http://link_url/' : response).replace(/^(?!(f|ht)tps?:\/\/)/,'http://') +
				'">'+ (selection == '' ? 'Link Text' : selection) + '</a>');
		},{  
		    id: 'compose_link_button'  
		});  

		toolbar.addButton('Image',function(){  
		    var selection = this.getSelection();  
			if( selection == '') {
			    var response = prompt('Enter image URL',''); 
			    if(response == null)  
			        return;  
				this.replaceSelection('<img src="'+response+'" alt="" />');
			} else {
				this.replaceSelection('<img src="'+selection+'" alt="" />');
			}
		},{  
		    id: 'compose_image_button'  
		});  

		/*
		toolbar.addButton('Heading',function(){  
		    var selection = this.getSelection();  
		    if(selection == '')  
		        selection = 'Heading';  
		    this.replaceSelection("\n" + selection + "\n" + $R(0,Math.max(5,selection.length)).collect(function(){'-'}).join('') + "\n");  
		},{  
		    id: 'compose_heading_button'  
		});  
		*/

		//toolbar.addButton('Unordered List',function(event){  
		//    this.collectFromEachSelectedLine(function(line){  
		//        return event.shiftKey ? (line.match(/^\*{2,}/) ? line.replace(/^\*/,'') : line.replace(/^\*\s/,'')) : (line.match(/\*+\s/) ? '*' : '* ') + line;  
		//    });  
		//},{  
		//    id: 'compose_unordered_list_button'  
		//});  

		
		//toolbar.addButton('Ordered List',function(event){  
		//    var i = 0;  
		//    this.collectFromEachSelectedLine(function(line){  
		//        if(!line.match(/^\s+$/)){  
		//            ++i;  
		//            return event.shiftKey ? line.replace(/^\d+\.\s/,'') : (line.match(/\d+\.\s/) ? '' : i + '. ') + line;  
		//        }  
		//    });  
		//},{  
		//    id: 'compose_ordered_list_button'  
		//});  

		toolbar.addButton('Block Quote',function(event){
		    this.wrapSelection('<blockquote>','</blockquote>');  
		},{  
		    id: 'compose_quote_button'  
		});  

		toolbar.addButton('Escape HTML',function(event){
		    var selection = this.getSelection();
		    this.replaceSelection(selection.replace(/</g,'&lt;').replace(/>/g,'&gt;'));
		},{  
		    id: 'compose_escape_button'  
		});  
		

		//toolbar.addButton('Code Block',function(event){  
		//    this.collectFromEachSelectedLine(function(line){  
		//        return event.shiftKey ? line.replace(/    /,'') : '    ' + line;  
		//    });  
		//},{  
		//    id: 'compose_code_button'  
		//});  

		//toolbar.addButton('Help',function(){  
		//    window.open('http://daringfireball.net/projects/markdown/dingus');  
		//},{  
		//    id: 'compose_help_button'  
		//});	
	}

});


