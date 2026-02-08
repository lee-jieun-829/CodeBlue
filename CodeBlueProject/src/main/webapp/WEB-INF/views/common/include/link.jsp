<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="_csrf" content="${_csrf.token}"/>
<meta name="_csrf_header" content="${_csrf.headerName}"/>

<!-- // Javascript Library // -->
<!-- Axios -->
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<!-- Jquery -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

<!-- Bootstrap -->
<%-- <script src="${pageContext.request.contextPath }/resources/assets/js/lib/bootstrap.min.js"></script> --%>

<!-- Tailwind -->
<script src="https://cdn.tailwindcss.com"></script>
<script>
tailwind.config = {corePlugins: { preflight: false }}
</script>

<!-- SockJS -->
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.5.1/dist/sockjs.min.js"></script>

<!-- STOMP -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.2/stomp.min.js" integrity="sha512-iKDtgDyTHjAitUDdLljGhenhPwrbBfqTKWO1mkhSFH3A7blITC9MhYon6SjnMhp4o0rADGw9yAC6EW4t5a4K3g==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

<!-- Fullcalendar  -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.css">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/locales-all.js"></script>

<!-- chart -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>

<!-- d3 -->
<script src="https://cdn.jsdelivr.net/npm/d3@7.9.0/dist/d3.min.js"></script>

<!-- // custom Javascript // -->
<script src="${pageContext.request.contextPath }/resources/assets/js/common.js" defer></script>

<!-- // custom css // -->
<%-- <link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/lib/bootstrap.min.css"> --%>
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/common/common.css">
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/common/design-tokens.css">
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/common/icon.css">

<!-- // messenger //  -->
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/pages/chat.css">
<script src="${pageContext.request.contextPath }/resources/assets/js/messenger.js"></script>

<!-- sweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.26.17/dist/sweetalert2.all.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.26.17/dist/sweetalert2.min.css">