package com.farm.wcp.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.farm.core.auth.domain.LoginUser;
import com.farm.core.page.ViewMode;
import com.farm.parameter.FarmParameterService;
import com.farm.wcp.util.AntiXSS;
import com.farm.web.WebUtils;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.wts.exam.domain.Card;
import com.wts.exam.domain.Room;
import com.wts.exam.domain.ex.PaperUnit;
import com.wts.exam.service.ExamTypeServiceInter;
import com.wts.exam.service.PaperServiceInter;
import com.wts.exam.service.CardServiceInter;
import com.wts.exam.service.RoomServiceInter;

/**
 * 考试
 * 
 * @author autoCode
 * 
 */
@RequestMapping("/webpaper")
@Controller
public class PaperWebController extends WebUtils {
	@Resource
	private PaperServiceInter paperServiceImpl;
	@Resource
	private ExamTypeServiceInter examTypeServiceImpl;
	@Resource
	private RoomServiceInter roomServiceImpl;
	@Resource
	private CardServiceInter cardServiceImpl;
	private static final Logger log = Logger.getLogger(PaperWebController.class);

	public static String getThemePath() {
		return FarmParameterService.getInstance().getParameter("config.sys.web.themes.path");
	}

	/***
	 * 答题卡(匿名答题，继续答题)
	 * 
	 * @param session
	 * @return
	 */
	@RequestMapping("/Pubcard")
	public ModelAndView pubcard(String paperid, String roomId, HttpServletRequest request, HttpSession session) {
		return index(paperid, roomId, request, session);
	}

	/***
	 * 答题卡(开始答题，继续答题)
	 * 
	 * @param session
	 * @return
	 */
	@RequestMapping("/card")
	public ModelAndView index(String paperid, String roomId, HttpServletRequest request, HttpSession session) {
		try {
			LoginUser user = getCurrentUser(session);
			Room room = roomServiceImpl.getRoomEntity(roomId);
			if (room.getWritetype().equals("2")) {
				// 匿名考场
				user = roomServiceImpl.getAnonymous(session);
			}
			ViewMode view = ViewMode.getInstance();
			// 进入答题室：1.判断时间，判断人员
			if (!roomServiceImpl.isLiveTimeRoom(room)) {
				throw new RuntimeException("该房间不可用，未到答题时间!");
			}
			if (user == null) {
				throw new RuntimeException("请先登陆系统!");
			}
			if (!roomServiceImpl.isUserAbleRoom(room.getId(), user)) {
				throw new RuntimeException("当前用户无进入权限!");
			}
			PaperUnit paper = paperServiceImpl.getPaperUnit(paperid);
			// 创建答题卡
			Card card = cardServiceImpl.creatOrGetCard(paperid, roomId, user);
			// 从答题卡中加载用户答案
			cardServiceImpl.loadCardVal(paper, card);
			if (!card.getPstate().equals("1")) {
				throw new RuntimeException("该试卷非答题状态!");
			}
			try {
				// 计算当前时间到结束时间之间得秒
				SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
				long a = new Date().getTime();
				long b = sdf.parse(card.getEndtime()).getTime();
				int c = (int) ((b - a - 5) / 1000);
				view.putAttr("CountDownSecond", c);
			} catch (Exception e) {
				log.warn(e.getMessage(), e);
				view.putAttr("CountDownSecond", 0);
			}
			return view.putAttr("paper", paper).putAttr("flag", "answer").putAttr("room", room).putAttr("card", card)
					.returnModelAndView(getThemePath() + "/paper/card");
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnModelAndView(getThemePath() + "/error");
		}
	}

	/**
	 * 暂存用户一道题答案
	 * 
	 * @return
	 */
	@RequestMapping("/PubsaveSubjectVal")
	@ResponseBody
	public Map<String, Object> pubSaveSubjectVal(String paperid, String roomid, String jsons, HttpSession session) {
		try {
			LoginUser user = getCurrentUser(session);
			ViewMode page = ViewMode.getInstance();
			JsonParser parse = new JsonParser(); // 创建json解析器
			JsonObject json = (JsonObject) parse.parse(jsons);
			String versionid = json.get("versionid").getAsString();
			String answerid = json.get("answerid").getAsString();
			String value = json.get("value").getAsString();
			if (StringUtils.isNotBlank(value)) {
				value = AntiXSS.replaceHtmlCode(value);
			}
			Room room = roomServiceImpl.getRoomEntity(roomid);
			if (room.getWritetype().equals("2")) {
				user = roomServiceImpl.getAnonymous(session);
			}
			Card card = cardServiceImpl.loadCard(paperid, roomid, user.getId());
			if (!cardServiceImpl.isAnswerAble(card)) {
				return ViewMode.getInstance().setError("OUTTIME", new RuntimeException("答題卡超時，强制提交！")).returnObjMode();
			}
			boolean isAnswer = cardServiceImpl.saveCardVal(card, versionid, answerid, value);
			return page.putAttr("isAnswer", isAnswer).returnObjMode();
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnObjMode();
		}
	}

