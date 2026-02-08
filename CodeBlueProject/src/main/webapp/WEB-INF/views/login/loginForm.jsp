<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Cold Blue EMR | 로그인</title>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" as="style" crossorigin href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css" />
<style>
html, body { height: 100%;}
body {font-family: "Pretendard", sans-serif;}
</style>
</head>
<body class="bg-white text-zinc-950 min-h-screen">
<c:set var="ctx" value="${pageContext.request.contextPath}" /> 
<div class="min-h-screen flex items-center justify-center px-8 py-10">
	<div class="w-full max-w-[1400px]">
		<div class="grid grid-cols-1 lg:grid-cols-[820px_350px] gap-20 items-center justify-center">

		<!-- 좌측 일러스트 -->
		<section class="hidden lg:block -ml-40">
			<div class="w-[840px] rounded-2xl">
				<img src="${ctx}/resources/assets/images/login.png" alt="Login Illustration" class="w-full h-auto block" />
			</div>
		</section>


			<!-- 우측 로그인폼 -->
			<section class="w-full max-w-[460px] justify-self-center lg:justify-self-start lg:pt-16 lg:-ml-16">
				<main class="w-full">
					<div class="flex items-center gap-3">
						<span class="text-4xl font-black tracking-tight text-blue-600">SB</span>
						<p class="text-2xl font-black tracking-tight text-zinc-900">정형외과</p>
					</div>

					<hr class="my-5 border-zinc-200" />

					<!-- hr 아래 Login -->
					<h2 class="text-base font-semibold text-zinc-900">Login</h2>

					<c:if test="${not empty param.logout}">
						<div class="mt-4 rounded-lg bg-blue-50 p-3 text-sm font-medium text-blue-700 ring-1 ring-blue-200">
							✅ 안전하게 로그아웃 되었습니다.
						</div>
					</c:if>

					<form id="loginForm" class="mt-6 space-y-5" action="${ctx}/login/check" method="post">
						<%-- <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> --%>

						<div>
							<label for="employeeNo" class="block text-sm font-medium text-zinc-700">사번</label>
							<input id="employeeNo" name="employeeNo" type="text" inputmode="numeric" pattern="[0-9]*" required autofocus
								   class="mt-2 h-11 w-full rounded-lg border border-zinc-200 bg-white px-3 text-sm outline-none placeholder:text-zinc-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition" />
							<p id="errNo" class="mt-2 hidden text-sm font-medium text-red-500 flex items-center gap-1">
								<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                   					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                 				</svg>
								사번을 입력해주세요.
							</p>
						</div>

						<div>
							<label for="employeePassword" class="block text-sm font-medium text-zinc-700">비밀번호</label>
							<input id="employeePassword" name="employeePassword" type="password" required
								   class="mt-2 h-11 w-full rounded-lg border border-zinc-200 bg-white px-3 text-sm outline-none placeholder:text-zinc-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition" />
							<p id="errPw" class="mt-2 hidden text-sm font-medium text-red-500 flex items-center gap-1">
								<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
									<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                 				</svg>
								비밀번호를 입력해주세요.
							</p>
						</div>

						<!-- 버튼 -->
						<div class="pt-1">
							<button type="submit" class="h-11 w-full rounded-lg bg-blue-600 text-base font-semibold text-white hover:bg-blue-700 transition shadow-sm">
								Login
							</button>
						</div>

						<div class="pt-1 text-left">
							<button type="button" id="findPw" onclick="findPwModal()" class="text-sm font-medium text-blue-600 hover:text-blue-500 hover:underline">
							  <span class="text-blue-600">비밀번호</span>
							  <span class="text-zinc-900">를 잊어버리셨나요?</span>
							</button>
						</div>
						
						<hr class="my-5 border-zinc-200" />
						
						<p class="pt-4 text-xs text-zinc-600 text-center leading-relaxed whitespace-normal">
							* 로그인 계정 생성 또는 오류 발생 시 관리자에게 문의바랍니다.
						</p>
					</form>
						
						<!-- 프리패스키 -->
						<div class="fixed bottom-6 left-0 w-full flex justify-center pointer-events-none">
						    <div class="bg-white/80 backdrop-blur-sm px-6 py-4 rounded-2xl border border-zinc-100 shadow-xl pointer-events-auto transition-opacity hover:opacity-100 opacity-40">
						        <p class="text-[10px] text-zinc-400 font-bold text-center mb-3 tracking-widest uppercase">*시연용 계정*</p>
						        <div class="grid grid-cols-4 gap-2 w-[320px]">
						            <button type="button" onclick="goDemo('26011906')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">의사</button>
						            <button type="button" onclick="goDemo('25122904')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">간호사</button>
						            <!-- <button type="button" onclick="goDemo('26023908')" class="py-2 text-[11px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">입원간</button> -->
						            <!-- <button type="button" onclick="goDemo('25124903')" class="py-2 text-[11px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">약제실</button> -->
						            
						            <!-- <button type="button" onclick="goDemo('26015905')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">방사실</button> -->
						            <!-- <button type="button" onclick="goDemo('26036910')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">물치실</button> -->
						            <button type="button" onclick="goDemo('26037909')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">원무과</button>
						            <button type="button" onclick="goDemo('26020907')" class="py-2 text-[12px] text-zinc-500 bg-white border border-zinc-200 rounded-lg hover:bg-blue-600 hover:text-white hover:border-blue-600 transition-all font-medium shadow-sm">관리자</button>
						        </div>
						    </div>
						</div>						
						
						
						<!-- 프리패스키 -->
				</main>
			</section>

		</div>
	</div>
