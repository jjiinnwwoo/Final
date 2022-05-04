package web.controller;

import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import web.dto.MyPlant;
import web.service.face.MyPlantService;
import web.util.TransDate;

@Controller
@RequestMapping(value = "/myplant")
public class MyPlantController {
	
	private static final Logger logger = LoggerFactory.getLogger(MyPlantController.class);
	
	@Autowired private MyPlantService myPlantService;
	
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String getList(HttpSession session, Model model) {
		
		logger.info("myplant/list [GET]");
		
		session.setAttribute("memberNo", 10000000);
		
		int memberNo =  (int) session.getAttribute("memberNo");
		model.addAttribute("list", myPlantService.list(memberNo));
		
		return "/myplant/list";
		
	}
	
	@RequestMapping(value = "/write", method = RequestMethod.GET)
	public String getWrite() {
		
		logger.info("myplant/write [GET]");
		
		return "/myplant/write";
		
	}
	
	@RequestMapping(value = "/write", method = RequestMethod.POST)
	public String write(HttpSession session, MyPlant myPlant, Model model) {
		
		logger.info("myplant/write [GET]");

		myPlant.setMemberNo((int) session.getAttribute("memberNo"));
		TransDate transDate = new TransDate();
		myPlant.setBirth(transDate.toString2(myPlant.getBirth()));
		
		
		
		return "/myplant/list";
		
	}
	
	@RequestMapping(value = "/alter", method = RequestMethod.GET)
	public String getAlter(Model model) {
		
		logger.info("myplant/alter [GET]");
		
		return "/myplant/change";
		
	}
	
	@RequestMapping(value = "/delete", method = RequestMethod.GET)
	public String drop(String no, Model model) {
		
		logger.info("myplant/delete [GET]");
		
		int myPlantNo = Integer.parseInt(no);
		myPlantService.drop(myPlantNo);
		
		return "redirect:/myplant/list";
		
	}

}
