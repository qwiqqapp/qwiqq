console.log('starting...');
var tfb={};
tfb.allowedLabels=["follow-me","follow-us","follow","my-twitter"];
tfb.defaultTop=78;
tfb.defaultColor="#35ccff";
tfb.isInArray=function(str,ar){
  if(ar.length<1)return;
  for(var i=0;i<ar.length;i++){if(ar[i]==str){return true;break;}}
  return false;
}
tfb.showbadge=function(){
  console.log('showbadge');
  if(!window.XMLHttpRequest){
    return;
  }
  if(document.getElementById('twitterFollowBadge')){
    document.body.removeChild(document.getElementById('twitterFollowBadge'));
  }
  if(tfb.top<0||tfb.top>1000||isNaN(tfb.top)){
    tfb.top=tfb.defaultTop;
  }
  if(!tfb.isInArray(tfb.label,tfb.allowedLabels)){
    tfb.label=tfb.allowedLabels[0];
  }
  var validColorPattern=/^#([a-f]|[A-F]|[0-9]){3}(([a-f]|[A-F]|[0-9]){3})?$/;
  if(!validColorPattern.test(tfb.color)||(tfb.color.length!=4&&tfb.color.length!=7)){
    tfb.color=tfb.defaultColor;
  };
  if(tfb.side!='l'){
    tfb.side='r';
  }
  
  var newURL = '/';
  var imageUrl = 'http://qwiqq.me/assets/consumers-2.png';
  if(window.location.pathname==='/'){
    newURL = '/merchants';
    imageUrl = 'http://qwiqq.me/assets/merchants-2.png';
  }
  
  tfb.tabStyleCode='position:fixed;'
    +'top:'+tfb.top+'px;'
    +'width:59px;'
    +'height:162px;'
    +'z-index:8765;'
    +'cursor:pointer;'
    +'background:url(' + imageUrl + ');'
    +'background-repeat:no-repeat;';
 if(tfb.side=='l'){
    tfb.tabStyleCode+='left:0; background-position:right top;';
  } else {
    tfb.tabStyleCode+='right:0; background-position:left top;';tfb.aboutStyleCode+='right:0;';
  }
  tfbMainDiv=document.createElement('div');
  tfbMainDiv.setAttribute('id','twitterFollowBadge');
  document.body.appendChild(tfbMainDiv);

  
  
  tfbMainDiv.innerHTML='<div id="tfbTab" style="'+tfb.tabStyleCode+
    '"></div><div id="tfbAbout" style="'+tfb.aboutStyleCode+'"></div>';
    
    console.log('badge shown');
  document.getElementById('tfbTab').onclick=function(){
    window.open(newURL,'_self');
  }
}

$(document).ready(function(){
  tfb.label = 'my-twitter';
  tfb.color = '#D76816';
  tfb.side = 'r';
  tfb.top = 150;
  tfb.showbadge();
});