</div>

	<c:if test="${not empty param.error}">
		<div id="errorModal" class="fixed inset-0 z-50 flex items-center justify-center">
			<div class="absolute inset-0 bg-black/40 backdrop-blur-sm"></div>

			<div class="relative w-[92%] max-w-sm rounded-2xl bg-white p-8 shadow-2xl ring-1 ring-black/5">
				<div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-red-50 ring-4 ring-red-50">
					<svg class="h-8 w-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
            			<path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          			</svg>
				</div>

				<div class="mt-5 text-center">
					<p class="text-lg font-bold text-gray-900">등록된 사용자가 없습니다.</p>
					<p class="mt-2 text-sm text-gray-500">정확한 정보를 입력해주세요.<br/> 계정이 없을 경우, 관리자에게 요청 바랍니다. </p>
				</div>

				<button type="button" onclick="closeModal()" class="w-full mt-6 flex h-11 items-center justify-center rounded-lg bg-blue-600 text-base font-semibold text-white hover:bg-blue-700 transition shadow-lg shadow-blue-600/20">
					확인
				</button>
			</div>
		</div>
	</c:if>

<div id="findPwModal" class="hidden fixed inset-0 z-[60] flex items-center justify-center">
    <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeFindPwModal()"></div>

    <div class="relative w-[92%] max-w-[460px] bg-white rounded-2xl shadow-2xl overflow-hidden p-8 transition-all">
        <button type="button" onclick="closeFindPwModal()" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>

        <div id="fp-step-input">
            <h3 class="text-xl font-bold text-gray-900 mb-2">비밀번호 찾기</h3>
            <p class="text-sm text-gray-500 mb-6">사번과 계정 등록 시 사용한 이메일 주소를 입력해주세요.</p>
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">사번</label>
                    <input type="text" id="fpEmployeeNo" placeholder="사번을 입력하세요" 
                           oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                           class="w-full h-11 rounded-lg border border-gray-300 px-3 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 outline-none transition" />
                    <p id="fpErrNo" class="hidden mt-1 text-xs text-red-500 flex items-center gap-1">⚠️ 사번을 입력해주세요.</p>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">이메일 주소</label>
                    <input type="email" id="fpEmail" placeholder="example@hospital.com" 
                           class="w-full h-11 rounded-lg border border-gray-300 px-3 text-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 outline-none transition" />
                    <p id="fpErrEmail" class="hidden mt-1 text-xs text-red-500 flex items-center gap-1">⚠️ 이메일 주소를 입력해주세요.</p>
                </div>
            </div>
            <div class="mt-8 flex gap-3 justify-end">
                <button onclick="closeFindPwModal()" class="px-5 py-2.5 rounded-lg border border-gray-300 text-gray-700 font-medium hover:bg-gray-50 text-sm transition">취소</button>
                <button onclick="submitFindPw()" class="px-5 py-2.5 rounded-lg bg-blue-600 text-white font-bold hover:bg-blue-700 text-sm transition shadow-md shadow-blue-500/20">확인</button>
            </div>
        </div>

        <div id="fp-step-fail" class="hidden text-center py-4">
            <div class="mx-auto w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mb-4 ring-4 ring-red-50">
                <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </div>
            <h3 class="text-lg font-bold text-red-500 mb-1">등록된 사용자가 없습니다.</h3>
            <p class="text-sm text-gray-500 mb-8">정확한 정보를 입력해주세요.</p>
            <button onclick="retryFindPw()" class="w-full py-3 rounded-lg bg-blue-600 text-white font-bold hover:bg-blue-700 transition">확인</button>
        </div>

        <div id="fp-step-success" class="hidden text-center py-4">
            <div class="mx-auto w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mb-4 ring-4 ring-green-50">
                <svg class="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            </div>
            <h3 class="text-lg font-bold text-green-600 mb-1">임시 비밀번호 전송 완료</h3>
            <p class="text-sm text-gray-500 mb-8">등록된 <span class="text-gray-900 font-bold">E-mail 주소</span>로<br/>임시 비밀번호가 전송되었습니다.</p>
            <button onclick="closeFindPwModal()" class="w-full py-3 rounded-lg bg-gray-100 text-gray-700 font-bold hover:bg-gray-200 transition">닫기</button>
        </div>
    </div>
