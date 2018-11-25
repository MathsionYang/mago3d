<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/taglib.jsp" %>
<%@ include file="/WEB-INF/views/common/config.jsp" %>

<!DOCTYPE html>
<html lang="${accessibility}">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width">
	<title>main | mago3D User</title>
	<link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />
	<link rel="stylesheet" href="/css/cloud.css?cache_version=${cache_version}">
	<link rel="stylesheet" href="/css/fontawesome-free-5.2.0-web/css/all.min.css">
<c:if test="${geoViewLibrary == null || geoViewLibrary eq '' || geoViewLibrary eq 'cesium' }">
	<link rel="stylesheet" href="/externlib/cesium/Widgets/widgets.css?cache_version=${cache_version}" />
</c:if>
	<link rel="stylesheet" href="/externlib/jquery-ui/jquery-ui.css" />
	<link rel="stylesheet" href="/externlib/jquery-toast/jquery.toast.css" />
	<link rel="stylesheet" href="/css/${lang}/font/font.css" />
	<link rel="stylesheet" href="/images/${lang}/icon/glyph/glyphicon.css" />
	
	<script type="text/javascript" src="/externlib/jquery/jquery.js"></script>
	<script type="text/javascript" src="/externlib/jquery-ui/jquery-ui.js"></script>
	<script type="text/javascript" src="/js/cloud.js?cache_version=${cache_version}"></script>
	<script type="text/javascript" src="/externlib/jquery-toast/jquery.toast.js"></script>
	<style type="text/css">
		#objectLabel {
			position:absolute;left:0px;top:0px; z-index: 999; pointer-events: none;
		}
	</style>
</head>
<body>

<div class="site-body">
	<%@ include file="/WEB-INF/views/layouts/header.jsp" %>
	<div id="site-content" class="on">
		<%@ include file="/WEB-INF/views/layouts/menu.jsp" %>
		<div id="content-wrap">
			<div id="magoContainer" style="height: 700px;"></div>
			<canvas id="objectLabel"></canvas>
		</div>
	</div>
	<%-- <%@ include file="/WEB-INF/views/layouts/footer.jsp" %> --%>
