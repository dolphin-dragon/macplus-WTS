<%@ page language="java" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="/view/conf/farmtag.tld" prefix="PF"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<base href="<PF:basePath/>">
<title>答题室数据管理</title>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<jsp:include page="/view/conf/include.jsp"></jsp:include>
</head>
<body class="easyui-layout">
	<div data-options="region:'west',split:true,border:false"
		style="width: 250px;">
		<div class="TREE_COMMON_BOX_SPLIT_DIV">
			<a id="examTypeTreeReload" href="javascript:void(0)"
				class="easyui-linkbutton" data-options="plain:true"
				iconCls="icon-reload">刷新</a> <a id="examTypeTreeOpenAll"
				href="javascript:void(0)" class="easyui-linkbutton"
				data-options="plain:true" iconCls="icon-sitemap">展开</a>
		</div>
		<ul id="examTypeTree"></ul>
	</div>
	<div class="easyui-layout" data-options="region:'center',border:false">
		<div data-options="region:'north',border:false">
			<form id="searchRoomForm">
				<table class="editTable">
					<tr>
						<td class="title">业务分类:</td>
						<td><input id="PARENTTITLE_RULE" type="text"
							readonly="readonly" style="background: #F3F3E8"> <input
							id="PARENTID_RULE" name="b.TREECODE:like" type="hidden"></td>
						<td class="title">答题室名称:</td>
						<td><input name="a.NAME:like" type="text"></td>
					</tr>
					<tr style="text-align: center;">
						<td colspan="4"><a id="a_search" href="javascript:void(0)"
							class="easyui-linkbutton" iconCls="icon-search">查询</a> <a
							id="a_reset" href="javascript:void(0)" class="easyui-linkbutton"
							iconCls="icon-reload">清除条件</a></td>
					</tr>
				</table>
			</form>
		</div>
		<div data-options="region:'center',border:false">
			<table id="dataRoomGrid">
				<thead>
					<tr>
						<th data-options="field:'ck',checkbox:true"></th>
						<th field="NAME" data-options="sortable:true" width="40">答题室名称</th>
						<th field="COUNTTYPE" data-options="sortable:true" width="20">阅卷类型</th>
						<th field="TIMELEN" data-options="sortable:true" width="40">答题时长</th>
						<th field="WRITETYPETITLE" data-options="sortable:true" width="20">答题类型</th>
						<th field="USERNUM" data-options="sortable:true" width="40">指定人数</th>
						<!-- WRITETYPE -->
						<th field="STARTTIME" data-options="sortable:true" width="40">开始时间</th>
						<th field="TIMETYPE" data-options="sortable:true" width="20">时间类型</th>
						<th field="TYPENAME" data-options="sortable:true" width="40">业务分类</th>
						<th field="PSTATETITLE" data-options="sortable:true" width="20">状态</th>
						<!-- PSTATE -->
					</tr>
				</thead>
			</table>
		</div>
		<div id="roomToolbar">
			<a href="javascript:void(0)" id="mb" class="easyui-menubutton"
				data-options="menu:'#viewMenus',iconCls:'icon-tip'">查看</a>
			<div id="viewMenus" style="width: 150px;">
				<div onclick="viewDataRoom()">房间信息</div>
				<div onclick="viewPopRoom()">权限信息</div>
			</div>
			<a class="easyui-linkbutton"
				data-options="iconCls:'icon-add',plain:true,onClick:addDataRoom">新增
			</a> <a class="easyui-linkbutton"
				data-options="iconCls:'icon-edit',plain:true,onClick:editDataRoom">修改
			</a> <a class="easyui-linkbutton"
				data-options="iconCls:'icon-remove',plain:true,onClick:delDataRoom">删除
			</a><a class="easyui-linkbutton"
				data-options="iconCls:'icon-communication',plain:true,onClick:moveTypetree">设置分类
			</a> <a href="javascript:void(0)" id="mb" class="easyui-menubutton"
				data-options="menu:'#mm6',iconCls:'icon-group_green_edit'">人员设置</a>
			<div id="mm6" style="width: 150px;">
				<div onclick="examuserMng()">答题人</div>
				<!--<div class="menu-sep"></div><div onclick="setCountPop()">阅卷人</div>
				 <div onclick="setAdminPop()">管理员</div> 
				<div onclick="setLeadPop()">评审人</div>-->
			</div>
			<a class="easyui-linkbutton"
				data-options="iconCls:'icon-administrative-docs',plain:true,onClick:paperListMng">答卷管理
			</a> <a href="javascript:void(0)" id="mb7" class="easyui-menubutton"
				data-options="menu:'#mm7',iconCls:'icon-networking'">发布</a>
			<div id="mm7" style="width: 150px;">
				<div onclick="examPublic()">发布</div>
				<div onclick="examValidate()">校验</div>
				<div class="menu-sep"></div>
				<div onclick="examPrivate()">禁用</div>
			</div>
			<!-- <a class="easyui-linkbutton"
				data-options="iconCls:'icon-move_to_folder',plain:true,onClick:delDataRoom">添加答卷
			</a>  -->
		</div>
	</div>
