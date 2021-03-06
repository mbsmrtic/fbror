/**
 *  MyToolTip provides a tooltip. The code was originally from http://ashishware.com/js/Tooltip.js 
 *  I modified it, changing the code style and removing functionality that I don't need. 
 *  Here is the original notice from that site: 
// Free for any type of use so long as original notice remains unchanged.
// Report errors to feedback@ashishware.com
//Copyrights 2006, Ashish Patil , ashishware.com
 */
function MyToolTip(id) { 
	var isInit = -1;
  	var div, divWidth, divHeight;
  	var html;
  
  	function Init(id){
       d3.select('div#tooltip')
           .style('background-color', 'white')
           .style('width', '150px')
           .style('height', '70px')
           .style('text-align', 'left')
           .style('font', '10px sans-serif')
           .style('opacity', '0.7')
          .style('border-radius', '5px')
           .style('display', 'none')
           .style('padding-left', '1em');

	   div = document.getElementById(id);
	   if (div == null) return;

	   if((div.style.width=="" || div.style.height=="")) {
	   		alert("Both width and height must be set");
	   		return;
	   }
	   
	   divWidth = parseInt(div.style.width);
	   divHeight= parseInt(div.style.height);
	   if(div.style.overflow!="hidden")div.style.overflow="hidden";
	   if(div.style.display!="none")div.style.display="none";
	   if(div.style.position!="absolute")div.style.position="absolute";
	   if(div.style.color!="black")div.style.color="black";
	        
	   isInit++;
       return this
  	}
	this.Show = function(e,strHTML) {
		if(isInit<0) return;
	    
	    var newPosx,newPosy,height,width;
	    if(typeof( document.documentElement.clientWidth ) == 'number' ){
		    width = document.body.clientWidth;
		    height = document.body.clientHeight;}
	    else {
		    width = parseInt(window.innerWidth);
		    height = parseInt(window.innerHeight);
	    }
	    var curPosx = (e.x)?parseInt(e.x):parseInt(e.clientX);
	    var curPosy = (e.y)?parseInt(e.y):parseInt(e.clientY);
	    
	    if(strHTML!=null){
	    	html = strHTML;
	     	div.innerHTML=html;
	    }

        //don't let the tooltip go off the right side
        //  if we're at the right side, move the tooltip
        //  to the left of the mouse
	    if((curPosx+divWidth+10)< width)
	    	newPosx= curPosx+10;
	    else
	    	newPosx = curPosx-divWidth;
	
	    if((curPosy - divHeight - 10) > 0)
	    	newPosy= curPosy + 10;
	    else
	    	newPosy = curPosy + divHeight + 20;
	
		if(window.pageYOffset){
	   		newPosy= newPosy+ window.pageYOffset;
	     	newPosx = newPosx + window.pageXOffset;
	   	}
	   	else {
	   		newPosy= newPosy+ document.body.scrollTop;
	     	newPosx = newPosx + document.body.scrollLeft;
	   	}

        newPosy = newPosy - divHeight- 20;

	   	div.style.display='block';
	   	div.style.top= newPosy + "px";
	   	div.style.left= newPosx+ "px";
	
	   	div.focus();
	}; 

	this.Hide= function(e) {
    	div.style.display='none';
   	};
    
  	this.SetHTML = function(strHTML) {
   		html = strHTML;
    	div.innerHTML=html;
   	}; 
   	
   	retvalue = Init(id);
    return retvalue;
}


