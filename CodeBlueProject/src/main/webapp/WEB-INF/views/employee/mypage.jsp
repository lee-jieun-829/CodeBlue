<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt"%>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>
<!DOCTYPE html>
<html>
<head>
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp"%>
<!-- ===== Head 끝 ===== -->
<title>마이페이지</title>
</head>
<body data-gnb="dashboard">
	<!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp"%>
	<!-- ===== Header 끝 ===== -->

	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<%@ include file="/WEB-INF/views/common/include/left/left_default.jsp"%>
		<!-- ===== Sidebar 끝 ===== -->

		<!-- ===== Main 시작 ===== -->
		<main class="main-content">
			<div class="grid grid-full-height">
				<!-- 콘텐츠 영역 -->
				<div class="content-area flex">
					<div class="box w-full">
						<section class="rounded-lg bg-white p-6 shadow ring-1 ring-black/5 flex items-start justify-between mb-6">
							<div class="flex items-center gap-6">
								<%-- 프로필 이미지 --%>
								<c:choose>
									<c:when
										test="${not empty employee.fileNo and employee.fileNo gt 0}">
										<img
											src="${pageContext.request.contextPath}/employee/profile/${employee.fileNo}"
											class="rounded-full w-24 h-24 object-cover border-2 border-gray-100 shadow-sm"
											onerror="this.src='https://placehold.co/96x96?text=No+Image'" />
									</c:when>
									<c:otherwise>
										<img src="https://placehold.co/96x96?text=User"
										     class="rounded-full w-24 h-24 object-cover border-2 border-gray-100 shadow-sm" />
									</c:otherwise>
								</c:choose>

								<div class="space-y-2">
									<div class="flex items-center gap-3">
										<h2 class="text-2xl font-bold text-gray-900">${employee.employeeName}</h2>

										<%-- 재직 상태  --%>
										<c:choose>
											<c:when
												test="${employee.employeeStatus eq '001' or employee.employeeStatus eq 'Y'}">
												<span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
													재직중
												</span>
											</c:when>
											<c:when
												test="${employee.employeeStatus eq '003' or employee.employeeStatus eq 'L'}">
												<span class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20">
													휴직
												</span>
											</c:when>
											<c:when
												test="${employee.employeeStatus eq '002' or employee.employeeStatus eq 'N'}">
												<span class="inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">
													퇴사
												</span>
											</c:when>
											<c:otherwise>
												<span class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">
													상태 미정 (${employee.employeeStatus})
												</span>
											</c:otherwise>
										</c:choose>

										<%-- 계정 활성 상태 --%>
										<c:choose>
											<c:when test="${employee.enabled eq '1' or employee.enabled eq 'Y' or employee.enabled eq 'true'}">
												<span class="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
													계정 활성
												</span>
											</c:when>
											<c:otherwise>
												<span class="inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-500 ring-1 ring-inset ring-gray-400/20">
													계정 잠금
													</span>
											</c:otherwise>
										</c:choose>
									</div>

									<div class="text-sm text-gray-500 space-y-1">
										<p class="flex items-center gap-2">
											<span class="font-semibold text-gray-700"> 사번:</span>
											${employee.employeeNo} <span class="w-px h-3 bg-gray-300 mx-1"></span> <span
												class="font-semibold text-blue-600"> <c:choose>
													<c:when test="${not empty employee.employeeCode}">
														${employee.employeeCode}
													</c:when>

													<c:when test="${not empty employee.authList}">
														<c:set var="firstAuth"
															value="${employee.authList[0].auth}" />
														<c:choose>
															<c:when test="${firstAuth eq 'ROLE_DOCTOR'}">의사</c:when>
															<c:when test="${firstAuth eq 'ROLE_NURSE_OUT'}">외래간호사</c:when>
															<c:when test="${firstAuth eq 'ROLE_NURSE_IN'}">입원간호사</c:when>
															<c:when test="${firstAuth eq 'ROLE_PHARMACIST'}">약사</c:when>
															<c:when test="${firstAuth eq 'ROLE_RADIOLOGIST'}">방사선사</c:when>
															<c:when test="${firstAuth eq 'ROLE_THERAPIST'}">물리치료사</c:when>
															<c:when test="${firstAuth eq 'ROLE_OFFICE'}">원무과</c:when>
															<c:when test="${firstAuth eq 'ROLE_ADMIN'}">관리자</c:when>
															<c:otherwise>직원</c:otherwise>
														</c:choose>
													</c:when>
													<c:otherwise>직원</c:otherwise>
												</c:choose>
											</span>
										</p>
										<p class="flex items-center gap-2">
											<i class="fa-regular fa-hospital"></i>
											<span>소속 : SB 정형외과</span>
										</p>
									</div>
								</div>
							</div>

							<button id="pwBtn" onclick="openModal()" class="h-10 rounded-lg bg-blue-600 px-6 text-sm font-semibold text-white">
								비밀번호 변경
							</button>
						</section>

						<section class="grid grid-cols-12 gap-6">

							<div class="col-span-12 lg:col-span-5 space-y-4">
								<div
									class="rounded-lg bg-white p-6 shadow ring-1 ring-black/5 h-full">
									<h3 class="mb-5 text-lg font-bold text-gray-800 border-b pb-3 border-gray-100">기본
										정보</h3>

									<div class="space-y-4 text-sm">
										<div class="flex justify-between items-center">
											<span class="text-neutral-500 w-24">전화번호</span> <span
												class="font-medium text-gray-900 flex-1 text-right">${employee.employeeTel}</span>
										</div>
										<div class="flex justify-between items-center">
											<span class="text-neutral-500 w-24">이메일</span> <span
												class="font-medium text-gray-900 flex-1 text-right">${employee.employeeEmail}</span>
										</div>

										<div class="flex justify-between items-center">
											<span class="text-neutral-500 w-24">생년월일</span> <span
												class="font-medium text-gray-900 flex-1 text-right">
												<%-- 생년월일 --%>
												<c:choose>
													<c:when test="${not empty employee.employeeBirth and fn:contains(employee.employeeBirth, '-')}">
														${employee.employeeBirth}
													</c:when>
													<c:when test="${not empty employee.employeeBirth and fn:length(employee.employeeBirth) eq 8}">
														${fn:substring(employee.employeeBirth, 0, 4)}.${fn:substring(employee.employeeBirth, 4, 6)}.${fn:substring(employee.employeeBirth, 6, 8)}
													</c:when>
													<c:otherwise>
														<span class="text-gray-400">정보 없음</span>
													</c:otherwise>
												</c:choose>
											</span>
										</div>

										<div class="flex justify-between items-center">
											<span class="text-neutral-500 w-24">성별</span>
											<span class="font-medium text-gray-900 flex-1 text-right">
												<c:choose>
													<c:when test="${employee.employeeGen eq 'M'}">남자</c:when>
													<c:when test="${employee.employeeGen eq 'F'}">여자</c:when>
													<c:otherwise>
														<span class="text-gray-400">정보 없음</span>
													</c:otherwise>
												</c:choose>
											</span>
										</div>

										<hr class="border-gray-100 my-2" />

										<div class="flex justify-between items-center">
											<span class="text-neutral-500 w-24">입사일</span>
											<span class="font-medium text-blue-600 flex-1 text-right">
												<fmt:formatDate value="${employee.employeeRegdate}" pattern="yyyy-MM-dd" />
											</span>
										</div>

										<c:if test="${not empty employee.employeeRetdate}">
											<div class="flex justify-between items-center">
												<span class="text-neutral-500 w-24">퇴사일</span>
												<span class="font-medium text-red-500 flex-1 text-right">
													<fmt:formatDate value="${employee.employeeRetdate}" pattern="yyyy-MM-dd" />
												</span>
											</div>
										</c:if>
										
									</div>
								</div>
							</div>

							<div class="col-span-12 lg:col-span-7 space-y-4">
								<div
									class="rounded-lg bg-white p-6 shadow ring-1 ring-black/5 h-full">
									<h3 class="mb-5 text-lg font-bold text-gray-800 border-b pb-3 border-gray-100">
										직무 및 권한
									</h3>

									<div class="space-y-6">
										<div>
											<label class="block text-xs font-medium text-gray-500 mb-1">직무 구분</label>
											<div class="w-full rounded-md border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-900">
												<c:choose>
													<c:when test="${not empty employee.employeeCode}">
				                                        ${employee.employeeCode}
				                                    </c:when>
													<c:when test="${not empty employee.authList}">
														<c:set var="firstAuth" value="${employee.authList[0].auth}" />
														<c:choose>
															<c:when test="${firstAuth eq 'ROLE_DOCTOR'}">의사</c:when>
															<c:when test="${firstAuth eq 'ROLE_NURSE_OUT'}">외래간호사</c:when>
															<c:when test="${firstAuth eq 'ROLE_NURSE_IN'}">입원간호사</c:when>
															<c:when test="${firstAuth eq 'ROLE_PHARMACIST'}">약사</c:when>
															<c:when test="${firstAuth eq 'ROLE_RADIOLOGIST'}">방사선사</c:when>
															<c:when test="${firstAuth eq 'ROLE_THERAPIST'}">물리치료사</c:when>
															<c:when test="${firstAuth eq 'ROLE_OFFICE'}">원무과</c:when>
															<c:when test="${firstAuth eq 'ROLE_ADMIN'}">관리자</c:when>
															<c:otherwise>직원</c:otherwise>
														</c:choose>
													</c:when>
													<c:otherwise>권한이 부여되지 않은 계정입니다.</c:otherwise>
												</c:choose>
											</div>
										</div>

										<%-- 면허 번호 --%>
										<c:if test="${not empty employee.employeeDetailLicence}">
											<div>
												<label class="block text-xs font-medium text-gray-500 mb-1">면허 번호</label>
												<div
													class="w-full rounded-md border border-blue-100 bg-blue-50/50 px-3 py-2 text-sm font-semibold text-blue-900 flex items-center justify-between">
													<span>${employee.employeeDetailLicence}</span>
													<span class="text-[10px] bg-blue-200 text-blue-800 px-1.5 py-0.5 rounded">등록됨</span>
												</div>
											</div>
										</c:if>

										<div>
											<label class="block text-xs font-medium text-gray-500 mb-2">보유 권한</label>
											<div class="flex flex-wrap gap-2">
												<c:choose>
													<c:when test="${not empty employee.authList}">
														<c:forEach var="authVO" items="${employee.authList}">
															<span class="inline-flex items-center gap-1 rounded-full bg-purple-50 px-3 py-1 text-xs font-medium text-purple-700 ring-1 ring-inset ring-purple-700/10">
																<span class="w-1.5 h-1.5 rounded-full bg-purple-500"></span>
																<c:choose>
																	<c:when test="${authVO.auth eq 'ROLE_DOCTOR'}">의사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_NURSE_OUT'}">외래간호사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_NURSE_IN'}">입원간호사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_PHARMACIST'}">약사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_RADIOLOGIST'}">방사선사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_THERAPIST'}">물리치료사</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_OFFICE'}">원무과</c:when>
																	<c:when test="${authVO.auth eq 'ROLE_ADMIN'}">관리자</c:when>
																	<c:otherwise>${fn:replace(authVO.auth, 'ROLE_', '')}</c:otherwise>
																</c:choose>
															</span>
														</c:forEach>
													</c:when>
													<c:otherwise>
														<span class="text-sm text-gray-400">부여된 권한이 없습니다.</span>
													</c:otherwise>
												</c:choose>
											</div>
										</div>

									</div>
								</div>
							</div>
						</section>

					</div>
				</div>
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	
	<!-- PASSWORD MODAL -->
	<div id="pwModal" class="fixed inset-0 z-50 hidden flex items-center justify-center bg-black/50">

		<!-- step 0 : 현재 비밀번호 체크 -->
		<div id="pwStep0" class="w-[420px] rounded-2xl bg-white p-6 shadow-xl">
			<h3 class="mb-1 text-lg font-bold">비밀번호 확인</h3>
			<p class="mb-4 text-sm text-neutral-500">변경을 위해 현재 비밀번호를 입력해주세요.</p>
			
			<input type="password" id="currentPw" class="mb-1 w-full rounded-lg border px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="현재 비밀번호" />
			<p id="step0Msg" class="mb-4 text-xs text-red-500 h-4"></p>
			
			<div class="flex justify-end gap-2">
				<button onclick="closeModal()" class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">취소</button>
				<button onclick="checkCurrentPw()" class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">확인</button>
			</div>
		</div>

		<!-- step 1-a : 인증번호 발송하기 -->
		<div id="pwStep1" class="hidden w-[420px] rounded-2xl bg-white p-6 shadow-xl">
			<h3 class="mb-1 text-lg font-bold">이메일 인증</h3>

			<p class="mb-4 text-sm text-neutral-500">보안을 위해 등록된 이메일로 인증번호를 발송합니다.</p>

			<div class="flex gap-2 mb-1">

				<div class="flex-1">
					<input type="text" id="authCode" disabled placeholder="인증번호 6자리"
						class="w-full rounded-lg border border-gray-300 px-3 py-2 text-center text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-50 disabled:text-gray-400 transition-all" />
				</div>

				<button onclick="sendAuthCode()" id="sendBtn"
					class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 transition-colors whitespace-nowrap shadow-sm">
					인증번호 발송</button>
			</div>

			<div class="flex justify-between items-start mb-4 h-4 px-1">
				<span id="timer" class="text-xs text-red-500 hidden pt-0.5"></span>
				<p id="step1Msg" class="text-xs text-blue-600 pt-0.5 flex-1 text-right"></p>
			</div>

			<div class="flex justify-end gap-2">
				<button onclick="closeModal()"
					class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
					취소
				</button>
				<button onclick="verifyAuthCode()" id="nextBtn" disabled
					class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-all shadow-sm">
					확인
				</button>
			</div>
		</div>

		<!-- step 2 : 새로운 비밀번호 입력 -->
		<div id="pwStep2" class="hidden w-[420px] rounded-2xl bg-white p-6 shadow-xl">
			<h3 class="mb-1 text-lg font-bold">비밀번호 변경</h3>
			
			<p class="mb-4 text-sm text-neutral-500">새 비밀번호를 입력해주세요.</p>
			
			<input id="newPw" type="password" placeholder="새로운 비밀번호"
				   class="mb-3 w-full rounded-lg border px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" /> 
				
			<input id="confirmPw" type="password" placeholder="새로운 비밀번호 확인"
				   class="mb-1 w-full rounded-lg border px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" />
				
			<p id="step2Msg" class="mb-4 text-xs text-red-500 h-4"></p>

			<div class="flex justify-end gap-2">
				<button onclick="closeModal()" class="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg">
					취소
				</button>
				
				<button onclick="updatePassword()" class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
					변경하기
				</button>
			</div>
		</div>

		<!-- step 3 : 변경 완료 창 -->
		<div id="pwStep3" class="hidden w-[420px] rounded-2xl bg-white p-6 text-center shadow-xl">
			<div class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-blue-50">
				<svg class="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
  					<path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
				</svg>
			</div>

			<h3 class="mb-2 text-lg font-bold">변경 완료</h3>
			<p class="mb-6 text-sm text-neutral-500 leading-relaxed">
				비밀번호가 성공적으로 변경되었습니다.<br>
				<span id="countdown" class="font-bold text-blue-600 text-lg">5</span>초 후 로그인 화면으로 이동합니다.
			</p>
			<button onclick="closeModal()" class="w-full rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">
				지금 로그인 하러 가기
			</button>
		</div>
	</div>
