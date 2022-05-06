<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    
<c:import url="/WEB-INF/views/layout/header.jsp" />
<!DOCTYPE html>
<html>

<!-- jQuery 2.2.4 -->

<script type="text/javascript" src="https://code.jquery.com/jquery-2.2.4.min.js"></script>
<!-- SOCKJS -->
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.0/sockjs.min.js"></script>
<!-- STOMP -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<!-- BOOTSTRAP -->
 <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
 <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
 
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-YcbK69I5IXQftf/mYD8WY0/KmEDCv1asggHpJk1trM8=" crossorigin="anonymous"></script>
    
   

    <style>
        .chat_wrap { border:3px solid #999; padding:5px; font-size:13px; color:#333}
        .chat_wrap .inner{background-color:#acc2d2; border-radius:5px; padding:10px; overflow-y:scroll;height: 400px;}
        .chat_wrap .item{margin-top:15px}
        .chat_wrap .item:first-child{margin-top:0px}
        .chat_wrap .item .box{ max-width:none; position:initial}
        .chat_wrap .item .box::before{content:""; position:absolute; left:-8px; top:9px; border-top:0px solid transparent; border-bottom:8px solid transparent;border-right:8px solid #fff;}
        .chat_wrap .item .box .msg {background:#fff; border-radius:10px; padding:8px; text-align:left}
        .chat_wrap .item .box .time {font-size:11px; color:#999; position:inherit; padding-left:5px; right: -75px; bottom:5px; width:70px}
        .chat_wrap .item .mymsg{text-align:right}
        .chat_wrap .item .mymsg .box::before{left:auto; right:-8px; border-left:8px solid #fee600; border-right:0;}
        .chat_wrap .item .mymsg .box .msg{background:#fee600}
        .chat_wrap .item .mymsg .box .time{right:auto; left:-75px}
        .chat_wrap .item .box{transition:all .3s ease-out; margin:0 0 0 20px;opacity: 7}
        .chat_wrap .item .mymsg .box{transition:all .3s ease-out; margin:0 20px 0 0;}
        .chat_wrap .item.on .box{margin:0; opacity: 1;}

        input[type="text"]{border:0; width:85%;background:#ddd; border-radius:5px; height:30px; padding-left:5px; box-sizing:border-box; margin-top:5px}
        input[type="text"]::placeholder{color:#999}
  
		.btn-primary { 
		  background-color: #99CC66;
		  display: inline-block;
		  margin: auto 0;
		  border: 0;
		 
		   }
		   
     .modal-backdrop {
       z-index: -1;
 	  }   
  
    </style>

<script type="text/javascript">

$(document).ready(function(){
	//웹소켓 설정을 위한 준비 작업 
	//const username = ${sessionScope.testuser}
	var username ="${testuser}"
	var namelength = username.length;
	console.log(username)
	var msg = $("#messages");
	console.log(msg.val())
	
 	if(username==null){
	alart('로그인되지 않았습니다')	
	}
	
	//-----------------------------------------
	// 클라이언트 소켓 만들기
	var sockJS = new SockJS("/chat")
	var stomp = Stomp.over(sockJS);
	

   var roomId = '${roomId}';
   
	stomp.connect({},function(){
		console.log("stomp 호출" + roomId)
		//subscribe(path, callback)
		stomp.subscribe("/sub/chat/room11"+roomId, function(chat){
  		   var content = JSON.parse(chat.body)
			var chatLog = content.chatLog
			var writer = content.userid;
	 		var message = content.chatLog
			var str = writer + ":" + message 
			console.log(chatLog)

            if(writer === username){
                str = "<div class=' item box msg'>";
                str += "<div class='mymsg box'>";
                str +=  writer + " : " + message 
                str += "<span class='time'>"
                str += currentTime()
                str += "</span>";
                str += "</div></div></div></div>";
                $("#inner").append(str);
            }
            else{
            	   str = "<div class=' item box '>";
                   str += "<div class='msg box'>";
                   str +=  writer + " : " + message 
                   str += "<span class='time'>"
                   str += currentTime()
                   str += "</span>";
                   str += "</div></div></div></div>";
                   $("#inner").append(str);
            }

			console.log("chat"+str)
		})//subscribe end
		
		//send(path, header, message)
		stomp.send('/pub/chat/enter11', {}, 
				JSON.stringify({roomId: roomId, 
					userid: username,
					chatLog: '입장'
					}))
		
	})//connect end
	
    
    var currentTime = function(){
        var date = new Date();
        var hh = date.getHours();
        var mm = date.getMinutes();
        var apm = hh >12 ? "오후":"오전";
        var ct = apm + " "+hh+":"+mm+"";
        return ct;
    }
	

	//퇴장
	function onClose(e){
//		clearInterval(websocket.interval);
		$.ajax({
			url: "/chat/exit11",
			type: "get",
			data: {roomId: roomId, username:username},
			success: console.log("session deleted") ,
			error:	console.log("session delete error")
		})
		console.log("onClose()")
		window.location.replace("/main")
	}
	
	 function onError(e){
		console.log("onError()")
		alart('에러가 발생하였습니다')
		history.go(-1)
	} 
		
// 		----------------------
//DOM 요소들의 동작


	 $("#sendButton").click(function(e){
		 var msg = $("#messages")
		 console.log("messages "+msg)
         stomp.send('/pub/chat/message11', {}, 
 				JSON.stringify({roomId: roomId, 
 					userid: username,
 					chatLog: msg.val()
 					}))
         msg.value = '';
	 })
	 
	  $("#disconn").click(function(){
		function pro1(){
			stomp.send('/pub/chat/exit11', {}, 
					JSON.stringify({roomId: roomId, 
						userid: username,
						chatLog: '퇴장'
						}))
			console.log("here1")
		}
		
		
		function pro2(){
			console.log("here2")
			
			 $.ajax({
					url: "/chat/logdown",
					type: "post",
					async: false,
					data:{userid:username, roomId:roomId}, //username은 위에서 선언한 var 
// 					dataType: "json",
	                success: function (data) {
	                    var blob = new Blob([data], { type: "application/octet-stream" });
	 					var fileName = "ChatLog.txt";
	 					
	                    var isIE = false || !!document.documentMode;
	                    if (isIE) {
	                        window.navigator.msSaveBlob(blob, fileName);
	                    } else {
	                        var url = window.URL || window.webkitURL;
	                        link = url.createObjectURL(blob);
	                        
	                        var a = $("<a />");
	                        a.attr("download", fileName);
	                        a.attr("href", link);
	                        
	                        $("body").append(a);
	                        a[0].click();
	                        a.remove();
	                    }
	                    pro3()
	                }
					,error:function(){
						console.log("저장실패")
						pro3();
					}
					 })
		}
			 
		function pro3() {
			console.log("here3")
			if (typeof window !== 'undefined') { alert('채팅을 종료합니다.') }
			onClose();	// 개발 위해 잠시 주석 처리
}

		
		if(!confirm("저장?")){ // 저장안함
			forcheckSaveDiv.click() 
		} else { // 저장함 
			pro1();
			pro2();
	    	onClose();
		}		
	 
	  })//disconn end
	
	  $("#forcheckSaveDiv").click(function(){
          		if (confirm("종료?")){ //종료함
     		    	onClose();
          		}
	  })	
	  
	var ckpart = function(){
					$.ajax({
						url:"/chat/participant",
						type:"post",
						data:{roomId:roomId},
						success:function(list){
						console.log("성공");
							for(var i=0; i<list.length; i++){
								var participant = list[i]
				 				console.log("참여자명 "+participant)
								$("#participants").html(participant)
							}
						},
						error:function(result){
						console.log("에러");
							$('#participants').val('error')
						}
					})
				}
	$("#checkparts").click(ckpart)
	
	
})

</script>


<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<div style="text-align: center; padding: 0.5em; background-color:#99CC66; font-size: 1.5em; font: bolder;">
<label>[OnLine] ${roomId} 님의 문의 채팅 </label>
</div>

<div class="chat_wrap">
	<div id="inner" class="inner">
	</div>
</div>
<div>
		<input type="text" id="messages" placeholder="메시지를 입력하세요.">
		<button type="button" id="sendButton" style="width: 10%; padding: 0 0" >전송</button>
</div>

<div style="height: 1.3em">
</div>
<div style="text-align: center">
	<button type="button" class="btn btn-primary" id="disconn" >대화방 나가기</button>
	<div id="participants"></div>
</div>		
<div style="height: 2em">
</div>
		

</body>
</html>