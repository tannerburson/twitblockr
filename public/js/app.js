jQuery.fn.center = function(params) {

		var options = {

			vertical: true,
			horizontal: true

		}
		op = jQuery.extend(options, params);

   return this.each(function(){

		//initializing variables
		var $self = jQuery(this);
		//get the dimensions using dimensions plugin
		var width = $self.width();
		var height = $self.height();
		//get the paddings
		var paddingTop = parseInt($self.css("padding-top"));
		var paddingBottom = parseInt($self.css("padding-bottom"));
		//get the borders
		var borderTop = parseInt($self.css("border-top-width"));
		var borderBottom = parseInt($self.css("border-bottom-width"));
		//get the media of padding and borders
		var mediaBorder = (borderTop+borderBottom)/2;
		var mediaPadding = (paddingTop+paddingBottom)/2;
		//get the type of positioning
		var positionType = $self.parent().css("position");
		// get the half minus of width and height
		var halfWidth = (width/2)*(-1);
		var halfHeight = ((height/2)*(-1))-mediaPadding-mediaBorder;
		// initializing the css properties
		var cssProp = {
			position: 'absolute'
		};

		if(op.vertical) {
			cssProp.height = height;
			cssProp.top = '50%';
			cssProp.marginTop = halfHeight;
		}
		if(op.horizontal) {
			cssProp.width = width;
			cssProp.left = '50%';
			cssProp.marginLeft = halfWidth;
		}
		//check the current position
		if(positionType == 'static') {
			$self.parent().css("position","relative");
		}
		//aplying the css
		$self.css(cssProp);


   });

};

$(document).ready(function(){
  function mask() {
        var maskHeight = $(document).height();  
        var maskWidth = $(window).width();  
      
        //Set height and width to mask to fill up the whole screen  
        $('#mask').css({'width':maskWidth,'height':maskHeight,'top':0});  
          
        //transition effect       
        $('#mask').fadeIn(1000);      
        $('#mask').fadeTo("slow",0.8);    
  }
  var id;
  $.ajaxPollSettings.pollingtype = "timed";
  $.ajaxPollSettings.interval = "2000";
  $('#frm_login > .button').click(function(){
	$.getJSON('/list',
	  {username: $('#login_username').val()}, function(data){
		  id = data;
		  mask();
		  $('#loading').center();
		  $('#loading').fadeIn(2000);
		  $.ajaxPoll({
		  url: "/status/" + id,
		  type: "GET",
		  successCondition: function(result) {
			  return result == "true";
		  },
		  success: function(data) {
			  window.location.href += '/results/' + id;
		  }
	  });
	},'json');
  });
});
