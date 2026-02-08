/**
 * common.js
 * auth : Been Daye
 * date : 2025-12-29
 * desc : header, sidebar 등 공통으로 삽입되는 UI 컴포넌트에 대한 js
 */


// 페이지 로드 완료 후 초기화
document.addEventListener('DOMContentLoaded', function() {
    initApp();
});

function initApp() {
    initDropdowns();
	initGnb();
	checkPwStats();
}

// 임시 비밀번호 여부 체크
async function checkPwStats(){
	try{
		const res = await axios.get('/api/auth/me');
		
		// 임시 비번 사용하면 대시보드로 보냄
		if(res.data.pwTempYn === 'Y'){
			const result = await sweetAlertC({
				icon : "warning",
				title : "접근 제한",
				text: "임시 비밀번호를 사용 중입니다.\n비밀번호 변경 후 이용 가능합니다.",
				confirm: "변경하기",
				showCancel: false,
				allowOutsideClick: false, // 배경 클릭해서 끄는 것 방지
				allowEscapeKey: false    // ESC로 끄는 것 방지
			});
			if (result.isConfirmed) {
				// 로그인 화면으로 이동 + 비밀번호 
				window.location.href = "http://localhost:5173";
			}
			// 사용자가 알림창을 띄워놓고 뒤에 버튼을 누르지 못하게 차단
			document.body.style.pointerEvents = 'none';
		}} catch (error) {
			// 로그인하지 않은 상태에서 /me 호출 시 에러가 날 수 있으니 예외 처리
			console.error("사용자 인증 체크 중 오류 발생:", error);
		}
	}

/**
 * 드롭다운 초기화 (data 속성 방식)
 */
function initDropdowns() {
    const dropdownButtons = document.querySelectorAll('[data-dropdown]');
    
    if (dropdownButtons.length === 0) {
        return;
    }
    
    // 각 드롭다운 버튼에 이벤트 리스너 등록
	dropdownButtons.forEach(button => {
		const dropdownId = button.getAttribute('data-dropdown');
	    const dropdown = document.getElementById(dropdownId);
	        
	    if (!dropdown) return;
	        
	    button.addEventListener('click', function(e) {
	    	e.stopPropagation();
	            
	        const isCurrentlyOpen = dropdown.classList.contains('show');
	            
	        closeAllDropdowns();
	            
	        if (!isCurrentlyOpen) {
	           dropdown.classList.add('show');
			}
	    });
	});
    
    // 외부 클릭 시 모든 드롭다운 닫기
    document.addEventListener('click', closeAllDropdowns);

}

/**
 * 모든 드롭다운 닫기
 */
function closeAllDropdowns() {
    document.querySelectorAll('.dropdown-menu').forEach(dropdown => {
        dropdown.classList.remove('show');
    });
}

/* gnb menu active */
function initGnb(){
	const currentGnb = document.body.dataset.gnb;
	
	// gnb 활성화
	let element = document.querySelector("#" + currentGnb);
	
	if(element){
		element.classList.add("active");
	}
}


/*
sweetAlert 사용하기
함수 호출 시,
sweetAlert(아이콘, title, confirmButtonText [,cancelButtonText, showCancelButton]); => 취소버튼이 없을 경우 "취소"와 true 함께 생략
sweetAlert("warning", "확인해보셨어요?", "확인", "취소", ture); => 취소 버튼 있음
sweetAlert("warning", "확인해보셨어요?", "확인"); => 취소 버튼 없음
*/
const sweetAlert = (icon, title, confirmText = "확인", cancelText = "취소", showCancel = false) => {
    return Swal.fire({
        title: title,
        icon: icon,
        showCancelButton: showCancel,
        confirmButtonText: confirmText,
        cancelButtonText: cancelText,
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-primary btn-lg",
            cancelButton: "btn btn-secondary btn-lg",
            title: "text-xl text-primary mb-3"
        }
    });
};

/*
sweetAlertC({
	icon: "", // 필수입력
	title: "", // 필수입력
	confirm: "", // 기본값: 확인 (생략가능)
	cancel: "", // 기본값: 취소 (생략가능)
	showCancel: false // 기본값: false (생략가능. 생략시 취소버튼x),
	...
	쓰고싶은 옵션 쓰기~~
})
*/
const sweetAlertC = ({
    icon, 
    title, 
    confirm = "확인", 
    cancel = "취소", 
    showCancel = false, 
    ...extraOptions 
}) => {
    const defaultSettings = {
        title: title,
        icon: icon,
        showCancelButton: showCancel,
        confirmButtonText: confirm,
        cancelButtonText: cancel,
        reverseButtons: true,
        customClass: {
            confirmButton: "btn btn-primary btn-lg",
            cancelButton: "btn btn-secondary btn-lg",
            title: "text-xl text-primary mb-3"
        }
    };

    return Swal.fire({ ...defaultSettings, ...extraOptions });
};