<script>
// axios 설정
const ctx = '${pageContext.request.contextPath}';

const api = axios.create({
	  baseURL: ctx + '/api/auth',
	  withCredentials: true,
	  timeout: 10000
	});

// 에러 처리
api.interceptors.response.use(
        res => res,
        err => {
            const status = err.response?.status;
            const msg = err.response?.data?.msg || err.response?.data?.message || "오류 발생";
            
            if (status === 401) {
                alert("세션 만료. 다시 로그인해주세요.");
                location.href = ctx + "/login";
                return Promise.reject(err);
            }
            if (status === 403) {
                alert("권한이 없습니다.");
                return Promise.reject(err);
            }
            return Promise.reject(err);
        }
    );
    
let timerInterval = null;

// 모달 관련 함수 - 열기
function openModal(){
	resetModal();
	const modal = document.getElementById('pwModal');
	modal.classList.remove('hidden');
	modal.classList.add('flex');
	document.getElementById('currentPw').focus();
}

// 모달 관련 함수 - 닫기
function closeModal(){
	const modal = document.getElementById('pwModal');
	modal.classList.add('hidden');
	modal.classList.remove('flex');
	resetModal();
}

// 모달 관련 함수 - 초기화
function resetModal(){
	
	// step 0 만 보여주고 나머지는 전부 숨김
	document.getElementById('pwStep0').classList.remove('hidden');
	document.getElementById('pwStep1').classList.add('hidden');
	document.getElementById('pwStep2').classList.add('hidden');
	document.getElementById('pwStep3').classList.add('hidden');
	
	// 입력값 초기화
	document.getElementById('currentPw').value = '';
	document.getElementById('authCode').value = '';
	document.getElementById('newPw').value = '';
	document.getElementById('confirmPw').value = '';
	
	// 메세지 초기화
	document.getElementById('step0Msg').textContent = '';
	document.getElementById('step1Msg').textContent = '';
	document.getElementById('step2Msg').textContent = '';
	
	// 타이머 초기화
	clearInterval(timerInterval);
	document.getElementById('timer').classList.add('hidden');
	
	// 전송 버튼 초기화
	const sendBtn = document.getElementById('sendBtn');
	sendBtn.disabled = false;
	sendBtn.textContent = '인증번호 발송';
	
	// 다음 버튼 초기화
	const nextBtn = document.getElementById('nextBtn');
	nextBtn.disabled = true;
	nextBtn.classList.add('bg-gray-300', 'cursor-not-allowed');
	nextBtn.classList.remove('bg-blue-600', 'hover:bg-blue-700');
}

