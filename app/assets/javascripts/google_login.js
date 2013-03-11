function login(login_url, test_url, redirect_url) {
  var left = (screen.width/2)-(640/2);
  var top = (screen.height/2)-(480/2);
  var win = window.open(login_url, "googlelogin", 'width=700, height=480, left='+left+', top='+top); 
  var pollTimer   =   window.setInterval(function() { 
	if (win.document.URL.indexOf(test_url) != -1) {
	    window.clearInterval(pollTimer);
	    win.close();

	    window.location = redirect_url;
	}
  }, 500);
}