</div>
<spring:eval expression="@environment.getProperty('cpr.demo.master-pw')" var="demoPw" />
<script>
// 오류 모달창 닫기 버튼
function closeModal() {
	const m = document.getElementById('errorModal');
	if (m) m.remove();
}

// 로그인
document.getElementById('loginForm').addEventListener('submit',function(e) {
	const no = document.getElementById('employeeNo');
	const pw = document.getElementById('employeePassword');
	const errNo = document.getElementById('errNo');
	const errPw = document.getElementById('errPw');

	let ok = true;

	if (no.value)
		no.value = no.value.replace(/[^0-9]/g, '');

	if (!no.value.trim()) {
		errNo.classList.remove('hidden');
		no.classList.add('ring-2', 'ring-red-500/20', 'border-red-500');
		ok = false;
	} else {
		errNo.classList.add('hidden');
		no.classList.remove('ring-2', 'ring-red-500/20', 'border-red-500');
	}

	if (!pw.value.trim()) {
		errPw.classList.remove('hidden');
		pw.classList.add('ring-2', 'ring-red-500/20', 'border-red-500');
		ok = false;
	} else {
		errPw.classList.add('hidden');
		pw.classList.remove('ring-2', 'ring-red-500/20', 'border-red-500');
	}

	if (!ok)
		e.preventDefault();
});

// 비밀번호 찾기 모달
function findPwModal() {
    const modal = document.getElementById('findPwModal');
    
    // 화면 초기화
    document.getElementById('fp-step-input').classList.remove('hidden');
    document.getElementById('fp-step-fail').classList.add('hidden');
    document.getElementById('fp-step-success').classList.add('hidden');
    
    // 입력값 초기화
    document.getElementById('fpEmployeeNo').value = '';
    document.getElementById('fpEmail').value = '';
    document.getElementById('fpErrNo').classList.add('hidden');
    document.getElementById('fpErrEmail').classList.add('hidden');
    
    modal.classList.remove('hidden');
}

//모달 닫기
function closeFindPwModal() {
    document.getElementById('findPwModal').classList.add('hidden');
}

// 실패 시 재시도
function retryFindPw() {
    document.getElementById('fp-step-fail').classList.add('hidden');
    document.getElementById('fp-step-input').classList.remove('hidden');
}

// 전송 (Axios)
function submitFindPw() {
    const empNo = document.getElementById('fpEmployeeNo');
    const email = document.getElementById('fpEmail');
    const errNo = document.getElementById('fpErrNo');
    const errEmail = document.getElementById('fpErrEmail');

    let isValid = true;
    
    // 유효성 체크
    if (!empNo.value.trim()) {
        errNo.classList.remove('hidden');
        empNo.classList.add('border-red-500');
        isValid = false;
    } else {
        errNo.classList.add('hidden');
        empNo.classList.remove('border-red-500');
    }

    if (!email.value.trim()) {
        errEmail.classList.remove('hidden');
        email.classList.add('border-red-500');
        isValid = false;
    } else {
        errEmail.classList.add('hidden');
        email.classList.remove('border-red-500');
    }

    if (!isValid) return;

// Axios 요청
const requestData = { employeeNo: empNo.value, employeeEmail: email.value };
const csrfTokenInput = document.querySelector('input[name="_csrf"]');
const headers = {};

if (csrfTokenInput) headers['X-CSRF-TOKEN'] = csrfTokenInput.value;

axios.post('${ctx}/api/auth/findpw', requestData, { headers: headers })
    .then(response => {
        document.getElementById('fp-step-input').classList.add('hidden');
        document.getElementById('fp-step-success').classList.remove('hidden');
    })
    .catch(error => {
        console.error(error);
        document.getElementById('fp-step-input').classList.add('hidden');
        document.getElementById('fp-step-fail').classList.remove('hidden');
    });
}

// 프리패스키(마스터키) 버튼 함수
function goDemo(empNo) {
    const noInput = document.getElementById('employeeNo');
    const pwInput = document.getElementById('employeePassword');
    const form = document.getElementById('loginForm');

    if (noInput && pwInput && form) {
        noInput.value = empNo;
        
     	// spring:eval로 읽어온 변수를 사용
        pwInput.value = "${demoPw}";
        
        form.submit();
    }
}
</script>
</body>
</html>