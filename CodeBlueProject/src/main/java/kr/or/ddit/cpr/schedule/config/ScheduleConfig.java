package kr.or.ddit.cpr.schedule.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ScheduleConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")             // 모든 주소에 대해
                .allowedOrigins("http://localhost:5173") // 이 주소(React)의 접속을 허용한다
                .allowedMethods("GET", "POST", "PUT", "DELETE", "INSERT") // 허용할 HTTP 메서드
                .allowCredentials(true);
    }
}