// step 0 :: 현재 비밀번호 일치 체크
async function checkCurrentPw(){
	// 값 가져오기
	const currentPw = document.getElementById('currentPw').value;
	const msgBox = document.getElementById('step0Msg');
	
	if(!currentPw){
		msgBox.textContent = '비밀번호 입력하세용~';
		msgBox.classList.add('text-red-500');
		return;
	}
	
	
	try{
		await api.post('/checkpw', {currentPw});
		// 성공시 1 오픈 (0 숨김)
		document.getElementById('pwStep0').classList.add('hidden');
        document.getElementById('pwStep1').classList.remove('hidden');
	}catch(err){
		const msg = err?.response?.data?.msg || '현재 비밀번호랑 일치하지 않아요';
		msgBox.textContent = msg;
		msgBox.classList.add('text-red-500');
	}
}

// step 1 :: 인증 번호 발송 및 체크
async function sendAuthCode(){
	const sendBtn = document.getElementById('sendBtn');
	const msgBox = document.getElementById('step1Msg');
	
	sendBtn.disabled = true;
    sendBtn.textContent = '인증번호 재발급';
	msgBox.textContent = '발송중..';
	msgBox.classList.remove('text-red-500', 'text-blue-500');
    msgBox.classList.add('text-gray-500');
	
	try{
		await api.post('/sendAuthCode');
		
		msgBox.textContent = '발송 완료';
		msgBox.classList.remove('text-gray-500');
		msgBox.classList.add('text-blue-500');
		
		document.getElementById('authCode').disabled = false;
        document.getElementById('authCode').focus();
        
        // 다음 버튼
        const nextBtn = document.getElementById('nextBtn');
        nextBtn.disabled = false;
        nextBtn.classList.remove('bg-gray-300', 'cursor-not-allowed');
        nextBtn.classList.add('bg-blue-600', 'hover:bg-blue-700');

        sendBtn.textContent = '인증번호 재발급';
        
        // 5초 뒤에 버튼 활성화
        setTimeout(function() {
        	sendBtn.disabled = false;
        	}, 5000);
        
        // 3분 타이머 시작
        startTimer(180);
        
	}catch (err) {
        const msg = err.response?.data?.msg || '메일 발송 실패';
        msgBox.textContent = msg;
        msgBox.classList.add('text-red-500');
        
        // 실패시 바로 누를수 있게 false 처리
        sendBtn.textContent = '인증번호 발송';
        sendBtn.disabled = false;
    }
}

