package kr.or.ddit.cpr.common.util;

import jakarta.servlet.http.HttpServletRequest;

/**
 * <p>HTTP 요청(Request) 관련 유틸</p>
 * <pre>
 * 1. AJAX 요청인지 확인
 * 2. API 요청인지 확인
 * </pre>
 */
public class RequestUtils {
	/**
     * 로그인할때 요청이 AJAX(AXIOS)이거나 API 요청인지 판단
     * @param request HttpServletRequest
     * @return AJAX/API 이면 성공, 일반 jsp form 요청이면 실패
     */
    public static boolean isAjaxOrApi(HttpServletRequest request) {
    	
        String uri = request.getRequestURI();
        String ctx = request.getContextPath();
        
        String xrw = request.getHeader("X-Requested-With");
        String accept = request.getHeader("Accept");

        // '/api' 로 시작하면 (ContextPath)
        boolean isApi = uri.startsWith(ctx + "/api");
        
        // 헤더에 XMLHttpRequest가 있으면 (AXIOS, jQuery 등)
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(xrw);
        
        // 클라이언트가 JSON 응답을 확실하게 원하면
        boolean wantsJson = accept != null && accept.contains("application/json");

        return isApi || isAjax || wantsJson;
    }
}