	/**
	 * 暂存试卷答案
	 * 
	 * @return
	 */
	@RequestMapping("/PubsavePaperVal")
	@ResponseBody
	public Map<String, Object> savePaperVal(String paperid, String roomid, String jsons, HttpSession session) {
		try {
			ViewMode page = ViewMode.getInstance();
			JsonParser parse = new JsonParser(); // 创建json解析器
			JsonArray jsonArray = (JsonArray) parse.parse(jsons);
			LoginUser user = getCurrentUser(session);
			Room room = roomServiceImpl.getRoomEntity(roomid);
			if (room.getWritetype().equals("2")) {
				// 匿名答题的room，中使用匿名用户进行数据保存
				user = roomServiceImpl.getAnonymous(session);
			}
			Card card = cardServiceImpl.loadCard(paperid, roomid, user.getId());
			if (!cardServiceImpl.isAnswerAble(card)) {
				return ViewMode.getInstance().setError("OUTTIME", new RuntimeException("答題卡超時，强制提交！")).returnObjMode();
			}
			for (JsonElement obj : jsonArray) {
				JsonObject sjonObj = obj.getAsJsonObject();
				String versionid = sjonObj.get("versionid").getAsString();
				String answerid = sjonObj.get("answerid").getAsString();
				String value = sjonObj.get("value").getAsString();
				if (StringUtils.isNotBlank(value)) {
					value = AntiXSS.replaceHtmlCode(value);
				}
				cardServiceImpl.saveCardVal(card, versionid, answerid, value);
			}
			return page.returnObjMode();
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnObjMode();
		}
	}

	/**
	 * 结束答题提交试卷
	 * 
	 * @param cardId
	 * @param session
	 * @return
	 */
	@RequestMapping("/PubsubmitPaper")
	public ModelAndView pubSubmitPaper(String cardId, HttpSession session) {
		try {
			LoginUser user = getCurrentUser(session);
			ViewMode view = ViewMode.getInstance();
			Card card = cardServiceImpl.getCardEntity(cardId);
			Room room = roomServiceImpl.getRoomEntity(card.getRoomid());
			if (room.getWritetype().equals("2")) {
				// 匿名考场的话，取匿名用户进行答题
				user = roomServiceImpl.getAnonymous(session);
			}
			cardServiceImpl.finishExam(cardId, user);
			if (room.getWritetype().equals("2")) {
				// 匿名考场
				return view.returnRedirectOnlyUrl("/exam/Pubroompage.do?roomid=" + card.getRoomid());
			} else {
				return view.returnRedirectOnlyUrl("/exam/roompage.do?roomid=" + card.getRoomid());
			}
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnModelAndView(getThemePath() + "/error");
		}
	}

	@RequestMapping("/checkUpPaper")
	public ModelAndView checkUpPaper(String cardId, HttpSession session) {
		try {
			ViewMode view = ViewMode.getInstance();
			// 创建答题卡
			Card card = cardServiceImpl.getCardEntity(cardId);
			if (card == null) {
				throw new RuntimeException("未找到答题卡，请确认答题卡是否存在!" + cardId);
			}
			Room room = roomServiceImpl.getRoomEntity(card.getRoomid());
			// 从答题卡中加载用户答案
			PaperUnit paper = paperServiceImpl.getPaperUnit(card.getPaperid());
			cardServiceImpl.loadCardVal(paper, card);

			return view.putAttr("paper", paper).putAttr("flag", "checkup").putAttr("room", room).putAttr("card", card)
					.returnModelAndView(getThemePath() + "/paper/paperCheckup");
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnModelAndView(getThemePath() + "/error");
		}
	}

	/**
	 * 清空用户某试卷的答题卡
	 * 
	 * @return
	 */
	@RequestMapping("/PubclearUserPaperCard")
	public ModelAndView pubClearUserPaperCard(String roomid, String paperid, HttpSession session) {
		try {
			ViewMode view = ViewMode.getInstance();
			LoginUser user = getCurrentUser(session);
			Room room = roomServiceImpl.getRoomEntity(roomid);
			if (room.getWritetype().equals("2")) {
				// 匿名考场的话，取匿名用户进行答题
				user = roomServiceImpl.getAnonymous(session);
			}
			cardServiceImpl.clearPaperUserCard(roomid, paperid, user);
			if (room.getWritetype().equals("2")) {
				return view.returnRedirectOnlyUrl("/exam/Pubroompage.do?roomid=" + roomid);
			} else {
				return view.returnRedirectOnlyUrl("/exam/roompage.do?roomid=" + roomid);
			}
		} catch (Exception e) {
			return ViewMode.getInstance().setError(e.getMessage(), e).returnModelAndView(getThemePath() + "/error");
		}
	}
}