// 타이머 시작
function startTimer(duration){
	let timer = duration;
	const display = document.getElementById('timer');
	display.classList.remove('hidden');
	
	clearInterval(timerInterval);
	
	timerInterval = setInterval(function (){
		const minutes = String(Math.floor(timer/60)).padStart(2, '0');
		const seconds = String(timer%60).padStart(2, '0');
		
		display.textContent = `${minutes}:${seconds}`;
		
		// 초과시
		if(--timer < 0){
			clearInterval(timerInterval);
			display.textContent = '시간이 초과되었습니당';
			document.getElementById('nextBtn').disabled = true;
			
			const msgBox = document.getElementById('step1Msg');
			msgBox.innerText = '인증 시간이 끝났습니다, \n다시 진행해주세용';
			msgBox.classList.add('text-red-500');
		}
	}, 1000);
}

// step 1-b :: 인증 번호 체크
async function verifyAuthCode(){
	const code = document.getElementById('authCode').value;
	
	if(!code) {alert("인증번호를 입력하세용"); return;}
	
	try{
		await api.post('/verifyAuthCode', {code});
		
		clearInterval(timerInterval);
		document.getElementById('pwStep1').classList.add('hidden');
		document.getElementById('pwStep2').classList.remove('hidden');
	}catch (err) {
        const msg = err.response?.data?.msg || '인증번호 불일치';
        alert(msg);
	}
}