</body>
<jsp:include page="../authority/PopComponent.jsp"></jsp:include>
<script type="text/javascript">
	var url_delActionRoom = "room/del.do";//删除URL
	var url_formActionRoom = "room/form.do";//增加、修改、查看URL
	var url_searchActionRoom = "room/query.do";//查询URL
	var title_windowRoom = "答题室管理";//功能名称
	var gridRoom;//数据表格对象
	var searchRoom;//条件查询组件对象
	$(function() {
		//初始化数据表格
		gridRoom = $('#dataRoomGrid').datagrid({
			url : url_searchActionRoom,
			fit : true,
			fitColumns : true,
			'toolbar' : '#roomToolbar',
			pagination : true,
			closable : true,
			checkOnSelect : true,
			border : false,
			striped : true,
			rownumbers : true,
			ctrlSelect : true
		});
		//初始化条件查询
		searchRoom = $('#searchRoomForm').searchForm({
			gridObj : gridRoom
		});
		$('#examTypeTree').tree({
			url : 'examtype/examtypeTree.do?funtype=1',
			onSelect : function(node) {
				$('#PARENTID_RULE').val(node.id);
				$('#PARENTTITLE_RULE').val(node.text);
				searchRoom.dosearch({
					'ruleText' : searchRoom.arrayStr()
				});
			}
		});
		$('#examTypeTreeReload').bind('click', function() {
			$('#examTypeTree').tree('reload');
		});
		$('#examTypeTreeOpenAll').bind('click', function() {
			$('#examTypeTree').tree('expandAll');
		});
	});
	//查看基本信息
	function viewDataRoom() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			var url = url_formActionRoom + '?pageset.pageType=' + PAGETYPE.VIEW
					+ '&ids=' + selectedArray[0].ID;
			$.farm.openWindow({
				id : 'winRoom',
				width : 600,
				height : 400,
				modal : true,
				url : url,
				title : '浏览'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//查看权限
	function viewPopRoom() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			var url = 'room/popinfo.do?pageset.pageType=' + PAGETYPE.VIEW
					+ '&ids=' + selectedArray[0].ID;
			$.farm.openWindow({
				id : 'winPopRoom',
				width : 600,
				height : 400,
				modal : true,
				url : url,
				title : '浏览权限'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//新增
	function addDataRoom() {
		if (!$('#PARENTID_RULE').val() || $('#PARENTID_RULE').val() == 'NONE') {
			$.messager.alert(MESSAGE_PLAT.PROMPT, "请选中一个左侧的分类后再添加答题室!", 'info');
			return;
		}
		var url = url_formActionRoom + '?operateType=' + PAGETYPE.ADD;
		$.farm.openWindow({
			id : 'winRoom',
			width : 600,
			height : 400,
			modal : true,
			url : url,
			title : '新增'
		});
	}
	//修改
	function editDataRoom() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			if (selectedArray[0].PSTATE == '2') {
				$.messager.alert(MESSAGE_PLAT.PROMPT, "答卷已经发布，请取消发布后进行修改!",
						'info');
				return;
			}
			var url = url_formActionRoom + '?operateType=' + PAGETYPE.EDIT
					+ '&ids=' + selectedArray[0].ID;
			$.farm.openWindow({
				id : 'winRoom',
				width : 600,
				height : 400,
				modal : true,
				url : url,
				title : '修改'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}
	//删除
	function delDataRoom() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			if (selectedArray[0].PSTATE == '2'){
				$.messager.alert(MESSAGE_PLAT.PROMPT, "答卷已经发布，请取消发布后进行修改!",
						'info');
				return;
			}
			// 有数据执行操作
			var str = selectedArray.length + MESSAGE_PLAT.SUCCESS_DEL_NEXT_IS;
			$.messager.confirm(MESSAGE_PLAT.PROMPT, str, function(flag) {
				if (flag) {
					$(gridRoom).datagrid('loading');
					$.post(url_delActionRoom + '?ids='
							+ $.farm.getCheckedIds(gridRoom, 'ID'), {},
							function(flag) {
								var jsonObject = JSON.parse(flag, null);
								$(gridRoom).datagrid('loaded');
								if (jsonObject.STATE == 0) {
									$(gridRoom).datagrid('reload');
								} else {
									var str = MESSAGE_PLAT.ERROR_SUBMIT
											+ jsonObject.MESSAGE;
									$.messager.alert(MESSAGE_PLAT.ERROR, str,
											'error');
								}
							});
				}
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//发布校验
	function examValidate(funcHandle) {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			$.post("room/examValid.do" + '?roomid='
					+ $.farm.getCheckedIds(gridRoom, 'ID'), {}, function(flag) {
				if (flag.STATE == 0) {
					if (flag.warning) {
						$.messager.alert(MESSAGE_PLAT.PROMPT, flag.warning,
								'error', function() {
									if (funcHandle) {
										funcHandle(flag);
									}
								});
					} else {
						$.messager.alert(MESSAGE_PLAT.PROMPT, flag.info,
								'info', function() {
									if (funcHandle) {
										funcHandle(flag);
									}
								});
					}
				} else {
					var str = MESSAGE_PLAT.ERROR_SUBMIT + jsonObject.MESSAGE;
					$.messager.alert(MESSAGE_PLAT.ERROR, str, 'error');
				}
			}, 'json');
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	function doExamPublic() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			// 有数据执行操作
			var str = selectedArray.length + "条数据将被发布，是否继续?";
			$.messager.confirm(MESSAGE_PLAT.PROMPT, str, function(flag) {
				if (flag) {
					$(gridRoom).datagrid('loading');
					$.post("room/examPublic.do" + '?ids='
							+ $.farm.getCheckedIds(gridRoom, 'ID'), {},
							function(flag) {
								var jsonObject = JSON.parse(flag, null);
								$(gridRoom).datagrid('loaded');
								if (jsonObject.STATE == 0) {
									$(gridRoom).datagrid('reload');
								} else {
									var str = MESSAGE_PLAT.ERROR_SUBMIT
											+ jsonObject.MESSAGE;
									$.messager.alert(MESSAGE_PLAT.ERROR, str,
											'error');
								}
							});
				}
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//发布
	function examPublic() {
		examValidate(function() {
			doExamPublic();
		});
	}

	//禁用
	function examPrivate() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			// 有数据执行操作
			var str = selectedArray.length + "条数据将被禁用，是否继续?";
			$.messager.confirm(MESSAGE_PLAT.PROMPT, str, function(flag) {
				if (flag) {
					$(gridRoom).datagrid('loading');
					$.post("room/examPrivate.do" + '?ids='
							+ $.farm.getCheckedIds(gridRoom, 'ID'), {},
							function(flag) {
								var jsonObject = JSON.parse(flag, null);
								$(gridRoom).datagrid('loaded');
								if (jsonObject.STATE == 0) {
									$(gridRoom).datagrid('reload');
								} else {
									var str = MESSAGE_PLAT.ERROR_SUBMIT
											+ jsonObject.MESSAGE;
									$.messager.alert(MESSAGE_PLAT.ERROR, str,
											'error');
								}
							});
				}
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE,
					'info');
		}
	}

	//移动分类
	function moveTypetree() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			if (selectedArray[0].PSTATE == '2'){
				$.messager.alert(MESSAGE_PLAT.PROMPT, "答卷已经发布，请取消发布后进行修改!",
						'info');
				return;
			}
			$.farm.openWindow({
				id : 'examTypeNodeWin',
				width : 250,
				height : 300,
				modal : true,
				url : "examtype/examTypeTreeView.do?funtype=1&ids="
						+ $.farm.getCheckedIds(gridRoom, 'ID'),
				title : '设置分类'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE,
					'info');
		}
	}
	//设置分类回调函数
	function chooseExamNodeBackFunc(node, ids) {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		$.messager.confirm(MESSAGE_PLAT.PROMPT, "是否设置为该业务分类？", function(flag) {
			if (flag) {
				$.post("room/examtypeSetting.do", {
					ids : $.farm.getCheckedIds(gridRoom, 'ID'),
					examtypeId : node.id
				}, function(flag) {
					var jsonObject = JSON.parse(flag, null);
					$(gridRoom).datagrid('loaded');
					$('#examTypeNodeWin').window('close');
					if (jsonObject.STATE == 0) {
						$(gridRoom).datagrid('reload');
					} else {
						var str = MESSAGE_PLAT.ERROR_SUBMIT
								+ jsonObject.MESSAGE;
						$.messager.alert(MESSAGE_PLAT.ERROR, str, 'error');
					}
				});
			}
		});
	}
	//参考人管理
	function examuserMng() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			var userType = selectedArray[0].WRITETYPE;
			if (userType != '1'){
				$.messager.alert(MESSAGE_PLAT.PROMPT, "答题类型为任何人员，无须设置人员!",
						'info');
				return;
			}
			$.farm.openWindow({
				id : 'winRoom',
				width : 600,
				height : 400,
				modal : true,
				url : 'roomuser/list.do?roomid=' + selectedArray[0].ID,
				title : '参考人管理'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//考卷管理
	function paperListMng() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length == 1) {
			//if(selectedArray[0].PSTATE=='2'){
			//	$.messager.alert(MESSAGE_PLAT.PROMPT,"答卷已经发布，请取消发布后进行修改!",
			//	'info');
			//	return;
			//}
			$.farm.openWindow({
				id : 'winRoom',
				width : 600,
				height : 400,
				modal : true,
				url : 'roompaper/list.do?roomid=' + selectedArray[0].ID,
				title : '考卷管理'
			});
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE_ONLY,
					'info');
		}
	}

	//设置阅卷人权限
	function setCountPop() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			var ids = $.farm.getCheckedIds(gridRoom, 'ID');
			openPopWindow(ids, 'ROOM_COUNT', '设置阅卷人');
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE,
					'info');
		}
	}
	//设置管理员权限
	function setAdminPop() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			var ids = $.farm.getCheckedIds(gridRoom, 'ID');
			openPopWindow(ids, 'ROOM_ADMIN', '设置管理员');
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE,
					'info');
		}
	}
	//设置评审人权限
	function setLeadPop() {
		var selectedArray = $(gridRoom).datagrid('getSelections');
		if (selectedArray.length > 0) {
			var ids = $.farm.getCheckedIds(gridRoom, 'ID');
			openPopWindow(ids, 'ROOM_LEAD', '设置评审人');
		} else {
			$.messager.alert(MESSAGE_PLAT.PROMPT, MESSAGE_PLAT.CHOOSE_ONE,
					'info');
		}
	}
</script>
</html>