</div>
<c:if test="${geoViewLibrary == null || geoViewLibrary eq '' || geoViewLibrary eq 'cesium' }">
<script type="text/javascript" src="/externlib/cesium/Cesium.js?cache_version=${cache_version}"></script>
</c:if>
<c:if test="${geoViewLibrary eq 'worldwind' }">
<script type="text/javascript" src="/externlib/webworldwind/worldwind.js?cache_version=${cache_version}"></script>
</c:if>
<script type="text/javascript" src="/js/mago3d.js?cache_version=${cache_version}"></script>
<script type="text/javascript" src="/js/${lang}/common.js"></script>
<script type="text/javascript" src="/js/${lang}/message.js"></script>
<script>
	console.log("---------------- window.innerHeight = " + window.innerHeight);
	var mapSize = window.innerHeight - 67;
	console.log("---------------- map size = " + mapSize);
	$("#magoContainer").css("height", mapSize);

	var agent = navigator.userAgent.toLowerCase();
	if(agent.indexOf('chrome') < 0) { 
		alert(JS_MESSAGE["demo.browser.recommend"]);
	}

	var managerFactory = null;
	var policyJson = ${policyJson};
	var initProjectJsonMap = ${initProjectJsonMap};
	var menuObject = { 	homeMenu : false, myIssueMenu : false, searchMenu : false, apiMenu : false, insertIssueMenu : false, 
						treeMenu : false, chartMenu : false, logMenu : false, attributeMenu : false, configMenu : false };
	var insertIssueEnable = false;
	var FPVModeFlag = false;
	
	var imagePath = "/images/${lang}";
	var dataInformationUrl = "/data/ajax-project-data-by-project-id.do";
	magoStart();
	var intervalCount = 0;
	var timerId = setInterval("startMogoUI()", 1000);
	
	$(document).ready(function() {
	});
	
	function startMogoUI() {
		intervalCount++;
		if(managerFactory != null && managerFactory.getMagoManagerState() === CODE.magoManagerState.READY) {
			initJqueryCalendar();
			// Label 표시
			changeLabel(false);
			// object 정보 표시
			changeObjectInfoViewMode(true);
			// Origin 표시
            changeOrigin(false);
			// BoundingBox
			changeBoundingBox(false);
			// Selecting And Moving
			changeObjectMove("2");
			// slider, color-picker
			initRendering();
			// 3PView Mode
			changeViewMode(false);
			
			clearInterval(timerId);
			console.log(" managerFactory != null, managerFactory.getMagoManagerState() = " + managerFactory.getMagoManagerState() + ", intervalCount = " + intervalCount);
			return;
		}
		console.log("--------- intervalCount = " + intervalCount);
	}
	
	// mago3d 시작, 정책 데이터 파일을 로딩
	function magoStart() {
		var initProjectsLength = ${initProjectsLength};
		if(initProjectsLength === null || initProjectsLength === 0) {
			managerFactory = new ManagerFactory(null, "magoContainer", policyJson, null, null, null, imagePath);
		} else {
			var projectIdArray = new Array(initProjectsLength);
			var projectDataArray = new Array(initProjectsLength);
			var projectDataFolderArray = new Array(initProjectsLength);
			var index = 0;
			for(var projectId in initProjectJsonMap) {
				projectIdArray[index] = projectId;
				var projectJson = JSON.parse(initProjectJsonMap[projectId]);
				projectDataArray[index] = projectJson;
				projectDataFolderArray[index] = projectJson.data_key;
				index++;
			}
			
			managerFactory = new ManagerFactory(null, "magoContainer", policyJson, projectIdArray, projectDataArray, projectDataFolderArray, imagePath);			
		}
	}
	
	// 프로젝트를 로딩한 후 이동
	function gotoProject(projectId, longitude, latitude, height, duration) {
		var projectData = getDataAPI(CODE.PROJECT_ID_PREFIX + projectId);
		if (projectData === null || projectData === undefined) {
			$.ajax({
				url: dataInformationUrl,
				type: "POST",
				data: "project_id=" + projectId,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						var projectDataJson = JSON.parse(msg.projectDataJson);
						if(projectDataJson === null || projectDataJson === undefined) {
							alert(JS_MESSAGE["project.data.no.found"]);
							return;
						}
						gotoProjectAPI(managerFactory, projectId, projectDataJson, projectDataJson.data_key, longitude, latitude, height, duration);
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
					console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
				}
			});
		} else {
			gotoProjectAPI(managerFactory, projectId, projectData, projectData.data_key, longitude, latitude, height, duration);	
		}
		
		// 현재 좌표를 저장
		saveCurrentLocation(latitude, longitude);
	}
	
	// 이슈 위치로 이동
	function gotoIssue(projectId, issueId, issueType, longitude, latitude, height, duration) {
		var projectData = getDataAPI(CODE.PROJECT_ID_PREFIX + projectId);
		if (projectData === null || projectData === undefined) {
			$.ajax({
				url: dataInformationUrl,
				type: "POST",
				data: "project_id=" + projectId,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						var projectDataJson = JSON.parse(msg.projectDataJson);
						if(projectDataJson === null || projectDataJson === undefined) {
							alert(JS_MESSAGE["project.data.no.found"]);
							return;
						}
						gotoIssueAPI(managerFactory, projectId, projectDataJson, projectDataJson.data_key, issueId, issueType, longitude, latitude, height, duration);
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
					console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
				}
			});
		} else {
			gotoIssueAPI(managerFactory, projectId, projectData, projectData.data_key, issueId, issueType, longitude, latitude, height, duration);	
		}
		
		// 현재 좌표를 저장
		saveCurrentLocation(latitude, longitude);
	}
	
	// issue 위치 버튼을 클릭 했을 경우
	$("#insertIssueEnableButton").click(function() {
		if(insertIssueEnable) {
			$("#insertIssueEnableButton").removeClass("on");
			$("#insertIssueEnableButton").text(JS_MESSAGE["demo.select.object.message"]);
			insertIssueEnable = false;
		} else {
			$("#insertIssueEnableButton").addClass("on");
			$("#insertIssueEnableButton").text(JS_MESSAGE["demo.issue.enable.status"]);
			insertIssueEnable = true;
		}
		changeInsertIssueModeAPI(managerFactory, insertIssueEnable);
	});
	
	// issue input layer call back function
	function showInsertIssueLayer(projectId, dataKey, objectKey, latitude, longitude, height) {
		if(insertIssueEnable) {
			$("#issueProjectId").val(projectId);
			$("#data_key").val(dataKey);
			$("#object_key").val(objectKey);
			$("#latitude").val(latitude);
			$("#longitude").val(longitude);
			$("#height").val(height);
			
			// 현재 좌표를 저장
			saveCurrentLocation(latitude, longitude);
		}
	}
	
	// 이슈 등록
	var isInsertIssue = true;
	$("#issueSaveButton").click(function() {
		if (check() == false) {
			return false;
		}
		if(isInsertIssue) {
			isInsertIssue = false;
			var url = "/issue/ajax-insert-issue.do";
			var info = $("#issue").serialize() + "&project_id=" + $("#issueProjectId").val();
			$.ajax({
				url: url,
				type: "POST",
				data: info,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						alert(JS_MESSAGE["insert"]);
						// pin image를 그림
						drawInsertIssueImageAPI(managerFactory, 1, msg.issue.issue_id, msg.issue.issue_type, 
								$("#data_key").val(), $("#latitude").val(), $("#longitude").val(), $("#height").val());
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
					
					isInsertIssue = true;
					ajaxIssueList();
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
					console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
					isInsertIssue
				}
			});
			
			// issue 등록 버튼, css, 상태를 변경
			$("#insertIssueEnableButton").removeClass("on");
			$("#insertIssueEnableButton").text(JS_MESSAGE["demo.select.object.message"]);
			insertIssueEnable = false;
			
			changeInsertIssueStateAPI(managerFactory, 0);
		} else {
			alert(JS_MESSAGE["button.dobule.click"]);
			return;
		}
	});
	
	function check() {
		if ($("#data_key").val() === "") {
			alert(JS_MESSAGE["issue.datakey.empty"]);
			$("#data_key").focus();
			return false;
		}
		if ($("#title").val() === "") {
			alert(JS_MESSAGE["issue.title.empty"]);
			$("#title").focus();
			return false;
		}
		if ($("#contents").val() === "") {
			alert(JS_MESSAGE["issue.contents.empty"]);
			$("#contents").focus();
			return false;
		}
	}
	
	// TODO issue url 밑에 있어야 할지도 모르겠다.
	function ajaxIssueList() {
		var info = "";
		var url = "/homepage/ajax-list-issue.do";
		$.ajax({
			url: url,
			type: "POST",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					var issueRecentList10Message = "<spring:message code='issue.recent.list.10'/>";
					var issueDoesNotExistMessage = "<spring:message code='issue.not.exist'/>";
					var commonShortcutMessage = "<spring:message code='shortcut'/>";
					
					var issueList = msg.issueList;
					var content = "";
					var issueListCount = 0;
					content = content 
						+	"<li style=\"margin-bottom: 8px; font-size: 1em; font-weight: normal; color: #2955a6;\">"
						+ 		issueRecentList10Message
						+	"</li>";
					if(issueList === null || issueList.length === 0) {
						content += 	"<li style=\"text-align: center; padding-top:20px; height: 50px;\">"
								+	issueDoesNotExistMessage
								+	"</li>";
					} else {
						issueListCount = issueList.length;
						for(i=0; i<issueListCount; i++ ) {
							var issue = issueList[i];
							content = content 
								+ 	"<li>"
								+ 	"	<button type=\"button\" title=\"" + commonShortcutMessage + "\""
								+			"onclick=\"gotoIssue('" + issue.project_id + "', '" + issue.issue_id + "', '" + issue.issue_type + "', '" 
								+ 				issue.longitude + "', '" + issue.latitude + "', '" + issue.height + "', '2')\">" + commonShortcutMessage + "</button>"
								+ 	"	<div class=\"info\">"
								+ 	"		<p class=\"title\">"
								+ 	"			<span>" + issue.project_name + "</span>"
								+ 				issue.title
								+ 	"		</p>"
								+ 	"		<ul class=\"tag\">"
								+ 	"			<li><span class=\"" + issue.issue_type_css_class + "\"></span>" + issue.issue_type_name + "</li>"
								+ 	"			<li><span class=\"" + issue.priority_css_class + "\"></span>" + issue.priority_name + "</li>"
								+ 	"			<li class=\"date\">" + issue.insert_date.substring(0,19) + "</li>"
								+ 	"		</ul>"
								+ 	"	</div>"
								+ 	"</li>";
						}
					}
					$("#issueListCount").empty();
					$("#issueListCount").html(msg.totalCount);
					$("#myIssueMenuContent").empty();
					$("#myIssueMenuContent").html(content);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
	
	// 왼쪽 메뉴 클릭시 ui 처리
	$("#homeMenu").click(function() {
		menuSlideControl("homeMenu");
	});
	$("#myIssueMenu").click(function() {
		menuSlideControl("myIssueMenu");
	});
	$("#searchMenu").click(function() {
		menuSlideControl("searchMenu");
	});
	$("#apiMenu").click(function() {
		menuSlideControl("apiMenu");
	});
	$("#insertIssueMenu").click(function() {
		menuSlideControl("insertIssueMenu");
	});
	$("#treeMenu").click(function() {
        menuSlideControl("treeMenu");
        initDataTree();
    });
    $("#chartMenu").click(function() {
        menuSlideControl("chartMenu");
        initDataChart();
    });
    $("#logMenu").click(function() {
        menuSlideControl("logMenu");
        dataInfoChangeRequestLogList();
    });
    $("#attributeMenu").click(function() {
        menuSlideControl("attributeMenu");
    });
	$("#configMenu").click(function() {
		menuSlideControl("configMenu");
	});
	
	function menuSlideControl(menuName) {
		var compareMenuState = menuObject[menuName];
		for(var key in menuObject) {
		    // state 값 변경하고, css 변경
			if(key === menuName) {
			    var value = menuObject[key];
				if(value) {
					$("#" + menuName).removeClass("on");
					$("#menuContent").hide();
					$("#" + menuName + "Content").hide();
				} else {
					$("#" + menuName).addClass("on");
					$("#menuContent").show();
					$("#" + menuName + "Content").show();
				}
				menuObject[menuName] = !compareMenuState;
			} else {
				$("#" + key).removeClass("on");
				$("#" + key + "Content").hide();
			}
		}
	}
	
	// menu content close 버튼
	$("#menuContentClose").click(function() {
		for(var key in menuObject) {
            var value = menuObject[key];
            if(value) {
				$("#menuContent").hide();
				$("#" + key + "Content").hide();
				$("#" + key).removeClass("on");
				menuObject[key] = !value;
			}
		}
		// 이슈 등록 비활성화 상태
		changeInsertIssueStateAPI(managerFactory, 0);
	});
	
	// Data 검색
	var searchDataFlag = true;
	$("#searchData").click(function() {
		if ($.trim($("#search_value").val()) === ""){
			alert(JS_MESSAGE["search.word.empty"]);
			$("#search_value").focus();
			return false;
		}
		
		if(searchDataFlag) {
			searchDataFlag = false;
			var info = $("#searchForm").serialize();
			var url = null;
			if($("#search_word").val() === "data_name") {
				url = "/data/ajax-search-data.do";
			} else {
				url = "/homepage/ajax-list-issue.do";
			}
			
			$.ajax({
				url: url,
				type: "POST",
				data: info,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						var issueDoesNotExistMessage = "<spring:message code='issue.not.exist'/>";
						var dataDoesNotExistMessage = "<spring:message code='data.not.exist'/>";
						var commonShortcutMessage = "<spring:message code='shortcut'/>";
						
						var searchType = $("#search_word").val();
						var content = "";
						if(searchType === "data_name") {
							var dataInfoList = msg.dataInfoList;
							if(dataInfoList == null || dataInfoList.length == 0) {
								content = content	
									+ 	"<li style=\"text-align: center; padding-top:20px; height: 50px;\">"
									+	dataDoesNotExistMessage
									+	"</li>";
							} else {
								dataInfoListCount = dataInfoList.length;
								for(i=0; i<dataInfoListCount; i++ ) {
									var dataInfo = dataInfoList[i];
									content = content 
										+ 	"<li>";
									if(dataInfo.parent !== 0) {	
										content = content 
										+ 	"	<button type=\"button\" title=\"" + commonShortcutMessage + "\""
										+ 	" 		onclick=\"gotoData('" + dataInfo.project_id + "', '" + dataInfo.data_key + "');\">" + commonShortcutMessage + "</button>";
									}
									content = content 
										+ 	"	<div class=\"info\">"
										+ 	"		<p class=\"title\">"
										+ 	"			<span>" + dataInfo.project_name + "</span>"
										+ 				dataInfo.data_name
										+ 	"		</p>"
										+ 	"		<ul class=\"tag\">"
										+ 	"			<li><span class=\"t3\"></span>" + dataInfo.latitude + "</li>"
										+ 	"			<li><span class=\"t3\"></span>" + dataInfo.longitude + "</li>"
										+ 	"			<li class=\"date\">" + dataInfo.insert_date.substring(0,19) + "</li>"
										+ 	"		</ul>"
										+ 	"	</div>"
										+ 	"</li>";
								}
							}
						} else {
							var issueList = msg.issueList;
							if(issueList === null || issueList.length === 0) {
								content = content	
									+ 	"<li style=\"text-align: center; padding-top:20px; height: 50px;\">"
									+	issueDoesNotExistMessage
									+	"</li>";
							} else {
								issueListCount = issueList.length;
								for(i=0; i<issueListCount; i++ ) {
									var issue = issueList[i];
									content = content 
										+ 	"<li>"
										+ 	"	<button type=\"button\" title=\"" + commonShortcutMessage + "\""
										+			" onclick=\"gotoIssue('" + issue.project_id + "', '" + issue.issue_id + "', '" + issue.issue_type + "', '" 
										+ 				issue.longitude + "', '" + issue.latitude + "', '" + issue.height + "', '2');\">" + commonShortcutMessage + "</button>"
										+ 	"	<div class=\"info\">"
										+ 	"		<p class=\"title\">"
										+ 	"			<span>" + issue.project_name + "</span>"
										+ 				issue.title
										+ 	"		</p>"
										+ 	"		<ul class=\"tag\">"
										+ 	"			<li><span class=\"" + issue.issue_type_css_class + "\"></span>" + issue.issue_type_name + "</li>"
										+ 	"			<li><span class=\"" + issue.priority_css_class + "\"></span>" + issue.priority_name + "</li>"
										+ 	"			<li class=\"date\">" + issue.insert_date.substring(0,19) + "</li>"
										+ 	"		</ul>"
										+ 	"	</div>"
										+ 	"</li>";
								}
							}
						}
						
						$("#searchList").empty();
						$("#searchList").html(content);
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
					searchDataFlag = true;
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
			    	console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
					searchDataFlag = true;
				}
			});
		} else {
			alert(JS_MESSAGE["button.dobule.click"]);
			return;
		}
	});
	
	// 데이터 위치로 이동
	function gotoData(projectId, dataKey) {
		searchDataAPI(managerFactory, projectId, dataKey);
	}
	
	$("#localSearch").click(function() {
		if ($.trim($("#localSearchDataKey").val()) === ""){
			alert(JS_MESSAGE["data.key.empty"]);
			$("#localSearchDataKey").focus();
			return false;
		}
		searchDataAPI(managerFactory, $("#localSearchProjectId").val(), $("#localSearchDataKey").val());
	});
	
	// object 정보 표시 call back function
	function showSelectedObject(projectId, dataKey, objectId, latitude, longitude, height, heading, pitch, roll) {
		var objectInfoViewFlag = $(':radio[name="objectInfo"]:checked').val();
		if(objectInfoViewFlag) {
			$("#moveProjectId").val(projectId);
			$("#moveDataKey").val(dataKey);
			$("#moveLatitude").val(latitude);
			$("#moveLongitude").val(longitude);
			$("#moveHeight").val(height);
			$("#moveHeading").val(heading);
			$("#movePitch").val(pitch);
			$("#moveRoll").val(roll);
			
			$.toast({
			    heading: 'Click Object Info',
			    text: [
			    	'projectId : ' + projectId,
			        'dataKey : ' + dataKey, 
			        'objectId : ' + objectId,
			        'latitude : ' + latitude,
			        'longitude : ' + longitude,
			        'height : ' + height,
			        'heading : ' + heading,
			        'pitch : ' + pitch,
			        'roll : ' + roll
			    ],
				bgColor : '#393946',
				hideAfter: 5000,
				icon: 'info',
				position : 'bottom-right'
			});
			
			// occlusion culling
			$("#occlusion_culling_data_key").val(dataKey);
			// 현재 좌표를 저장
			saveCurrentLocation(latitude, longitude);
		}
	}
	// 속성 가시화
	$("#changePropertyRendering").click(function(e) {
		var isShow = $(':radio[name="propertyRendering"]:checked').val();
		if(isShow === undefined){
			alert(JS_MESSAGE["demo.selection"]);
			return false;
		}
		if ($.trim($("#propertyRenderingWord").val()) === ""){
			alert(JS_MESSAGE["demo.property.empty"]);
			$("#propertyRenderingWord").focus();
			return false;
		}
		changePropertyRenderingAPI(managerFactory, isShow, $("#propertyRenderingProjectId").val(), $("#propertyRenderingWord").val());
	});
	
	// 색변경
	$("#changeColor").click(function(e) {
		if ($.trim($("#colorDataKey").val()) === ""){
			alert(JS_MESSAGE["data.key.empty"]);
			$("#colorDataKey").focus();
			return false;
		}
		
		var objectIds = null;
		var colorObjectIds = $("#colorObjectIds").val();
		if(colorObjectIds !== null && colorObjectIds !== "") objectIds = colorObjectIds.split(",");
		changeColorAPI(managerFactory, $("#colorProjectId").val(), $("#colorDataKey").val(), objectIds, $("#colorProperty").val(), $("#updateColor").val());
	});
	// 색깔 변경 이력 삭제
	$("#deleteAllChangeColor").click(function () {
		if(confirm("삭제 하시겠습니까?")) {
			deleteAllChangeColorAPI(managerFactory);
		}
	});
	
	// 변환행렬
	$("#changeLocationAndRotation").click(function() {
		if(!changeLocationAndRotationCheck()) return false;
		changeLocationAndRotationAPI(	managerFactory, $("#moveProjectId").val(),
										$("#moveDataKey").val(), $("#moveLatitude").val(), $("#moveLongitude").val(), 
										$("#moveHeight").val(), $("#moveHeading").val(), $("#movePitch").val(), $("#moveRoll").val());
	});
	function changeLocationAndRotationCheck() {
		if ($.trim($("#moveDataKey").val()) === ""){
			alert(JS_MESSAGE["data.key.empty"]);
			$("#moveDataKey").focus();
			return false;
		}
		if ($.trim($("#moveLatitude").val()) === ""){
			alert(JS_MESSAGE["data.latitude.empty"]);
			$("#moveLatitude").focus();
			return false;
		}
		if ($.trim($("#moveLongitude").val()) === ""){
			alert(JS_MESSAGE["data.longitude.empty"]);
			$("#moveLongitude").focus();
			return false;
		}
		if ($.trim($("#moveHeight").val()) === ""){
			alert(JS_MESSAGE["data.height.empty"]);
			$("#moveHeight").focus();
			return false;
		}
		if ($.trim($("#moveHeading").val()) === ""){
			alert(JS_MESSAGE["data.heading.empty"]);
			$("#moveHeading").focus();
			return false;
		}
		if ($.trim($("#movePitch").val()) === ""){
			alert(JS_MESSAGE["data.pitch.empty"]);
			$("#movePitch").focus();
			return false;
		}
		if ($.trim($("#moveRoll").val()) === ""){
			alert(JS_MESSAGE["data.roll.empty"]);
			$("#moveRoll").focus();
			return false;
		}
		return true;
	}
	
	// 변환행렬 수정
	var isUpdateLocationAndRotation = true;
	$("#updateLocationAndRotation").click(function() {
		if(!changeLocationAndRotationCheck()) return false;
								
		if(isUpdateLocationAndRotation) {
			isUpdateLocationAndRotation = false;
			var url = "/data/ajax-update-data-location-and-rotation.do";
			var info = 	"project_id=" + $("#moveProjectId").val()
						+ "&data_key=" + $("#moveDataKey").val()
						+ "&latitude=" + $("#moveLatitude").val()
						+ "&longitude=" + $("#moveLongitude").val()
						+ "&height=" + $("#moveHeight").val()
						+ "&heading=" + $("#moveHeading").val()
						+ "&pitch=" + $("#movePitch").val()
						+ "&roll=" + $("#moveRoll").val();
			$.ajax({
				url: url,
				type: "POST",
				data: info,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						alert(JS_MESSAGE["insert"]);
						// ajax
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
					isUpdateLocationAndRotation = true;
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
			    	console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			    	isUpdateLocationAndRotation = true;
				}
			});
		} else {
			alert(JS_MESSAGE["button.dobule.click"]);
			return;
		}
	});
	
	// 인접 지역 이슈 표시
	function changeNearGeoIssueList(isShow) {
		$("input:radio[name='nearGeoIssueList']:radio[value='" + isShow + "']").prop("checked", true);
		if(isShow) {
			// 현재 위치의 latitude, logitude를 가지고 가장 가까이에 있는 데이터 그룹에 속하는 이슈 목록을 최대 100건 받아서 표시
			var now_latitude = $("#now_latitude").val();
			var now_longitude = $("#now_longitude").val();
			var info = "latitude=" + now_latitude + "&longitude=" + now_longitude;
			var url = "/issue/ajax-list-issue-by-geo.do";
			$.ajax({
				url: url,
				type: "POST",
				data: info,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						var issueList = msg.issueList;
						if(issueList != null && issueList.length > 0) {
							for(i=0; i<issueList.length; i++ ) {
								var issue = issueList[i];
								drawInsertIssueImageAPI(managerFactory, 0, issue.issue_id, issue.issue_type, issue.data_key, issue.latitude, issue.longitude, issue.height);
							}
						}
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
			    	console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
				}
			});
		}
		changeNearGeoIssueListViewModeAPI(managerFactory, isShow);
	}
	
	function initDataTree() {
        var projectId = $("#treeProjectId").val();
		var projectData = getDataAPI(CODE.PROJECT_ID_PREFIX + projectId);
        if (projectData === null || projectData === undefined) {
            $.ajax({
            	url: dataInformationUrl,
				type: "POST",
				data: "project_id=" + projectId,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
                success: function(msg) {
                	if(msg.result === "success") {
						var projectDataJson = JSON.parse(msg.projectDataJson);
						if(projectDataJson === null || projectDataJson === undefined) {
							alert(JS_MESSAGE["project.data.no.found"]);
							return;
						}
						drawDataTree(projectId, projectDataJson);
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
                },
                error : function(request, status, error) {
                	alert(JS_MESSAGE["ajax.error.message"]);
                    console.log("code : " + request.status + "\n" + "message : " + request.responseText + "\n" + "error : " + error);
                }
            });
        } else {
            drawDataTree(projectId, projectData);
        }
	}

	function drawDataTree(projectId, projectData) {
	    var content = 	"";
	    var dataCssId = 1;
	    content 	= 	content
					+ 	"<tr class=\"treegrid-" + dataCssId + "\" style=\"height: 25px; background-color: #F79F81\">"
					+ 		"<td style=\"padding-left: 10px\" nowrap=\"nowrap\"></td>"
					+		"<td colspan=\"3\"> <b>" + projectData.data_name + "</b></td>"
					+	"</tr>";
	    var childrenCount = projectData.children.length;
	    if(childrenCount > 0) {
            var childrenContent = getChildrenContent(projectId, dataCssId, projectData.children);
            content = content + childrenContent;
        }

        $("#dataTree").html("");
		$("#dataTree").append(content);
        $('.dataTree').treegrid({
            expanderExpandedClass: 'glyphicon glyphicon-minus',
            expanderCollapsedClass: 'glyphicon glyphicon-plus'
        });
	}

	function getChildrenContent(projectId, dataCssId, children) {
        var content = 	"";
       	var count = children.length;
       	var parentClass = " treegrid-parent-" + dataCssId;
       	var evenColor = "background-color: #ccc";
       	var oddColor = "background-color: #eee";
       	for(var i=0; i<count; i++) {
       		dataCssId++;
			var bgcolor = (dataCssId % 2 == 0) ? evenColor : oddColor;
			var myClass = "treegrid-" + dataCssId;
	        var dataInfo = children[i];
			content 	= 	content
                + 	"<tr class=\"" + myClass + parentClass + "\" style=\"height: 25px;" + bgcolor + "\">"
                + 		"<td style=\"padding-left: 2px\" nowrap=\"nowrap\"></td>"
                +		"<td title=\"" + dataInfo.data_key + "\"> " + dataInfo.data_name + "</td>"
                +		"<td style=\"padding-left: 5px\"><button type=\"button\" title=\"Shortcuts\" class=\"dataShortcut\" onclick=\"gotoData('" + projectId + "', '" + dataInfo.data_key + "');\">Shortcuts</button></td>"
                +		"<td style=\"padding-left: 5px; padding-right: 5px;\"><a href=\"#\" onclick=\"viewDataAttribute('" + dataInfo.data_id + "'); return false; \">Details</a></td>"
                +	"</tr>";
            var childrenCount = dataInfo.children.length;
            if(childrenCount > 0) {
                var childrenContent = getChildrenContent(projectId, dataCssId, dataInfo.children);
                content = content + childrenContent;
            }
		}
		return content;
	}

    var dataAttributeDialog = $( ".dataAttributeDialog" ).dialog({
        autoOpen: false,
        width: 400,
        height: 550,
		modal: true,
        resizable: false
    });

    // data key 를 이용하여 dataInfo 정보를 취득
    function viewDataAttribute(dataId) {
    	var url = "/data/ajax-data-by-data-id.do";
		var info = "data_id=" + dataId;
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					showDataInfo(msg.dataInfo);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
    }

    // data info daialog callback
    function showDataInfo(dataInfo) {
        dataAttributeDialog.dialog( "open" );
        $("#detailDataKey").html(dataInfo.data_key);
        $("#detailDataName").html(dataInfo.data_name);
        $("#detailLatitude").html(dataInfo.latitude);
        $("#detailLongitude").html(dataInfo.longitude);
        $("#detailHeight").html(dataInfo.height);
        $("#detailHeading").html(dataInfo.heading);
        $("#detailPitch").html(dataInfo.pitch);
        $("#detailRoll").html(dataInfo.roll);
        showDataAttribute(dataInfo.data_id);
	}
    
    function showDataAttribute(dataId) {
    	var url = "/data/ajax-data-attribute-by-data-id.do";
		var info = "data_id=" + dataId;
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					if(msg.dataInfoAttribute === null || msg.dataInfoAttribute.attributes === null || msg.dataInfoAttribute.attributes === "") {
						var message = "<spring:message code='demo.data.attribute.not.exist'/>";
						$("#detailAttribute").html(message);
					} else {
						$("#detailAttribute").html("");
						$("#detailAttribute").html(msg.dataInfoAttribute.attributes);
					}
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
    
	// chart 표시
	function initDataChart() {
        projectChart();
        dataStatusChart();
	}

	// project 별 chart
	function projectChart() {
		var url = "/data/ajax-project-data-statistics.do";
		var info = "";
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					drawProjectChart(msg.projectNameList, msg.dataTotalCountList);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
	
	function drawProjectChart(projectNameList, dataTotalCountList) {
		if(projectNameList == null || projectNameList.length == 0) {
			return;
		} 
		
		var data = [];
		var projectCount =  projectNameList.length;
		for(i=0; i<projectCount; i++ ) {
			var projectStatisticsArray = [ projectNameList[i], dataTotalCountList[i]];
			data.push(projectStatisticsArray);
		}
		
		$("#projectChart").html("");
        //var data = [["3DS", 37],["IFC(Cultural Assets)", 1],["IFC", 42],["IFC(MEP)", 1],["Sea Port", 7],["Collada", 7],["IFC(Japan)", 5]];
        var plot = $.jqplot("projectChart", [data], {
            //title : "project 별 chart",
            seriesColors: [ "#a67ee9", "#FE642E", "#01DF01", "#2E9AFE", "#F781F3", "#F6D8CE", "#99a0ac" ],
            grid: {
                drawBorder: false,
                drawGridlines: false,
                background: "#ffffff",
                shadow:false
            },
            gridPadding: {top:0, bottom:115, left:0, right:20},
            seriesDefaults:{
                renderer:$.jqplot.PieRenderer,
                trendline : { show : false},
                rendererOptions: {
                    padding:8,
                    showDataLabels: true,
                    dataLabels: "value",
                    //dataLabelFormatString: "%.1f%"
                },
            },
            legend: {
                show: true,
                fontSize: "10pt",
                placement : "outside",
                rendererOptions: {
                    numberRows: 3,
                    numberCols: 3
                },
                location: "s",
                border: "none",
                marginLeft: "10px"
            }
        });
	}

	function dataStatusChart() {
		var url = "/data/ajax-data-status-statistics.do";
		var info = "";
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					drawDataStatusChart(msg.useTotalCount, msg.forbidTotalCount, msg.etcTotalCount);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
	
	function drawDataStatusChart(useTotalCount, forbidTotalCount, etcTotalCount) {
        $("#dataStatusChart").html("");
        
        var useTotalCountLabel = "<spring:message code='demo.data.statistics.use'/>";
        var forbidTotalCountLabel = "<spring:message code='demo.data.statistics.forbid'/>";
        var etcTotalCountLabel = "<spring:message code='demo.data.statistics.etc'/>";
        var dataValues = [ useTotalCount, forbidTotalCount, etcTotalCount];
        var ticks = [useTotalCountLabel, forbidTotalCountLabel, etcTotalCountLabel];
        var yMax = 100;
        if(useTotalCount > 100 || forbidTotalCount > 100 || etcTotalCount > 100) {
			yMax = Math.max(useTotalCount, forbidTotalCount, etcTotalCount) + (useTotalCount * 0.2);
		}

        var plot = $.jqplot("dataStatusChart", [dataValues], {
            //title : "data 상태별 차트",
            height: 205,
            animate: !$.jqplot.use_excanvas,
            seriesColors: [ "#ffa076"],
            grid: {
                background: "#fff",
                //background: "#14BA6C"
                gridLineWidth: 0.7,
                //borderColor: 'transparent',
                shadow: false,
                borderWidth:0.1
                //shadowColor: 'transparent'
            },
            gridPadding:{
                left:35,
                right:1,
                to:40,
                bottom:27
            },
            seriesDefaults:{
                shadow:false,
                renderer:$.jqplot.BarRenderer,
                pointLabels: { show: true },
                rendererOptions: {
                    barWidth: 40
                }
            },
            axes: {
                xaxis: {
                    renderer: $.jqplot.CategoryAxisRenderer,
                    ticks: ticks,
                    tickOptions:{
                        formatString: "%'d",
                        fontSize: "10pt"
                    }
                },
                yaxis: {
                    numberTicks : 6,
                    min : 0,
                    max : yMax,
                    tickOptions:{
                        formatString: "%'d",
                        fontSize: "10pt"
                    }
                }
            },
            highlighter: { show: false }
        });
	}
	
	function dataInfoChangeRequestLogList() {
		var dataInfoLogListDoesNotExistMessage = "<spring:message code='demo.data.change.request.log.not.exist'/>";
		var requestMessage = "<spring:message code='request'/>";
		var completeMessage = "<spring:message code='complete'/>";
		var rejectMessage = "<spring:message code='reject'/>";
		var resetMessage = "<spring:message code='reset'/>";
		
		var url = "/data/ajax-list-data-change-request-log.do";
		var info = "";
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					var dataInfoLogList = msg.dataInfoLogList;
					var totalCount = msg.totalCount;
					var content = "";
					var dataInfoLogListCount = 0;
					if(dataInfoLogList === null || dataInfoLogList.length === 0) {
						content += 	"<tr style=\"text-align: center; vertical-align: middle; padding-top:20px; height: 50px;\">"
								+	"	<td colspan=\"3\" rowspan=\"2\">" +	dataInfoLogListDoesNotExistMessage + "</td>"
								+	"</tr>";
					} else {
						dataInfoLogListCount = dataInfoLogList.length;
						for(i=0; i<dataInfoLogListCount; i++ ) {
							var dataInfoLog = dataInfoLogList[i];
							var status = "";
							if(dataInfoLog.status == "0") status = requestMessage;
							else if(dataInfoLog.status == "1") status = completeMessage;
							else if(dataInfoLog.status == "2") status = rejectMessage;
							else if(dataInfoLog.status == "3") status = resetMessage;
							
							content = content 
							+	"<tr style=\"height: 30px;\">"
							+	"	<td rowspan=\"2\">" + (totalCount - i) + "</td>"
							+	"	<td>" + dataInfoLog.user_id + "</td>"
							+	"	<td><a href=\"#\" onclick=\"dataChangeLog('" + dataInfoLog.data_info_log_id + "'); return false;\">" + dataInfoLog.data_name + "</a></td>"
							+	"</tr>"
							+	"<tr style=\"height: 30px;\">"
							+	"	<td>" + status + "</td>"
							+	"	<td>" + dataInfoLog.view_insert_date + "</td>"
							+	"</tr>";
						}
					}
					$("#dataInfoChangeRequestLog").empty();
					$("#dataInfoChangeRequestLog").html(content);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
	
	// data info change request log
    var dataInfoChangeDialog = $( ".dataInfoChangeDialog" ).dialog({
        autoOpen: false,
        width: 400,
        height: 300,
        modal: true,
        resizable: false
    });
	function dataChangeLog(dataInfoLogId) {
		var url = "/data/ajax-data-info-log.do";
		var info = "data_info_log_id=" + dataInfoLogId;
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					var dataInfoLog = msg.dataInfoLog;
					$("#beforeLatitude").html(dataInfoLog.before_latitude);
					$("#afterLatitude").html(dataInfoLog.latitude);
					$("#beforeLongitude").html(dataInfoLog.before_longitude);
					$("#afterLongitude").html(dataInfoLog.longitude);
					$("#beforeHeight").html(dataInfoLog.before_height);
					$("#afterHeight").html(dataInfoLog.height);
					$("#beforeHeading").html(dataInfoLog.before_heading);
					$("#afterHeading").html(dataInfoLog.heading);
					$("#beforePitch").html(dataInfoLog.before_pitch);
					$("#afterPitch").html(dataInfoLog.pitch);
					$("#beforeRoll").html(dataInfoLog.before_roll);
					$("#afterRoll").html(dataInfoLog.roll);
					
					dataInfoChangeDialog.dialog({title: dataInfoLog.data_name + " Change Request Log"}).dialog( "open" );
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
	}
	
	// Data Object Attribute 검색
	var objectAttributeSearchFlag = true;
    $("#objectAttributeSearch").click(function() {
        if ($.trim($("#objectAttributeDataKey").val()) === "") {
            alert(JS_MESSAGE["data.key.empty"]);
            $("#objectAttributeDataKey").focus();
            return false;
        }
        if ($.trim($("#objectAttributeObjectId").val()) === "") {
        	alert(JS_MESSAGE["object.id.empty"]);
            $("#objectAttributeObjectId").focus();
            return false;
        }

        if(objectAttributeSearchFlag) {
            objectAttributeSearchFlag = false;
            var doesNotExistMessage = "<spring:message code='data.object.does.not.exist'/>";
            
			var url = "/data/ajax-list-data-object-attribute.do";
			var info = 	"project_id=" + $("#objectAttributeProjectId").val()
						+ "&data_key=" + $("#objectAttributeDataKey").val()
						+ "&object_id=" + $("#objectAttributeObjectId").val()
						+ "&search_value=" + $("#objectAttributeSearchValue").val();
			$.ajax({
				url: url,
				type: "GET",
				data: info,
				dataType: "json",
				headers: { "X-mago3D-Header" : "mago3D"},
				success : function(msg) {
					if(msg.result === "success") {
						var dataInfoObjectAttributeList = msg.dataInfoObjectAttributeList;
						var totalCount = msg.totalCount;
						var content = "";
						var dataInfoObjectAttributeListCount = 0;
						if(dataInfoObjectAttributeList === null || dataInfoObjectAttributeList.length === 0) {
							content += 	"<tr style=\"text-align: center; vertical-align: middle; padding-top:20px; height: 50px;\">"
									+	"	<td colspan=\"3\">" +	doesNotExistMessage + "</td>"
									+	"</tr>";
						} else {
							dataInfoObjectAttributeListCount = dataInfoObjectAttributeList.length;
							for(i=0; i<dataInfoObjectAttributeListCount; i++ ) {
								var dataInfoObjectAttribute = dataInfoObjectAttributeList[i];
								
								content = content
								+ 	"<tr style=\"height: 30px; background-color: #eee\">"
								+ 		"<td style=\"padding-left: 2px\" nowrap=\"nowrap\">" + dataInfoObjectAttribute.data_id + "</td>"
								+		"<td>" + dataInfoObjectAttribute.object_id + "</td>"
								+		"<td style=\"padding-left: 5px; padding-right: 5px;\">"
								+		"	<a href=\"#\" onclick=\"viewDataObjectAttribute('" 
								+ 				dataInfoObjectAttribute.data_object_attribute_id + "'); return false; \">Details</a></td>"
								+	"</tr>";	
							}
						}
						
						$("#objectAttributeSearchList > tbody:last").html("");
			            $("#objectAttributeSearchList > tbody:last").append(content);
					} else {
						alert(JS_MESSAGE[msg.result]);
					}
					objectAttributeSearchFlag = true;
				},
				error : function(request, status, error) {
					alert(JS_MESSAGE["ajax.error.message"]);
			    	console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			    	objectAttributeSearchFlag = true;
				}
			});
        } else {
            alert("In progress.");
            return;
        }
    });

    var dataObjectAttributeDialog = $( ".dataObjectAttributeDialog" ).dialog({
        autoOpen: false,
        width: 600,
        height: 550,
        modal: true,
        resizable: false
    });

    // data key 를 이용하여 dataInfo 정보를 취득
	function viewDataObjectAttribute(dataObjectAttributeId) {
        dataObjectAttributeDialog.dialog( "open" );
        
        var url = "/data/ajax-data-object-attribute.do";
		var info = "data_object_attribute_id=" + dataObjectAttributeId;
		$.ajax({
			url: url,
			type: "GET",
			data: info,
			dataType: "json",
			headers: { "X-mago3D-Header" : "mago3D"},
			success : function(msg) {
				if(msg.result === "success") {
					//var jsonAttribute = JSON.stringify(msg.dataInfoObjectAttribute.attributes, null, 2);
	                $("#dataObjectAttributeContent").append(msg.dataInfoObjectAttribute.attributes);
				} else {
					alert(JS_MESSAGE[msg.result]);
				}
			},
			error : function(request, status, error) {
				alert(JS_MESSAGE["ajax.error.message"]);
				console.log("code : " + request.status + "\n message : " + request.responseText + "\n error : " + error);
			}
		});
    }
	
	// 설정 메뉴 시작
	// Label 표시
	function changeLabel(isShow) {
		$("input:radio[name='labelInfo']:radio[value='" + isShow + "']").prop("checked", true);
		changeLabelAPI(managerFactory, isShow);
	}
	// object info 표시
	function changeObjectInfoViewMode(isShow) {
		$("input:radio[name='objectInfo']:radio[value='" + isShow + "']").prop("checked", true);
		changeObjectInfoViewModeAPI(managerFactory, isShow);
	}
	// Origin 표시/비표시
    function changeOrigin(isShow) {
        $("input:radio[name='origin']:radio[value='" + isShow + "']").prop("checked", true);
        changeOriginAPI(managerFactory, isShow);
    }
	// boundingBox 표시/비표시
	function changeBoundingBox(isShow) {
		$("input:radio[name='boundingBox']:radio[value='" + isShow + "']").prop("checked", true);
		changeBoundingBoxAPI(managerFactory, isShow);
	}
	// 마우스 클릭 객체 이동 모드 변경
	function changeObjectMove(objectMoveMode) {
		$("input:radio[name='objectMoveMode']:radio[value='" + objectMoveMode + "']").prop("checked", true);
		changeObjectMoveAPI(managerFactory, objectMoveMode);
		// ALL 인 경우 Origin도 같이 표시
        var originValue = $(':radio[name="origin"]:checked').val();
        if(objectMoveMode === "0") {
		    if(originValue === "true") {
            } else {
            }
            changeOriginAPI(managerFactory, true);
        } else {
            if(originValue === "true") {
            } else {
                changeOriginAPI(managerFactory, false);
            }
        }
	}
	// 마우스 클릭 객체 이동 모드 변경 저장
	$("#saveObjectMoveButton").click(function () {
		alert(JS_MESSAGE["preparing"]);
		return;
		var objectMoveMode = $(':radio[name="objectMoveMode"]:checked').val();
		if(objectMoveMode === "2") {
			alert(JS_MESSAGE["demo.none.mode.not.save"]);
			return;
		}
		saveObjectMoveAPI(managerFactory, objectMoveMode);
	});
	// 마우스 클릭 객체 이동 모드 변경 삭제
	$("#deleteAllObjectMoveButton").click(function () {
		var objectMoveMode = $(':radio[name="objectMoveMode"]:checked').val();
		if(confirm("삭제 하시겠습니까?")) {
			deleteAllObjectMoveAPI(managerFactory, objectMoveMode);
		}
	});
	// Object Occlusion culling
	$("#changeOcclusionCullingButton").click(function() {
		var isUse = $(':radio[name="occlusionCulling"]:checked').val();
		if(isUse === undefined){
			alert(JS_MESSAGE["demo.occlusion.culling.selection"]);
			return;
		}
		if($.trim($("#occlusion_culling_data_key").val()) === ""){
			alert(JS_MESSAGE["data.key.empty"]);
			$("#occlusion_culling_data_key").focus();
			return;
		}
		changeOcclusionCullingAPI(managerFactory, ($(':radio[name="occlusionCulling"]:checked').val() === "true"), $("#occlusion_culling_data_key").val());
	});
	
	// 카메라 모드 전환
	function changeViewMode(isFPVMode) {
		$("input:radio[name='viewMode']:radio[value='" + isFPVMode + "']").prop("checked", true);
		changeFPVModeAPI(managerFactory, isFPVMode);
	}
	
	// rendering 설정
	function initRendering() {
		var ambient = $( "#geo_ambient_reflection_coef_view" );
		$( "#ambient_reflection_coef" ).slider({
			range: "max",
			min: 0, // min value
			max: 1, // max value
			step: 0.01,
			value: '0.5', // default value of slider
			create: function() {
				ambient.text( $( this ).slider( "value" ) );
			},
			slide: function( event, ui ) {
				ambient.text( ui.value);
				$("#geo_ambient_reflection_coef" ).val(ui.value);
			}
		});
		var diffuse = $( "#geo_diffuse_reflection_coef_view" );
		$( "#diffuse_reflection_coef" ).slider({
			range: "max",
			min: 0, // min value
			max: 1, // max value
			step: 0.01,
			value: '1.0', // default value of slider
			create: function() {
				diffuse.text( $( this ).slider( "value" ) );
			},
			slide: function( event, ui ) {
				diffuse.text( ui.value);
				$("#geo_diffuse_reflection_coef" ).val(ui.value);
			}
		});
		var specular = $( "#geo_specular_reflection_coef_view" );
		$( "#specular_reflection_coef" ).slider({
			range: "max",
			min: 0, // min value
			max: 1, // max value
			step: 0.01,
			value: '1.0', // default value of slider
			create: function() {
				specular.text( $( this ).slider( "value" ) );
			},
			slide: function( event, ui ) {
				specular.text( ui.value);
				$("#geo_specular_reflection_coef" ).val(ui.value);
			}
		});
	}
	
	// LOD 설정
	$("#changeLodButton").click(function() {
		changeLodAPI(managerFactory, $("#geo_lod0").val(), $("#geo_lod1").val(), $("#geo_lod2").val(), $("#geo_lod3").val(), $("#geo_lod4").val(), $("#geo_lod5").val());
	});
	// Lighting 설정
	$("#changeLightingButton").click(function() {
		changeLightingAPI(managerFactory, $("#geo_ambient_reflection_coef").val(), $("#geo_diffuse_reflection_coef").val(), $("#geo_specular_reflection_coef").val(), null, null);
	});
	// Ssadradius 설정
	$("#changeSsaoRadiusButton").click(function() {
		if($.trim($("#geo_ssao_radius").val())==="") {
			alert(JS_MESSAGE["demo.ssao.empty"]);
			$("#geo_ssao_radius").focus();
			return;
		}
		changeSsaoRadiusAPI(managerFactory, $("#geo_ssao_radius").val());
	});

	// click poisition call back function
	function showClickPosition(position) {
		$("#positionLatitude").val(position.lat);
		$("#positionLongitude").val(position.lon);
		$("#positionAltitude").val(position.alt);
	}
	
	// 모든 데이터 비표시
	function clearAllData() {
		clearAllDataAPI(managerFactory);
	}
	
	// general callback alert function
	function showApiResult(apiName, result) {
		if(apiName === "searchData") {
			if(result === "-1") {
				alert(JS_MESSAGE["demo.information.not.loading"]);
			}
		}
	}
	
	function saveCurrentLocation(latitude, longitude) {
		// 현재 좌표를 저장
		$("#now_latitude").val(latitude);
		$("#now_longitude").val(longitude);
	}
	
	// moved data callback
	function showMovedData(projectId, dataKey, objectId, latitude, longitude, height, heading, pitch, roll) {
		$("#moveProjectId").val(projectId);
		$("#moveDataKey").val(dataKey);
        $("#moveLatitude").val(latitude);
        $("#moveLongitude").val(longitude);
        $("#moveHeight").val(height);
        $("#moveHeading").val(heading);
        $("#movePitch").val(pitch);
        $("#moveRoll").val(roll);
    }
</script>
</body>
</html>