// 변경완료 후 로그인창 이동 타이머
let redirectTimer = null;

//step 2 :: 새로운 비밀번호 업데이트
async function updatePassword() {
    const newPw = document.getElementById('newPw').value;
    const confirmPw = document.getElementById('confirmPw').value;
    const msgBox = document.getElementById('step2Msg');

    if(!newPw || !confirmPw) {
        msgBox.textContent = '비밀번호를 모두 입력해주세요.';
        msgBox.classList.add('text-red-500');
        return;
    }

    if(newPw !== confirmPw) {
        msgBox.textContent = '비밀번호가 일치하지 않습니다.';
        msgBox.classList.add('text-red-500');
        return;
    }

    try {
        await api.post('/updatepw', {newPw});
        
        document.getElementById('pwStep2').classList.add('hidden');
        document.getElementById('pwStep3').classList.remove('hidden');
        
        // 로그인 페이지 이동 (5초)
        startRedirectCountdown(5);
        
    } catch (err) {
        const msg = err.response?.data?.msg || '비밀번호 변경 실패';
        msgBox.textContent = msg;
        msgBox.classList.add('text-red-500');
    }
}

// 5초 리다이렉트 타이머 함수
function startRedirectCountdown(seconds) {
    let count = seconds;
    const countdownSpan = document.getElementById('countdown');
    
    redirectTimer = setInterval(function() {
        count--;
        countdownSpan.textContent = count;
        
        if (count <= 0) {
            backToLoginform();
        }
    }, 1000);
}

// 로그인 페이지로 이동
function backToLoginform() {
    clearInterval(redirectTimer);
    location.href = ctx + "/login";
}
</script>
</body>
</html>