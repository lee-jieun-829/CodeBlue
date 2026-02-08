import axios from "axios";

/**
 * Axios 공통 설정 파일
 * 
 * 작성자 : 김경희
 * 역할 : React에서 백엔드(Spring)로 가는 모든 요청을 담당
 * 
 * 1) LoginSuccessHandler에서 ACCESS_TOKEN 쿠키 발급
 * 2) 쿠키 HttpOnly + SameSite=Lax
 * 3) axios withCredentials: true
 * 4) /api/auth/me에서 @ AuthenticationPrincipal 사용
 * 5) Dashboard에서 res.data.employeeName 사용
 */

// 현재 호스트 기반 url 설정
const SPRING_URL = `${window.location.protocol}//${window.location.hostname}:8060`;

const api = axios.create({
  baseURL: "/api",
  timeout: 10000,
  withCredentials: true
  // 헤더의 content-type 고정된거 지움 (폼데이타 살리기)
});

// 
api.interceptors.request.use(
  (config) => {
    // fomdata 라면 content-type 삭제
    const isFormData =
      config.data instanceof FormData ||
      (typeof FormData !== "undefined" && config.data?.constructor?.name === "FormData");

    if (isFormData) {
      // 멀티파트는 브라우저가 boundary 포함해서 자동 세팅
      if (config.headers) {
        delete config.headers["Content-Type"];
        delete config.headers["content-type"];
      }
    } else {
      // JSON 요청만 명시함 (없어도 axios가 처리하지만 일단 확실하게)
      config.headers = config.headers || {};
      config.headers["Content-Type"] = "application/json";
    }

    console.log(`API 요청 ${config.method.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => Promise.reject(error)
);

// 에러 발생시... 대처하자....
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // 401
    if (error.response && error.response.status === 401) {

      const msg = error.response.data?.message || "로그인 세션 만료";
      alert(msg);
      
      window.location.href = `${SPRING_URL}/login`;
    }
    
    // 403
    if (error.response && error.response.status === 403) {
        const msg = error.response.data?.message || "접근 권한이 없습니다.";
        alert(msg);
    }

    // 그 외 에러
    console.error("API 에러", error);
    return Promise.reject(error);
  }
);

export default api;