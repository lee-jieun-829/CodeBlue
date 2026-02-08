package kr.or.ddit.cpr.common.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import kr.or.ddit.cpr.notification.handler.NotificationWebSocketHandler;
import kr.or.ddit.cpr.vo.AlertVO;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/commonws/api")
public class CommonWSRestController {

	@Autowired
    private NotificationWebSocketHandler handler;


	@PostMapping("/receptionUpdate")
	public ResponseEntity<String> receptionUpdate(){
		
		AlertVO alertVO = new AlertVO();
		alertVO.setAlertType("RECEPTION_UPDATE");
		alertVO.setAlertContent("ㅎㅅㅎ");
		// ObjectMapper를 사용하여 alertVO 객체를 JSON 문자열로 변환
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			String jsonMsg = objectMapper.writeValueAsString(alertVO);
			handler.sendNotificationToAll(jsonMsg);
		} catch (JsonProcessingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
		return new ResponseEntity<>("테스트입니다.",HttpStatus.OK);
	}
}
