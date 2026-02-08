import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  define: {
    // sockjs-client 에러 해결을 위한 global 정의
    global: 'window',
  },
  server:{
    host: "0.0.0.0",
    port: 5173,
    // Proxy 설정 추가, 참고(https://velog.io/@lhhl1029/ReactVite-Cors%EB%B0%A9%EC%A7%80%EB%A5%BC-%EC%9C%84%ED%95%9C-Proxy%EC%82%AC%EC%9A%A9)
    proxy:{
      '/api': {
        // back-end server port
        target: 'http://localhost:8060',
        // 호스트 헤더를 target url 로 변경 (CORS 발생 막기위해서~)
        changeOrigin: true, 
        // 요청 보낼 때 '/api'를 제거
        //rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})