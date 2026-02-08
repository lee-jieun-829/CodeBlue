<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<jsp:useBean id="now" class="java.util.Date" />

<!DOCTYPE html>

<html lang="ko">
  <head>
    <title>SB 병원 - 외래 진료 간호사</title>

    <!-- ===== Head 시작 ===== -->

    <%@ include file="/WEB-INF/views/common/include/link.jsp"%>

    <link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/pages/execution.css"/>

    <!-- ===== Head 끝 ===== -->

    <style type="text/css">

      .drug-done {
        color: #155dfc !important;
        font-weight: 500;
      } /* 파랑 */
      .drug-wait {
        color: #e7000b !important;
        font-weight: 500;
      } /* 빨강 */
      .table td {
        vertical-align: middle;
      }

      .status-label {
        font-size: 16px;
        font-weight: 600;
      }
      

      
     /* ✅ grid 안에서 내부 스크롤 허용 (중요) */
		.content-area.grid.grid-1-2,
		.content-area_left,
		.content-area_right,
		#center-panel,
		#detail-view {
		  min-height: 0;
		}
		
		/* ✅ 아래 탭영역이 "남은 높이"를 가져가게 */
		#visit-tabs-scope{
		  flex: 1 1 auto;
		  min-height: 0;
		  overflow: hidden;
		  display: flex;
		  flex-direction: column;
		}
		
		/* ✅ 기존 전역 .tab-content 규칙( active=block ) 때문에 flex가 깨짐 → 스코프 안에서만 강제 */
		#visit-tabs-scope .tab-content{
		  flex: 1 1 auto;
		  min-height: 0;
		  overflow: hidden;
		  display: none;           /* 기본은 숨김 */
		}
		
		#visit-tabs-scope .tab-content.active{
		  display: flex !important; /* ✅ active는 flex로 */
		  flex-direction: column;
		}
		
		/* ✅ 실제 스크롤은 여기서만 */
		#history-list,
		#exam-list{
		  flex: 1 1 auto;
		  min-height: 0;
		  overflow-y: auto;
		  overflow-x: hidden;
		}
      
      
      
    </style>
  </head>

  <body data-gnb="gnb-outpatientnurse">
    <!-- ===== Header 시작 ===== -->

    <%@ include file="/WEB-INF/views/common/include/header.jsp"%>

    <!-- ===== Header 끝 ===== -->

    <div class="main-container">
      <!-- ===== Sidebar 시작 ===== -->

      <%@ include file="/WEB-INF/views/common/include/left/left_nursing.jsp"%>

      <!-- ===== Sidebar 끝 ===== -->

      <main class="main-content">
        <div class="grid grid-sidebar-lg grid-full-height">
          <!-- =========================================================

                     [LEFT] 환자 목록 (의사 페이지 프로세스/탭 구조 + 간호사 요구사항 유지)

                     ========================================================= -->

          <div class="content-area flex flex-col h-full overflow-hidden">
            <div class="box">
              <h2 class="page-title">외래</h2>
            </div>

            <div class="box">
              <h2 class="box-title">접수 환자 목록</h2>
              <div class="form-group">
                <label class="form-label">환자 검색</label>

                <!-- ✅ 의사 페이지 방식: input 이벤트로 즉시 필터링 -->
                <input
                  type="text"
                  id="search-input"
                  class="input input-search"
                  placeholder="검색어를 입력하세요"
                />
              </div>

              <!-- ✅ 간호사 탭 구성 유지: 전체/진료중/진료대기/대기 -->

              <div class="tabs tabs-button mb-2" style="width: 100% !important">
                <button
                  class="tab active w-full"
                  onclick="switchTab(event, 'tab1')"
                >
                  전체 <span class="text-sm" id="count-total">0</span>
                </button>
                <button class="tab w-full" onclick="switchTab(event, 'tab4')">
                  대기 <span class="text-sm" id="count-wait">0</span>
                </button>
                <button class="tab w-full" onclick="switchTab(event, 'tab3')">
                  진료대기 <span class="text-sm" id="count-clinic-wait">0</span>
                </button>
                <button class="tab w-full" onclick="switchTab(event, 'tab2')">
                  진료중 <span class="text-sm" id="count-ing">0</span>
                </button>
              </div>

              <!-- <p class="text-xs text-zinc-500 mt-2">
							환자 카드의 <b>상태</b>를 클릭하면 상태를 변경할 수 있습니다.
						</p> -->
            </div>

            <!-- ✅ 의사 페이지 방식: 탭 컨텐츠 영역 분리 -->

            <div class="flex-1 overflow-auto">
              <div id="tab1" class="tab-content active">
                <div class="card-group" id="tab1-group"></div>
              </div>

              <div id="tab2" class="tab-content">
                <div class="card-group" id="tab2-group"></div>
              </div>

              <div id="tab3" class="tab-content">
                <div class="card-group" id="tab3-group"></div>
              </div>

              <div id="tab4" class="tab-content">
                <div class="card-group" id="tab4-group"></div>
              </div>
            </div>
          </div>

          <!-- =========================================================

	           [CENTER + RIGHT] 환자정보/바이탈/내원이력 + 진료기록/오더/상병/처방
	
	          ========================================================= -->

          <div class="content-area grid grid-1-2 h-full overflow-hidden">
            <!-- =======================

                 [CENTER] 환자 정보 + 바이탈 + 내원이력

                 ======================= -->

            <div id="center-panel" class="content-area_left flex flex-col h-full overflow-hidden">
              <!-- 빈 화면 -->

              <div
                id="empty-view"
                class="flex flex-col items-center justify-center h-full text-center"
              >
                <div class="mb-4">
                  <svg
                    class="w-16 h-16 text-gray-200 mx-auto"
                    fill="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"
                    />
                  </svg>
                </div>

                <h3 class="text-lg font-bold text-gray-500">
                  환자를 선택해 주세요.
                </h3>

                <p class="text-sm text-gray-400 mt-1">
                  바이탈이 등록되지 않은 환자는<br />우측 진료 기록/오더가
                  표시되지 않습니다.
                </p>
              </div>

              <!-- 상세 화면 -->

              <div
                id="detail-view"
                class="flex flex-col h-full overflow-hidden"
                style="display: none"
              >
                <!-- =======================
							     환자 기본 정보 (예시 구조)
							======================= -->
                <div class="box">
                  <div class="box-title-group flex justify-between">
                    <h2 class="box-title flex items-center">
                      <span
                        id="view-patient-no"
                        style="font-size: var(--font-lg); color: #6b7280"
                      ></span>
                      <strong
                        id="view-patient-name"
                        style="margin-left: 6px"
                      ></strong>
                    </h2>

                    <div class="doctor-info flex items-center">
                      <i class="icon icon-doctor icon-md icon-muted"></i>
                      <span class="text-sm"
                        ><b id="view-employeeName"></b> 의사</span
                      >
                      <button
                        class="btn btn-icon btn-ghost"
                        onclick="closeInfoView()"
                      >
                        <i class="icon icon-x"></i>
                      </button>
                    </div>
                  </div>

                  <!-- 보험 -->
                  <span
                    class="badge badge-success"
                    id="view-registration-insurance"
                  ></span>

                  <div
                    class="list-horizontal list-horizontal-2"
                    style="margin-top: 12px"
                  >
                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">나이 / 성별</div>
                      <div
                        id="view-age-gen"
                        class="list-horizontal-value"
                      ></div>
                    </div>
                  </div>

                  <div class="list-horizontal list-horizontal-1">
                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">생년월일</div>
                      <div id="view-birth" class="list-horizontal-value"></div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">주민등록번호</div>
                      <div class="list-horizontal-value">
                        <span id="view-regno1"></span>-<span
                          id="view-regno2"
                        ></span
                        >******
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">연락처</div>
                      <div id="view-tel" class="list-horizontal-value"></div>
                    </div>
                  </div>

                  <div class="list-horizontal list-horizontal-1">
                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">주소</div>
                      <div id="view-addr" class="list-horizontal-value"></div>
                    </div>
                  </div>
                </div>

                <!-- =======================
				     바이탈 + 메모 (표시 + 입력 통합)
				     ✅ 기존 input id 유지 (saveVital / fillVitalInputs 그대로 사용)
					======================= -->
                <div class="box box-bordered box-secondary mt-3">
                  <!-- 헤더: 제목 + 저장버튼 -->
                  <div
                    class="card-header flex justify-between items-center"
                    style="padding: 0 0 12px 0"
                  >
                    <h3 class="box-title">바이탈 작성</h3>
                    <!-- 바이탈 작성 헤더(수정 버튼 옆에) -->
                    
					 <div class="flex items-center gap-2 ml-auto">
					    <button	 id="btnFillVitalDummy" class="btn btn-ghost" style="font-size: var(--font-sm); color: var(--color-text-secondary);">시연</button>
					
					    <button
					      type="button"
					      class="btn btn-primary btn-sm"
					      id="btn-save-vital"
					      onclick="saveVital()"
					    >
					      저장
					    </button>
					  </div>
                  </div>

                  <!-- 바이탈 입력 (한 박스 안에서) -->
                  <div class="list-horizontal list-horizontal-2">
                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">키(cm)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-height"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">몸무게(kg)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-weight"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">체온(℃)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-temp"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">맥박(bpm)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-pulse"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">혈압(수축기)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-sys"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>

                    <div class="list-horizontal-item">
                      <div class="list-horizontal-label">혈압(이완기)</div>
                      <div class="list-horizontal-value">
                        <input
                          type="number"
                          id="input-dia"
                          class="input input-sm"
                          placeholder="-"
                          style="max-width: 120px"
                        />
                      </div>
                    </div>
                  </div>

                  <!-- 메모 -->
                  <div class="form-group mt-3">
                    <label class="form-label"><i class=""></i> 환자메모</label>
                    <textarea
                      id="input-memo"
                      class="textarea textarea-sm"
                      rows="2"
                      name="patientMemo"
                      placeholder="예) 알러지 : 페니실린&#13;&#10;복용중 약품 : 고혈압완화제"
                    ></textarea>
                  </div>

                  <p class="text-xs text-zinc-500 mt-2">
                    바이탈 저장 시 상태를 <b>진료대기</b>로 자동 변경합니다.
                  </p>
                </div>

                <!-- 입력 폼이자 조회 폼 끝 -->

                <hr class="section-divider" />

                <!-- =======================
				     내원 이력, 검사 결과 (예시 느낌 + 기존 id 유지)
					======================= -->

                <div class="box">
                  <div class="flex justify-between items-center">
                    <div class="tabs tabs-text">
                      <button class="tab active" onclick="switchTabScoped(event, 'tab11', 'visit-tabs-scope')">
						  내원 이력
						</button>
					  <button class="tab" onclick="switchTabScoped(event, 'tab12', 'visit-tabs-scope')">
					      검사 결과
					  </button>
                    </div>
                  </div>
                </div>

                <div id="visit-tabs-scope" class="flex flex-col flex-1 min-h-0 overflow-hidden">

				  <div id="tab11" class="tab-content active flex flex-col flex-1 min-h-0">
				    <div id="history-list" class="flex-1 min-h-0 overflow-y-auto"></div>
				  </div>
				
				  <div id="tab12" class="tab-content active flex flex-col flex-1 min-h-0">
				    <div id="exam-list" class="flex-1 min-h-0 overflow-y-auto"></div>
				  </div>
				</div>

              </div>
            </div>

            <!-- =======================

                [RIGHT] 진료 기록/오더/상병/처방 + 처치 완료

                ======================= -->

            <div
              class="content-area_right flex flex-col h-full overflow-hidden"
            >
              

              <!-- ✅ 우측: 조건부 뷰 -->

              <div
                id="right-empty"
                class="flex-1 flex items-center justify-center text-center"
              >
                <div class="empty-state empty-state-sm">
                  <svg
                    class="empty-state-icon"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <path
                      d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"
                    ></path>
                  </svg>
                  <br />
                  <div class="text-lg font-bold text-gray-500">
                    아직 진료 데이터가 존재하지 않습니다.
                  </div>

                  <div class="text-sm text-gray-400 mt-1" id="right-empty-msg">
                    환자 대기 상태가 <b>진료중</b>일 때만 표시됩니다.
                  </div>
                </div>
              </div>

              <div
                id="right-view"
                class="flex-1 overflow-auto custom-scroll hidden"
              >
              
              
              <!-- 상단 -->

              <div class="box">
                <div class="box-title-group flex justify-between">
                  <h2 class="box-title">
                    <fmt:formatDate value="${now}" pattern="yyyy-MM-dd E요일" />
                  </h2>

                  <div
                    class="flex items-center gap-2 text-sm font-medium text-neutral-600"
                  ><button
                        class="btn btn-icon btn-ghost"
                        onclick="closeInfoView()"
                      >
                        <i class="icon icon-x"></i>
                      </button></div>
                </div>
              </div>
              
              
                <!-- 진료 기록 -->
                <div class="content-group mt-3">
                  <div class="content-group-header">
                    <svg
                      class="content-header-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <path
                        d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                      ></path>
                    </svg>
                    <div class="content-header-title">진료 기록</div>
                  </div>

                  <div class="content-group-body">
                    <textarea
                      class="textarea textarea-sm"
                      id="clinicNote"
                      placeholder="진료 기록이 작성되어 있지 않습니다."
                      style="
                        min-height: 60px;
                        margin-bottom: var(--spacing-md);
                      "
                      readonly="readonly"
                    ></textarea>
                  </div>
                </div>

                <!-- 투약 및 처치 기록 -->

                <div class="box mt-3">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <path
                        d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
                      ></path>
                    </svg>
                    <div class="content-group-title">
                      투약 및 처치 기록 (간호사 오더 수행)
                    </div>
                  </div>

                  <div class="table-wrapper mt-2">
                    <table class="table">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 6rem">오더 타입</th>
                          <th>오더명칭</th>
                          <th style="width: 7rem">상태</th>
                          <th style="width: 7rem; text-align: center;">액션</th>
                        </tr>
                      </thead>
                      <tbody id="order-list-body">
                        <tr>
                          <td colspan="5" class="text-center" style="text-align: center;">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <!-- 상병 -->

                <div class="box mt-4">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <circle cx="12" cy="12" r="10"></circle>
                      <line x1="12" y1="16" x2="12" y2="12"></line>
                      <line x1="12" y1="8" x2="12.01" y2="8"></line>
                    </svg>
                    <div class="content-group-title">상병</div>
                  </div>

                  <div class="table-wrapper mt-2">
                    <table class="table">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 4rem">주</th>
                          <th style="width: 4rem">부</th>
                          <th style="width: rem">상병코드</th>
                          <th>상병 명</th>
                        </tr>
                      </thead>

                      <tbody id="diagnosis-list-body">
                        <tr>
                          <td colspan="5" class="text-center">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <!-- 치료 처방 -->

                <div class="box mt-4">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <path
                        d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
                      ></path>
                      <polyline points="14 2 14 8 20 8"></polyline>
                    </svg>
                    <div class="content-group-title">치료 처방</div>
                  </div>

                  <div class="table-wrapper mt-2">
                    <table class="table">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 6rem">처방타입</th>
                          <th style="width: 7rem">처방코드</th>
                          <th>처방명칭</th>
                          <th style="width: 5rem">1회량</th>
                          <th style="width: 4rem">횟수</th>
                          <th style="width: 4rem">일수</th>
                          <th style="width: 4rem">상태</th>
                        </tr>
                      </thead>

                      <tbody id="treat-list-body">
                        <tr>
                          <td colspan="8" class="text-center">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <!-- 약제 처방 -->

                <div class="box mt-4">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <rect
                        x="3"
                        y="3"
                        width="18"
                        height="18"
                        rx="2"
                        ry="2"
                      ></rect>
                      <line x1="9" y1="9" x2="15" y2="9"></line>
                      <line x1="9" y1="15" x2="15" y2="15"></line>
                    </svg>
                    <div class="content-group-title">약제 처방</div>
                  </div>

                  <div class="table-wrapper mt-2">
                    <table class="table">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 7rem">약제코드</th>
                          <th>약제명</th>
                          <th style="width: 5rem">1회량</th>
                          <th style="width: 5rem">횟수</th>
                          <th style="width: 5rem">일수</th>
                          <th style="width: 7rem">용법</th>
                        </tr>
                      </thead>
                      <tbody id="drug-list-body">
                        <tr>
                          <td colspan="7" class="text-center">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <!-- 수술 처방 -->

                <div class="box mt-4">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <circle cx="12" cy="12" r="10"></circle>
                      <line x1="12" y1="16" x2="12" y2="12"></line>
                      <line x1="12" y1="8" x2="12.01" y2="8"></line>
                    </svg>
                    <div class="content-group-title">수술 처방</div>
                    <div class="content-group-actions"></div>
                  </div>
                  <div class="table-wrapper">
                    <table class="table table-input">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 6rem">수술코드</th>
                          <th>수술명</th>
                        </tr>
                      </thead>
                      <tbody id="opTable-list-body">
                        <tr>
                          <td colspan="3" class="text-center">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <!-- 검사 처방 -->

                <div class="box mt-4">
                  <div class="content-header">
                    <svg
                      class="content-group-icon"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2"
                    >
                      <circle cx="12" cy="12" r="10"></circle>
                      <line x1="12" y1="16" x2="12" y2="12"></line>
                      <line x1="12" y1="8" x2="12.01" y2="8"></line>
                    </svg>
                    <div class="content-group-title">검사 처방</div>
                    <div class="content-group-actions"></div>
                  </div>
                  <div class="table-wrapper">
                    <table class="table table-input">
                      <thead>
                        <tr>
                          <th style="width: 3rem">No</th>
                          <th style="width: 6rem">검사명</th>
                          <th style="width: 7rem">환부</th>
                          <th style="width: 4rem">좌우</th>
                          <th style="width: 4rem">파일</th>
                          <th style="width: 4rem">상태</th>
                        </tr>
                      </thead>
                      <tbody id="exam-list-body">
                        <tr>
                          <td colspan="6" class="text-center">
                            조회하신 정보가 존재하지 않습니다.
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
                
                <br>
                
              <div class="area-right_footer pt-3">
                <div class="btn-group-justified">
                  <button id="opReservation" class="btn btn-secondary">
                    수술 예약
                  </button>
                  <div class="btn-group-left">
                    <!-- 									<button onclick="openModal('scheduleModal')" -->
                    <!-- 										class="btn btn-secondary">일정 확인 및 진료 예약 등록</button> -->
                  </div>

                  <div class="btn-group-right">
                    <!-- ✅ 조건 충족 시만 동작 -->

                    <button
                      class="btn btn-primary"
                      id="btn-complete-treatment"
                      onclick="completeTreatment(this)"
                    >
                      처치 완료
                    </button>
                  </div>
                </div>

                <p class="text-xs text-zinc-500 mt-2" id="complete-hint">
                  ※ 오더가 존재하는 경우, <b>모든 오더가 완료</b>되어야 처치
                  완료가 가능합니다.
                </p>
              </div>
              
              </div>

            </div>
          </div>
        </div>
      </main>
    </div>

    <!-- libs -->

    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <jsp:include page="/WEB-INF/views/nurse/opReservation.jsp" />

    <script>
      /* =========================
	   Global
	========================= */
      const CTX = "${pageContext.request.contextPath}";
      let originalPatientList = [];
      let currentPatient = null;
      let registrationNo = null;
      let chartNo = null;
      let vitalExists = false;
      let historyMode = false; // ✅ 내원이력(과거 차트) 상세보기 모드
      let vitalForCurrentRegistration = false;
      let rightDataExists = false; // ✅ 우측에 표시할 진료 데이터(차트/오더/상병/처방 등) 존재 여부




      /* =========================
		   CSRF Header
		========================= */
      function getApiHeaders() {
        const csrfMetaTag = document.querySelector('meta[name="_csrf"]');
        const csrfHeaderTag = document.querySelector(
          'meta[name="_csrf_header"]',
        );

        const csrfToken = (csrfMetaTag && csrfMetaTag.content) || "";
        const csrfHeader = (csrfHeaderTag && csrfHeaderTag.content) || "";

        const headers = { "Content-Type": "application/json" };
        if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;
        return headers;
      }
      
      
      //시간 포맷
      function formatRegTime(raw) {
    	  if (!raw) return "";

    	  const s = String(raw);

    	  // 1) ISO: 2026-01-26T09:12:34..., 2026-01-26T09:12:34.000+09:00
    	  if (s.includes("T")) {
    	    const t = s.split("T")[1] || "";
    	    return t.substring(0, 5); // HH:mm
    	  }

    	  // 2) 공백형: 2026-01-26 09:12:34
    	  if (s.includes(" ")) {
    	    const t = s.split(" ")[1] || "";
    	    return t.substring(0, 5);
    	  }

    	  // 3) Date 파싱 fallback
    	  const d = new Date(raw);
    	  if (!isNaN(d.getTime())) {
    	    const hh = String(d.getHours()).padStart(2, "0");
    	    const mm = String(d.getMinutes()).padStart(2, "0");
    	    return `${hh}:${mm}`;
    	  }

    	  return "";
    	}

    	function pickRegDate(p, reg) {
    	  // 너 API 필드명에 맞게 최대한 많이 fallback
    	  return (
    	    reg?.registrationRegdate ||
    	    reg?.registrationRegDate ||
    	    reg?.regDate ||
    	    p?.registrationRegdate ||
    	    p?.registrationRegDate ||
    	    p?.regDate ||
    	    p?.regdate ||
    	    ""
    	  );
    	}

      
      
      
      /* =========================
	      Memo Auto Save (blur)
	      - 메모는 별도 저장
	   ========================= */
	
	   const MEMO_SAVE_URL = CTX + "/nurse/updatePatientMemo"; 
	   // ✅ 너희 서버에 실제로 존재하는 메모 저장 API로 맞춰줘야 함
	   // (없으면 아래 4번에 서버쪽 예시 첨부해둠)
	
	   let __memoLastSaved = "";     // 마지막으로 저장된 값(중복 저장 방지)
	   let __memoSaving = false;     // 저장 중 중복 호출 방지
	   let __memoDirty = false;      // 저장 중 변경되면 재저장 트리거
	   let __memoSaveTimer = null;   // (선택) 디바운스용
	
	   function getMemoValue() {
	     return document.getElementById("input-memo")?.value ?? "";
	   }
	
	   // ✅ 환자 선택/조회 시 “현재 DB 값”을 기준값으로 세팅(이게 중요)
	   function setMemoBaseline(v) {
	     __memoLastSaved = String(v ?? "");
	     __memoDirty = false;
	   }
	
	   // ✅ blur 순간 저장(변경 있을 때만)
	   async function savePatientMemo(reason, force) {
	     const memoEl = document.getElementById("input-memo");
	     if (!memoEl) return;
	
	     // 저장 대상 환자
	     if (!currentPatient?.patientNo) return;
	
	     const memo = String(memoEl.value ?? "");
	     if (!force && memo === __memoLastSaved) return; // 변경 없으면 저장 X
	
	     // 저장 중이면 dirty만 표시해두고 끝
	     if (__memoSaving) {
	       __memoDirty = true;
	       return;
	     }
	
	     __memoSaving = true;
	
	     try {
	       const payload = {
	         patientNo: currentPatient.patientNo,
	         patientMemo: memo,
	
	         // ✅ 메모가 “접수/차트 단위”로 저장되는 구조면 이 값도 필요할 수 있어
	         // 서버가 필요 없으면 무시해도 됨
	         registrationNo: registrationNo,
	         chartNo: chartNo,
	       };
	
	       const res = await axios.post(MEMO_SAVE_URL, payload, { headers: getApiHeaders() });
	
	       const ok =
	         res?.data === "success" ||
	         res?.data === true ||
	         res?.data?.status === "OK" ||
	         res?.data?.status === "success" ||
	         res?.data?.result === "success";
	
	       if (!ok) {
	         console.warn("[memo] save failed:", res?.data);
	         return;
	       }
	
	       __memoLastSaved = memo;
	       __memoDirty = false;
	
	       // 원하면 저장 성공 표시(너무 시끄러우면 주석)
	       // sweetAlert("success", "메모가 저장되었습니다.", "확인");
	     } catch (e) {
	       console.error("[memo] save error:", e);
	       // 실패 시 알림은 취향(자동저장은 너무 자주 뜨면 피곤해서 콘솔만 추천)
	     } finally {
	       __memoSaving = false;
	
	       // 저장 중에 또 변경됐으면 1회 더 저장
	       if (__memoDirty) {
	         __memoDirty = false;
	         await savePatientMemo("memo_dirty_retry", true);
	       }
	     }
	   }
	
	   // ✅ 이벤트 바인딩
	   function initMemoAutosave() {
	     const memoEl = document.getElementById("input-memo");
	     if (!memoEl) return;
	
	     memoEl.addEventListener("input", () => {
	       // 단순 플래그(blur에서 비교 저장)
	     });
	
	     memoEl.addEventListener("blur", () => {
	       // blur 시 저장
	       savePatientMemo("blur", false);
	     });
	
	     // (선택) 페이지 나갈 때 저장 시도
	     window.addEventListener("beforeunload", () => {
	       // beforeunload는 await이 안 먹어서 “시도만”
	       if (currentPatient?.patientNo && getMemoValue() !== __memoLastSaved) {
	         navigator.sendBeacon?.(
	           MEMO_SAVE_URL,
	           new Blob([JSON.stringify({
	             patientNo: currentPatient.patientNo,
	             patientMemo: getMemoValue(),
	             registrationNo,
	             chartNo
	           })], { type: "application/json" })
	         );
	       }
	     });
	   }
	
	   // ✅ 환자 전환 직전에 메모 저장(안 하면 클릭 전환 시 값 유실될 수 있음)
	   async function flushMemoBeforeSwitch() {
	     const memoEl = document.getElementById("input-memo");
	     if (!memoEl) return;
	     if (!currentPatient?.patientNo) return;
	
	     const cur = String(memoEl.value ?? "");
	     if (cur !== __memoLastSaved) {
	       await savePatientMemo("patient_switch", false);
	     }
	   }

      

      /* =========================
		   Helpers
		========================= */
      function getReg(p) {
        return p && p.registrationVO ? p.registrationVO : {};
      }

      // status: 코드(001~004) or 한글(대기/진료대기/진료중/수납대기) 모두 정규화
      function normalizeStatus(s) {
        if (!s) return "";
        const v = String(s);

        // 코드
        if (v === "001") return "대기";
        if (v === "002") return "진료대기";
        if (v === "003") return "진료중";
        if (v === "004") return "수납대기";

        // 이미 한글
        if (v.includes("대기") || v.includes("진료")) return v;

        return v;
      }
      
      //우측 데이터 존재 판별 함수
      function hasRightPanelData(d) {
    	  const chartAll = Array.isArray(d?.chartListAll) ? d.chartListAll : [];
    	  const orders = Array.isArray(d?.chartList) ? d.chartList : [];
    	  const diagnosis = Array.isArray(d?.diagnosisList) ? d.diagnosisList : [];

    	  // chartListAll에 chartContent가 있거나, 처방 리스트들 중 하나라도 있으면 "데이터 있음"
    	  let hasChartContent = false;
    	  let hasAnyPrescriptions = false;

    	  for (let i = 0; i < chartAll.length; i++) {
    	    const x = chartAll[i] || {};
    	    if (String(x.chartContent || "").trim() !== "") hasChartContent = true;

    	    if (Array.isArray(x.drugList) && x.drugList.length) hasAnyPrescriptions = true;
    	    if (Array.isArray(x.treatList) && x.treatList.length) hasAnyPrescriptions = true;
    	    if (Array.isArray(x.examList) && x.examList.length) hasAnyPrescriptions = true;
    	    if (Array.isArray(x.operList) && x.operList.length) hasAnyPrescriptions = true;

    	    if (hasChartContent || hasAnyPrescriptions) break;
    	  }

    	  return (
    	    hasChartContent ||
    	    hasAnyPrescriptions ||
    	    diagnosis.length > 0 ||
    	    orders.length > 0
    	  );
    	}



      /* =========================
		   Card Rendering (보험/상태 스타일 강화)
		========================= */
      function makePatientCard(p) {
        const reg = getReg(p);
        
        const patientNo = p.patientNo || "";
        const pName = p.patientName || "";
        const pGen = p.patientGen || ""; // 한글 있으면 우선
        const pAge = p.patientAge || "";
        const pRegNo1 = p.patientRegno1 || "";

        const regNo = reg.registrationNo || "";
        const cNo = p.chartNo || reg.chartNo || "";

        // 보험명 (우선순위 대응)
        const insuranceName = reg.registrationInsurance || "";

        // 상태(코드/한글 모두 대응)
        const rawStatus = reg.registrationStatus || "";
        const statusLabel = normalizeStatus(rawStatus); // "대기/진료대기/진료중/수납대기" 로 정규화
        
        
        // ✅ 접수시간 가져오기 (핵심)
        const rawRegDate = pickRegDate(p, reg);
        const regTime = formatRegTime(rawRegDate) || "-";
        
     // ✅ 담당의사 이름(우선순위로 안전하게)
        const doctorName =
          reg.employeeName ||
          reg.doctorName ||
          p.employeeName ||
          p.doctorName ||
          p.employee?.employeeName ||
          "-";



        /* ---------- 보험 배지 클래스 ---------- */
        let badgeClass = "bg-gray-100 text-gray-800";
        if (insuranceName === "건강보험")
          badgeClass = "bg-blue-100 text-green-800";
        else if (insuranceName === "일반")
          badgeClass = "bg-green-100 text-blue-800";
        else if (insuranceName === "산재" || insuranceName === "후유장해")
          badgeClass = "bg-red-100 text-red-800";

        /* ---------- 상태 박스 클래스 ---------- */
        // 기본(대기/기타)
        let statusBoxClass = "bg-gray-100 text-gray-600 border border-gray-200";
        // 상태별 강조
        if (statusLabel === "진료중") {
          statusBoxClass =
            "bg-emerald-50 text-emerald-600 border border-emerald-100";
        } else if (statusLabel === "진료대기") {
          statusBoxClass = "bg-amber-50 text-amber-700 border border-amber-100";
        } else if (statusLabel === "수납대기") {
          statusBoxClass =
            "bg-indigo-50 text-indigo-700 border border-indigo-100";  
        } else if (statusLabel === "대기") {
          statusBoxClass = "bg-gray-100 text-gray-600 border border-gray-200";
        }

        console.log("insuranceName:", insuranceName, typeof insuranceName);

        return (
        		  "" +
        		  '<div class="card bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden mb-2 cursor-pointer transition-colors hover:bg-gray-50"' +
        		  " onclick=\"selectPatient('" + patientNo + "','" + regNo + "','" + cNo + "')\">" +

        		  '<div class="card-header bg-gray-50 px-4 py-2 border-b border-gray-100 flex justify-between items-center">' +
        		    '<h4 class="card-title text-sm text-gray-700 font-medium">환자번호 ' + patientNo + "</h4>" +
        		    '<span class="text-[11px] text-slate-400">접수 ' + regTime + "</span>" +
        		  "</div>" +

        		  // ✅ 여기 card-body 안에서 왼쪽/오른쪽을 나란히 유지해야 함
        		  '<div class="card-body p-4 flex justify-between items-center">' +

        		    // 왼쪽 영역
        		    '<div class="flex flex-col gap-2">' +
        		      "<div>" +
        		        '<h3 class="text-lg font-bold text-gray-900">' + pName + "</h3>" +
        		        '<p class="text-sm text-gray-500 mt-0.5">' + pGen + " / " + pAge + "세 (" + pRegNo1 + ")</p>" +
        		      "</div>" +

        		      '<div class="patient-card__badges flex items-center gap-1">' +
        		      '<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-yellow-80">' +
        		      '<strong>Dr.</strong>'+ doctorName +
        		        "</span>" +
        		        '<span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ' + badgeClass + '">' +
        		          insuranceName +
        		        "</span>" +
        		      "</div>" +
        		    "</div>" +  // ✅ 왼쪽 영역 닫기 (여기까지만!)

        		    // 오른쪽 상태 영역 (flex 줄의 두 번째 아이템)
        		    '<div class="flex flex-col items-center justify-center w-20 h-16 rounded-xl ml-4 flex-shrink-0 ' + statusBoxClass + '">' +
        		      '<span class="font-bold text-sm">' + (statusLabel || "") + "</span>" +
        		    "</div>" +

        		  "</div>" + // ✅ card-body 닫기
        		  "</div>"   // ✅ card 닫기
        		);

      }
      

      function renderAllTabs(list) {
        let total = "",
          ing = "",
          clinicWait = "",
          standby = "";
        let cntTotal = 0,
          cntIng = 0,
          cntClinicWait = 0,
          cntStandby = 0;

        (list || []).forEach((p) => {
          const reg = getReg(p);
          const statusLabel = normalizeStatus(
            reg.registrationStatus || p.registrationStatus,
          );

          const html = makePatientCard(p);
          total += html;
          cntTotal++;

          if (statusLabel === "진료중") {
            ing += html;
            cntIng++;
          } else if (statusLabel === "진료대기") {
            clinicWait += html;
            cntClinicWait++;
          } else if (statusLabel === "대기") {
            standby += html;
            cntStandby++;
          }
        });

        document.getElementById("count-total").textContent = cntTotal;
        document.getElementById("count-ing").textContent = cntIng;
        document.getElementById("count-clinic-wait").textContent =
          cntClinicWait;
        document.getElementById("count-wait").textContent = cntStandby;

        document.getElementById("tab1-group").innerHTML =
          total || empty("접수된 환자가 없습니다.");
        document.getElementById("tab2-group").innerHTML =
          ing || empty("진료중인 환자가 없습니다.");
        document.getElementById("tab3-group").innerHTML =
          clinicWait || empty("진료대기중인 환자가 없습니다.");
        document.getElementById("tab4-group").innerHTML =
          standby || empty("대기중인 환자가 없습니다.");
      }
      
      //항목 비어있을 시 보여질 화면
      function empty(msg){
		  msg = (msg == null) ? "" : String(msg);
		
		  return ''
		    + '<div class="flex flex-col items-center justify-center py-10 text-center text-gray-400">'
		    +   '<svg class="w-16 h-16 text-gray-200 mx-auto" fill="currentColor" viewBox="0 0 24 24">'
		    +     '<path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>'
		    +   '</svg>'
		    +   '<div class="mt-2 text-sm font-medium">' + msg + '</div>'
		    + '</div>';
		}




      /* =========================
		   Tabs / Modal
		========================= */
      // 탭 전환 함수
      function switchTab(event, tabId) {
        const clickedTab = event.currentTarget;
        const tabContainer = clickedTab.closest(".tabs");
        tabContainer
          .querySelectorAll(".tab")
          .forEach((tab) => tab.classList.remove("active"));
        clickedTab.classList.add("active");

        const targetContent = document.getElementById(tabId);
        if (targetContent) {
          const contentWrapper = targetContent.parentElement;
          contentWrapper
            .querySelectorAll(".tab-content")
            .forEach((content) => content.classList.remove("active"));
          targetContent.classList.add("active");
        }
      }

      function openModal(id) {
        const el = document.getElementById(id);
        el.classList.remove("hidden");
        el.style.display = "flex";
      }
      function closeModal(id) {
        const el = document.getElementById(id);
        el.classList.add("hidden");
        el.style.display = "none";
      }

      /* =========================
	   Load List
	========================= */
	function loadWaitingList(){
		loadPatientList()
	}
	
      document.addEventListener("DOMContentLoaded", () => {
    	  
        loadPatientList();

        
     	// ✅ 실시간 목록 갱신 시작
        initRealtimePatientList();
        initMemoAutosave();
        
        document
          .getElementById("search-input") //검색하면 바로 리스트에 출력됨
          .addEventListener("input", (e) => filterPatientList(e.target.value));
      });

      async function loadPatientList() {
        try {
          const res = await axios.post(
            CTX + "/nurse/getOutPatientList",
            {},
            { headers: getApiHeaders() },
          );

          // ✅ 응답 형태가 {list, counts} 이거나, 배열 그 자체일 수도 있어서 둘 다 대응
          const data = res.data;
          const list = Array.isArray(data) ? data : data.list || [];
          const counts = Array.isArray(data) ? null : data.counts;

          originalPatientList = list;
          applyCounts(counts); // 있으면 반영(없어도 renderAllTabs에서 다시 계산함)
          renderAllTabs(originalPatientList);
        } catch (e) {
          console.error("환자 목록 로딩 실패", e);
          sweetAlert(
            "error",
            "환자 목록 로딩 실패 (콘솔/네트워크 확인)",
            "확인",
          );
        }
      }
      
      
      /*  =========================
      Realtime: Outpatient List (WebSocket/STOMP)
      - 연결은 공용코드가 함
      - 여기서는 "구독 + 수신 시 목록 갱신"만
   ========================= */

   // ✅ 너희 서버에서 실제로 publish 하는 토픽으로만 바꿔줘
   const OUTPATIENT_TOPIC = "/topic/nurse/outpatientnurse"; // 예: "/topic/nurse/outpatients" 등

   let __outpatientSubscription = null;
   let __refreshTimer = null;

   // ✅ 메시지 여러 개 연달아 와도 서버를 과하게 호출하지 않게 디바운스
   function schedulePatientListRefresh(reason) {
     clearTimeout(__refreshTimer);
     __refreshTimer = setTimeout(async () => {
       try {
         const kw = document.getElementById("search-input")?.value ?? "";

         await loadPatientList();        // 원본 목록 다시 가져오기
         if (kw.trim()) filterPatientList(kw); // 검색 중이면 필터 다시 적용

         // 필요하면 로그
         // console.log("[WS] patient list refreshed:", reason);
       } catch (e) {
         console.error("[WS] refresh failed:", e);
       }
     }, 200);
   }

   // ✅ 웹소켓 메시지 핸들러(형식이 뭐든, "목록 변경"이면 갱신)
   function onOutpatientWsMessage(payload) {
     // payload가 문자열/객체/스톰프 frame 등 어떤 형태여도 대응
     let data = payload;

     try {
       if (payload && payload.body) {
         // STOMP frame
         data = JSON.parse(payload.body);
       } else if (typeof payload === "string") {
         data = JSON.parse(payload);
       }
     } catch (_) {
       // JSON 파싱 실패면 그냥 원본 유지(문자열일 수도 있음)
       data = payload;
     }

     // ✅ 여기서 이벤트 타입을 엄격히 필터링하고 싶으면 조건 추가 가능
     // 예: if (data?.type !== "OUTPATIENT_CHANGED") return;

     schedulePatientListRefresh(data?.type || "outpatient_changed");
   }

   // ✅ 공용코드에 의해 stompClient가 전역에 있다고 가정하고 최대한 안전하게 구독
   function initRealtimePatientList() {
     // 중복 구독 방지
     if (__outpatientSubscription) return;

     // 1) 공용코드가 window.stompClient를 제공하는 케이스 (가장 흔함)
     const trySubscribeWithStomp = () => {
       const c = window.stompClient;
       if (!c || !c.connected || typeof c.subscribe !== "function") return false;

       __outpatientSubscription = c.subscribe(OUTPATIENT_TOPIC, onOutpatientWsMessage);
       return true;
     };

     // 2) 공용코드가 별도 구독 함수 제공하는 케이스(있으면 이걸로)
     const trySubscribeWithHelper = () => {
       // 예: window.wsSubscribe(dest, cb) 같은 공용 함수가 있을 수도 있음
       const fn = window.wsSubscribe || window.subscribeTopic || window.subscribe;
       if (typeof fn !== "function") return false;

       __outpatientSubscription = fn(OUTPATIENT_TOPIC, onOutpatientWsMessage);
       return true;
     };

     // 먼저 헬퍼 -> stomp 순으로 시도
     if (trySubscribeWithHelper()) return;
     if (trySubscribeWithStomp()) return;

     // 아직 연결 전이면 잠깐 기다렸다가 구독
     let tries = 0;
     const timer = setInterval(() => {
       tries++;

       if (trySubscribeWithHelper() || trySubscribeWithStomp()) {
         clearInterval(timer);
         // 최초 1회 동기화(접속 직후 한번 새로고침)
         schedulePatientListRefresh("ws_connected");
         return;
       }

       // 너무 오래 기다리면 중단(콘솔에만 남김)
       if (tries > 60) { // 60 * 500ms = 30초
         clearInterval(timer);
         console.warn("[WS] subscribe failed: stompClient/subscribe helper not found");
       }
     }, 500);
   }

      
      

      function applyCounts(counts) {
        if (!counts) return;

        // ✅ 네 XML readStatus 키: total, treating, waiting, standby
        // ✅ 혹시 예전 키도 들어오면 같이 대응
        const total = counts.total ?? 0;
        const treating = counts.treating ?? counts.ing ?? 0;
        const waiting = counts.waiting ?? counts.clinicWait ?? 0;
        const standby = counts.standby ?? counts.wait ?? 0;

        document.getElementById("count-total").textContent = total;
        document.getElementById("count-ing").textContent = treating;
        document.getElementById("count-clinic-wait").textContent = waiting;
        document.getElementById("count-wait").textContent = standby;
      }

      //검색 필터링 (patientName + registrationNo + patientNo || 환자이름,접수번호,환자번호)
      function filterPatientList(keyword) {
        if (!keyword) {
          renderAllTabs(originalPatientList);
          return;
        }

        const kw = String(keyword).trim();

        const filtered = (originalPatientList || []).filter((p) => {
          const name = String(p?.patientName ?? "");
          const regNo = String(p?.registrationVO?.registrationNo ?? "");
          const patientNo = String(p?.patientNo ?? "");

          return (
            name.includes(kw) || regNo.includes(kw) || patientNo.includes(kw)
          );
        });

        renderAllTabs(filtered);
      }

      /* =========================
		   Detail (Click)
		========================= */
      async function selectPatient(pNo, regNo, cNo) {
        try {
        
          await flushMemoBeforeSwitch();
          // ✅ 클릭 즉시 이전 환자 우측 패널 잔상 제거(초기화)
          registrationNo = regNo || null;
          chartNo = cNo || null;
          currentPatient = null;
          vitalExists = false;
          //toggleRightPanel(); 이걸 살리고 다른 환자 왔다리 갔다리해도 괜찮게 할 것이냐. 이걸 죽이고 깜빡임을 없앨 것이냐...

          console.log("##차트 번호 잘 들어오는지 확인:" + chartNo);

          const url =
            CTX +
            "/nurse/patientDetail/" +
            encodeURIComponent(pNo) +
            "?registrationNo=" +
            encodeURIComponent(registrationNo || "") +
            (chartNo ? "&chartNo=" + encodeURIComponent(chartNo) : "");

          const res = await axios.get(url, { headers: getApiHeaders() });

          const d = res.data || {};
          console.log(d);
          updateOPReservation(d);

          //수술 모달 열 수 있는 데
         /*  $("#opReservation")
            .off("click")
            .on("click", function () {
              openOpReservationModal(d);
            }); */
            const opBtn = document.getElementById("opReservation");
            if (opBtn) opBtn.onclick = () => openOpReservationModal(d);

            

          if (!d.detail) {
            console.log("detail response:", d);
            sweetAlert(
              "warning",
              "상세 응답(detail)이 비어있음. 컨트롤러 응답 확인 필요",
              "확인",
            );
            return;
          }

          currentPatient = d.detail;
          vitalExists = !!d.detail.screeningVO;

          renderPatientInfo(d);
          fillVitalInputs(d.detail.screeningVO);
          updateVitalButtonText();


          //renderOrders(d.chartListAll[0].drugList || []);
          const nOrders = (d?.chartListAll?.[0]?.drugList || []).filter(
			  (x) => String(x?.predrugDetailType || "").trim() === "N"
			);
			
			renderOrders(nOrders);


          // 🔴 진료중인데 상병이 하나도 없으면 강제 에러 처리
          const regStatus =
            d.detail?.registrationVO?.registrationStatus ||
            d.detail?.registrationStatus ||
            "";

          if (
       		  regStatus === "003" &&
       		  (!d.diagnosisList || d.diagnosisList.length === 0)
       		) {
       		  console.error("진료중 환자인데 diagnosisList가 비어있음", d);
       		  sweetAlert(
       		    "warning",
       		    "아직 담당 의사가 처방을 완료하지 않았습니다. \n처방이 마무리 될 때까지 기다려주세요.",
       		    "확인",
       		  );

       		  rightDataExists = false;
       		  historyMode = false;
       		  return;
       		}

          
          //바이탈 버튼 동작 관련
          const screening = d.detail.screeningVO || null;

	       // 🔥 핵심 판별
	       if (
	         screening &&
	         String(screening.registrationNo) === String(registrationNo)
	       ) {
	         vitalExists = true;
	         vitalForCurrentRegistration = true;
	       } else {
	         vitalExists = false;
	         vitalForCurrentRegistration = false;
	       }


          renderDiagnosis(d.diagnosisList || []);
          historyMode = false;              // ✅ 환자 새로 선택하면 과거모드 OFF
          renderHistory(d.visitHistory || []);
          renderExamList(d.chartListAll);
          renderExamOrderList(d.chartListAll || []);
          updateCompleteTreatmentButton(d);
          resetVisitTabs();
          renderClinicNote(d.chartListAll || []);
          renderTreatList(d.chartListAll || []);
          renderDrugList(d.chartListAll || []);
          renderOpList(d.chartListAll || []);

          updateVitalButton();

          rightDataExists = hasRightPanelData(d); // ✅ 우측에 표시할 데이터 존재 여부 계산
          
          console.log("diagnosisList:", d.diagnosisList);
          if (d.diagnosisList && d.diagnosisList[0]) {
            console.log(
              "diagnosisList[0] keys:",
              Object.keys(d.diagnosisList[0]),
            );
            console.log("diagnosisList[0] sample:", d.diagnosisList[0]);
          }

          console.log("chartListAll length:", (d.chartListAll || []).length);
          console.log(
            "chartListAll[0] keys:",
            d.chartListAll?.[0] ? Object.keys(d.chartListAll[0]) : null,
          );
          console.log("treatList sample:", d.chartListAll?.[0]?.treatList);
          toggleRightPanel();
        } catch (e) {
          console.error("상세조회 실패", e);
          //sweetAlert("error","상세조회 실패 (콘솔/네트워크 확인)","확인");
        }
      }

      function fillVitalInputs(screening) {
    	  if (!screening) {
    	    // 바이탈 정보 없으면 입력칸 초기화
    	    document.getElementById("input-height").value = "";
    	    document.getElementById("input-weight").value = "";
    	    document.getElementById("input-sys").value = "";
    	    document.getElementById("input-dia").value = "";
    	    document.getElementById("input-temp").value = "";
    	    document.getElementById("input-pulse").value = "";

    	    // ✅ 버튼 텍스트: 저장
    	    updateVitalButtonUI(null);
    	    return;
    	  }

    	  // ✅ 기존 바이탈 있음
    	  document.getElementById("input-height").value =
    	    screening.screeningHeight ?? "";
    	  document.getElementById("input-weight").value =
    	    screening.screeningWeight ?? "";
    	  document.getElementById("input-temp").value =
    	    screening.screeningTemperature ?? "";
    	  document.getElementById("input-sys").value =
    	    screening.screeningSystolic ?? "";
    	  document.getElementById("input-dia").value =
    	    screening.screeningDiastolic ?? "";
    	  document.getElementById("input-pulse").value =
    	    screening.screeningPulse ?? "";

    	  // ✅ 버튼 텍스트: 수정
    	  updateVitalButtonUI(screening);
    	}

      //바이탈 저장 버튼 토글
      function updateVitalButtonText() {
		  const btn = document.getElementById("btn-save-vital");
		  if (!btn) return;
		
		  btn.textContent = vitalForCurrentRegistration ? "수정" : "저장";
		}

      
      //바이탈 버튼 텍스트 변경 함수
      function updateVitalButton() {
		  const btn = document.getElementById("btn-save-vital");
		  if (!btn) return;
		
		  if (vitalForCurrentRegistration) {
		    btn.textContent = "수정";
		    btn.classList.remove("btn-primary");
		    btn.classList.add("btn-light"); // 기존에 btn은 이미 있으면 굳이 add 안 해도 됨
		  } else {
		    btn.textContent = "저장";
		    btn.classList.remove("btn-light");
		    btn.classList.add("btn-primary");
		  }
		}




      //환자 바이탈 조회 및 입력
      function getInputNumber(id) {
        const el = document.getElementById(id);
        if (!el) return null;

        const v = String(el.value ?? "").trim();
        if (v === "") return null;

        const n = Number(v);
        return Number.isFinite(n) ? n : null;
      }

      //바이탈 입력
      async function saveVital() {
        if (!currentPatient || !currentPatient.patientNo) {
          sweetAlert("warning", "환자를 먼저 선택해주세요.", "확인");
          return;
        }
        if (!registrationNo) {
          alert(
            "registrationNo가 없어. 목록에서 접수번호가 내려오는지 확인해줘.",
          );
          return;
        }

        // ✅ 너 프로젝트는 patientDetail이 chartNo 기반 조회를 많이 하니까 chartNo도 포함 권장
        if (!chartNo) {
          alert(
            "chartNo가 없어. 환자 상세 조회 응답에 chartNo가 내려오는지 확인해줘.",
          );
          return;
        }

        const payload = {
          patientNo: currentPatient.patientNo,
          registrationNo: registrationNo,
          chartNo: chartNo,

          // ✅ 어제 코드 기준 VO 필드명으로 전송!
          screeningHeight: getInputNumber("input-height"),
          screeningWeight: getInputNumber("input-weight"),
          screeningTemperature: getInputNumber("input-temp"),
          screeningSystolic: getInputNumber("input-sys"),
          screeningDiastolic: getInputNumber("input-dia"),
          screeningPulse: getInputNumber("input-pulse"),

          // (선택) 메모까지 같이 저장하는 컨트롤러라면 같이 전송
          //patientMemo: document.getElementById("input-memo")?.value ?? "",
        };

        if (
          payload.screeningHeight == null ||
          payload.screeningWeight == null
        ) {
          sweetAlert("warning", "키/몸무게는 필수로 입력해주세요.", "확인");
          return;
        }

        try {
          const r = await axios.post(CTX + "/nurse/registerVital", payload, {
            headers: getApiHeaders(),
          });

          // 서버 응답 형태 대응
          const ok =
            r?.data === "success" ||
            r?.data === true ||
            r?.data?.status === "OK" ||
            r?.data?.status === "success" ||
            r?.data?.result === "success";
          sweetAlert("success", "바이탈이 저장되었습니다!", "확인");
          //sendNewNotification(26011906, '바이탈 작성 완료', '바이탈 작성이 완료되었으니 진료 보셔도 됩니다.', '003', '/doctor/outpatient', 'N');

          if (!ok) {
            console.log("registerVital response:", r.data);
            sweetAlert("warning", "바이탈 저장 실패(응답 확인 필요)", "확인");
            return;
          }

          // 현재 접수 상태 확인
          const currentStatus =
            currentPatient?.registrationVO?.registrationStatus ||
            currentPatient?.registrationStatus ||
            "";

          // 001(대기)인 경우에만 002로 변경
          if (currentStatus === "001") {
            await axios.post(
              CTX + "/nurse/updateStatus",
              { registrationNo: registrationNo, status: "002" },
              { headers: getApiHeaders() },
            );
            console.log("상태 001 → 002 자동 변경 완료");
          } else {
            console.log(
              "현재 상태가 001이 아니므로 상태 변경 안함:",
              currentStatus,
            );
          }

          // ✅ 리스트/상세 재조회로 화면 동기화
          await loadPatientList();
          await selectPatient(
            currentPatient.patientNo,
            registrationNo,
            chartNo,
          );
        } catch (e) {
          console.error("saveVital error:", e);
          sweetAlert(
            "warning",
            "바이탈 저장 중 오류 (콘솔/네트워크 확인)",
            "확인",
          );
        }
        
     // ✅ 저장 성공 직후: 즉시 "수정" 모드로 전환
        vitalForCurrentRegistration = true;   // 버튼 판별 플래그
        vitalExists = true;

        // ✅ 입력값 기반으로 screeningVO를 임시로 만들어 currentPatient에 반영(잔상 방지용)
        currentPatient.screeningVO = currentPatient.screeningVO || {};
        currentPatient.screeningVO.registrationNo = registrationNo;
        currentPatient.screeningVO.screeningHeight = payload.screeningHeight;
        currentPatient.screeningVO.screeningWeight = payload.screeningWeight;
        currentPatient.screeningVO.screeningTemperature = payload.screeningTemperature;
        currentPatient.screeningVO.screeningSystolic = payload.screeningSystolic;
        currentPatient.screeningVO.screeningDiastolic = payload.screeningDiastolic;
        currentPatient.screeningVO.screeningPulse = payload.screeningPulse;

        // ✅ 버튼 텍스트/스타일 즉시 변경
        updateVitalButton();

        
      }
      
      
   // ✅ 바이탈 저장/수정 버튼 UI 제어
      function updateVitalButtonUI(screening) {
        const btn = document.getElementById("btn-save-vital");
        if (!btn) return;

        const hasVital = !!screening; // screeningVO가 있으면 기존 바이탈 있음

        btn.textContent = hasVital ? "수정" : "저장";

        // (선택) 버튼 스타일도 바꾸고 싶으면 여기서 같이:
        // btn.classList.toggle("btn-secondary", hasVital);
        // btn.classList.toggle("btn-primary", !hasVital);
      }
   

   // ✅ 바이탈 자동 입력 (네 input id에 100% 맞춘 버전)
      (function () {
        function randInt(min, max) {
          return Math.floor(Math.random() * (max - min + 1)) + min;
        }
        function randFloat(min, max, digits) {
          const v = Math.random() * (max - min) + min;
          return Number(v.toFixed(digits));
        }

        function setValById(id, value) {
          var el = document.getElementById(id);
          if (!el) {
            console.warn("[vital dummy] input not found:", id);
            return false;
          }
          el.value = value;
          el.dispatchEvent(new Event("input", { bubbles: true }));
          el.dispatchEvent(new Event("change", { bubbles: true }));
          return true;
        }

        function makeDummyVital() {
          var height = randInt(158, 188);
          var weight = randInt(45, 85);
          var temp = randFloat(36.0, 37.5, 1);
          var pulse = randInt(60, 120);

          var systolic = randInt(95, 120);
          var diastolic = randInt(75, 95);

          if (diastolic >= systolic - 15) diastolic = systolic - randInt(15, 35);
          if (diastolic < 45) diastolic = 45;

          return { height, weight, temp, pulse, systolic, diastolic };
        }

        function fillVitalDummy() {
          // ✅ 환자 선택 안 된 상태면 detail-view 자체가 숨김일 수 있어서 가드
          if (!document.getElementById("detail-view") || document.getElementById("detail-view").style.display === "none") {
            sweetAlert("warning", "환자를 먼저 선택한 뒤 사용해주세요.", "확인");
            return;
          }

          var v = makeDummyVital();

          setValById("input-height", v.height);
          setValById("input-weight", v.weight);
          setValById("input-temp", v.temp);
          setValById("input-pulse", v.pulse);
          setValById("input-sys", v.systolic);
          setValById("input-dia", v.diastolic);

       /*    if (typeof sweetAlert === "function") {
            sweetAlert("success", "바이탈 임의값이 자동 입력됐어요.", "확인");
          } else {
            console.log("[Dummy Vital Filled]", v);
          } */
        }

        document.addEventListener("DOMContentLoaded", function () {
          var btn = document.getElementById("btnFillVitalDummy");
          if (!btn) {
            console.warn("[vital dummy] button not found: btnFillVitalDummy");
            return;
          }

          // 혹시 중복 바인딩 방지
          btn.removeEventListener("click", fillVitalDummy);
          btn.addEventListener("click", fillVitalDummy);

          console.log("[vital dummy] ready");
        });
      })();


      

      //생년월일 yyyy-mm-dd 식으로 찍히게
      function formatBirth(v) {
        if (!v) return "";
        const s = String(v).trim();

        // 20000216 형태
        if (/^\d{8}$/.test(s)) {
          return s.slice(0, 4) + "-" + s.slice(4, 6) + "-" + s.slice(6, 8);
        }

        // 이미 2000-02-16 형태면 그대로
        if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;

        // 혹시 Date로 들어오거나 다른 포맷이면 안전하게 원본 반환
        return s;
      }

      //환자 정보 가져오기 (기본 정보) 이적 사항
      function renderPatientInfo(d) {
        const p = d.detail || {};

        document.getElementById("empty-view").style.display = "none";
        document.getElementById("detail-view").style.display = "flex";

        // 담당의
        const empEl = document.getElementById("view-employeeName");
        if (empEl) empEl.textContent = p.employeeName || "";

        document.getElementById("view-patient-no").textContent =
          p.patientNo || "";
        document.getElementById("view-patient-name").textContent =
          p.patientName || "";

        document.getElementById("view-age-gen").textContent =
          (p.patientAge || "") + " / " + (p.patientGenKr || p.patientGen || "");

        document.getElementById("view-birth").textContent = formatBirth(
          p.patientBirth,
        );
        document.getElementById("view-regno1").textContent =
          p.patientRegno1 || "";
        document.getElementById("view-regno2").textContent =
          p.patientRegno2 || "";
        document.getElementById("view-tel").textContent = p.patientTel || "";
        document.getElementById("view-addr").textContent = p.patientAddr1 || "";

        document.getElementById("view-registration-insurance").textContent =
          p.registrationVO?.registrationInsurance ?? "";

        // 메모
       const memoEl = document.getElementById("input-memo");
		if (memoEl) {
		  memoEl.value = p.patientMemo ?? "";
		  setMemoBaseline(memoEl.value); // ✅ 추가(이거 없으면 blur 때 불필요 저장/오작동 가능)
		}


        // ✅ 추가: "바이탈 표시용 span" 채우기 (없으면 '-' 유지)
        const s = p.screeningVO || null;
        setText("view-vital-height", s?.screeningHeight);
        setText("view-vital-weight", s?.screeningWeight);
        setText("view-vital-temp", s?.screeningTemperature);
        setText("view-vital-sys", s?.screeningSystolic);
        setText("view-vital-dia", s?.screeningDiastolic);
        setText("view-vital-pulse", s?.screeningPulse);
      }

      function setText(id, value) {
        const el = document.getElementById(id);
        if (!el) return;
        const v =
          value === undefined || value === null || String(value).trim() === ""
            ? "-"
            : String(value);
        el.textContent = v;
      }

      //진료 기록 가져오기
      function renderClinicNote(chartListAll) {
        const el = document.getElementById("clinicNote");
        if (!el) return;

        const list = Array.isArray(chartListAll) ? chartListAll : [];
        const first = list[0] || {};
        const content = (first.chartContent ?? "").toString().trim();

        el.value = content || "진료 기록이 작성되어 있지 않습니다.";
      }

      //환자 대기 상태 변경 정규화
      function normalizeDrugStatus(v) {
        if (v === undefined || v === null) return "002";

        var s = String(v).trim();

        // 코드로 이미 내려옴
        if (s === "001" || s === "002") return s;

        // 한글로 내려옴
        if (s === "완료") return "001";
        if (s === "대기") return "002";

        // 혹시 다른 값이면 기본 대기
        return "002";
      }

      function drugStatusText(code) {
        return code === "001" ? "완료" : "대기";
      }

      //투약 및 처치 내역 가져오기
      function renderOrders(list) {
        var body = document.getElementById("order-list-body");
        if (!body) return;

        if (!Array.isArray(list) || list.length === 0) {
          body.innerHTML =
            '<tr><td colspan="5" class="text-center">오더 없음</td></tr>';
          return;
        }

        var html = "";
        for (var i = 0; i < list.length; i++) {
          var o = list[i] || {};

          var predetailNo = o.predetailNo;
          var drugNo = o.drugNo;

          var curCode = normalizeDrugStatus(o.predrugDetailStatus); // 001/002
          var statusText = drugStatusText(curCode);

          var btnText = curCode === "001" ? "수행완료" : "미수행";
          var btnBaseClass = "btn btn-destructive btn-sm";
          var btnClass = btnBaseClass + (curCode === "001" ? " opacity-50" : "");

          // ✅ 여기 핵심: 우리가 만든 CSS 클래스 사용
          var nameClass = curCode === "001" ? "drug-done" : "drug-wait";

          var disabledAttr =
        	  (curCode === "001" || !predetailNo || !drugNo) ? " disabled" : "";
          var statusClass = curCode === "001" ? "drug-done" : "drug-wait";
          
          var onclickAttr = "";
          if (curCode !== "001" && predetailNo && drugNo) {
            onclickAttr =
              " onclick=\"togglePredrugStatus(this, '" +
              predetailNo + "', '" + drugNo + "', '" + curCode + "')\"";
          }

          html +=
            "" +
            "<tr>" +
            "<td>" +
            (i + 1) +
            "</td>" +
            "<td>" +
            (o.predrugDetailType || "") +
            "</td>" +
            '<td class="drug-name ' +
            nameClass +
            '">' +
            (o.drugName || "") +
            "</td>" +
            '<td class="status-label ' +
            statusClass +
            '">' +
            statusText +
            "</td>" +
            "<td>" +
            '<button type="button" class="' + btnClass + '"' +
            disabledAttr +
            onclickAttr +
            ">" +
            btnText +
            "</button>" +
            "</td>" +
            "</tr>";
            
        }
        
        body.innerHTML = html;
        //sweetAlert("success","주사 투약이 완료되었습니다!", "확인");
      }

      //새로고침 말고 읽기만 할거다!?
      async function reloadOrdersOnly() {
        try {
          if (!currentPatient || !registrationNo) return;

          const url =
            CTX +
            "/nurse/patientDetail/" +
            encodeURIComponent(currentPatient.patientNo) +
            "?registrationNo=" +
            encodeURIComponent(registrationNo || "") +
            (chartNo ? "&chartNo=" + encodeURIComponent(chartNo) : "");

          const res = await axios.get(url, { headers: getApiHeaders() });
          const d = res.data || {};

          // ✅ 오더 영역만 다시 렌더링
          renderOrders(d.chartList || []);
        } catch (e) {
          console.error("reloadOrdersOnly error:", e);
        }
      }

      //토글 방식..?
      async function togglePredrugStatus(btn, predetailNo, drugNo, currentCode) {
		  if (!predetailNo || !drugNo) {
		    alert("오더 키(predetailNo/drugNo)가 없어. 응답 데이터 확인해줘.");
		    return;
		  }
		
		  var cur = normalizeDrugStatus(currentCode);
		
		  // ✅ 이미 완료면 아무것도 못 하게 (이중 방어)
		  if (cur === "001") {
		    return;
		  }
		
		  // ✅ 단방향: 002(대기) -> 001(완료)만 허용
		  var next = "001";
		
		  var row = btn ? btn.closest("tr") : null;
		  var nameTd = row ? row.querySelector(".drug-name") : null;
		  var statusTd = row ? row.querySelector(".status-label") : null;
		
		  function applyUiByCode(code) {
			  var isDone = code === "001";

			  // 텍스트/색상(이건 너가 원하면 유지해도 됨)
			  if (nameTd) {
			    nameTd.classList.remove("drug-done", "drug-wait");
			    nameTd.classList.add(isDone ? "drug-done" : "drug-wait");
			  }

			  if (statusTd) {
			    statusTd.textContent = isDone ? "완료" : "대기";
			    statusTd.classList.remove("drug-done", "drug-wait");
			    statusTd.classList.add(isDone ? "drug-done" : "drug-wait");
			  }

			  if (btn) {
			    // ✅ 버튼 문구만 변경
			    btn.textContent = isDone ? "수행완료" : "미수행";

			    // ✅ 버튼 색은 바꾸지 않음 (btnClass 유지)
			    // 기존에 btn-destructive(빨강)로 생성돼 있으니 그대로 두고,
			    // 완료되면 비활성 표시만 추가

			    if (isDone) {
			      btn.disabled = true;
			      btn.classList.add("opacity-50");   // 흐리게
			      btn.style.cursor = "not-allowed";  // 커서
			      btn.removeAttribute("onclick");    // 클릭 차단(이중방어)
			    } else {
			      btn.disabled = false;
			      btn.classList.remove("opacity-50");
			      btn.style.cursor = "pointer";
			    }
			  }
			}

		
		  
		  // 먼저 UI 반영
		  applyUiByCode(next);
		
		  try {
		    btn.disabled = true; // 요청 중 잠깐 잠금
		
		    const res = await axios.post(
		      CTX + "/nurse/updateDrogStatus",
		      {
		        predetailNo: Number(predetailNo),
		        drugNo: Number(drugNo),
		        predrugDetailStatus: next,
		      },
		      { headers: getApiHeaders() },
		    );
		
		    if (res && res.data && res.data !== "success") {
		      applyUiByCode(cur);
		      sweetAlert("error", "상태 변경 실패(서버 응답 확인 필요)", "확인");
		      return;
		    }
		
		    sweetAlert("success", "주사 투약이 완료되었습니다!", "확인");
		
		    await selectPatient(currentPatient.patientNo, registrationNo, chartNo);
		  } catch (e) {
		    console.error("투약 상태 변경 실패", e);
		    applyUiByCode(cur);
		    sweetAlert("error", "투약 상태 변경 실패 (콘솔/네트워크 확인)", "확인");
		  } finally {
		    // ✅ 완료(next=001)면 다시 활성화하지 않음
		    // (실패해서 cur로 돌아간 경우만 다시 활성화)
		    if (btn && cur !== "001") btn.disabled = false;
		  }
		}
      

      //상병명 가져오기 (주상병이 항상 위로 오도록 정렬)
      function renderDiagnosis(list) {
        var body = document.getElementById("diagnosis-list-body");
        if (!body) return;

        body.innerHTML = "";

        if (!Array.isArray(list) || list.length === 0) {
          body.innerHTML =
            '<tr><td colspan="5" class="text-center">상병 없음</td></tr>';
          return;
        }

        // ✅ 주상병(Y) 먼저, 그 다음 부상병(N), 그 외는 뒤
        // ✅ 같은 그룹끼리는 원래 순서 유지(stable sort 방식으로 index 보존)
        var sorted = list
          .map(function (d, idx) {
            var yn = String(
              (d && (d.diagnosisDetailYn || d.diagnosisDetailYN)) || "",
            ).toUpperCase();
            var priority = yn === "Y" ? 0 : yn === "N" ? 1 : 2;
            return { d: d, idx: idx, yn: yn, priority: priority };
          })
          .sort(function (a, b) {
            if (a.priority !== b.priority) return a.priority - b.priority;
            return a.idx - b.idx; // 같은 우선순위면 원래 순서 유지
          });

        var html = "";
        for (var i = 0; i < sorted.length; i++) {
          var d = sorted[i].d || {};
          var yn = sorted[i].yn;

          // ⚠️ 정렬했으니 group도 i 기준으로 다시 부여
          var group = "diag_" + i;
          var mainChecked = yn === "Y" ? " checked" : "";
          var subChecked = yn === "N" ? " checked" : "";

          html +=
            "" +
            "<tr>" +
            "<td>" +
            (i + 1) +
            "</td>" +
            '<td class="text-center"><input type="radio" name="' +
            group +
            '"' +
            mainChecked +
            " disabled></td>" +
            '<td class="text-center"><input type="radio" name="' +
            group +
            '"' +
            subChecked +
            " disabled></td>" +
            "<td>" +
            (d.diagnosisCode || "") +
            "</td>" +
            "<td>" +
            (d.diagnosisName || "") +
            "</td>" +
            "</tr>";
        }

        body.innerHTML = html;
      }

      /* =========================
		   Safe Render Helpers (JSP-safe)
		========================= */
      function safe(v, fallback) {
        if (v === undefined || v === null) return fallback ?? "";
        return String(v);
      }

      //db에서 가져오는 상태값 문자로 변환
      function normalizeTreatStatus(v) {
        if (v === undefined || v === null) return "002";

        const s = String(v).trim();

        // 코드 그대로
        if (s === "001" || s === "002") return s;

        // 혹시 한글로 내려오는 경우 방어
        if (s === "완료") return "001";
        if (s === "대기") return "002";

        return "002";
      }

      function treatStatusText(code) {
        return code === "001" ? "완료" : "대기";
      }
      
   // ✅ 치료 처방 상태 뱃지(HTML) 반환
      function treatStatusBadgeHtml(code) {
        const c = normalizeTreatStatus(code); // "001"/"002"로 정규화

        if (c === "001") {
          // 완료
          return '<span class="tag tag-success">완료</span>';
        }
        // 대기
        return '<span class="tag tag-danger">대기</span>';
      }


      /* =========================
		   치료 처방 렌더링 
		========================= */
      function renderTreatList(chartListAll) {
        const body = document.getElementById("treat-list-body");
        if (!body) return;

        body.innerHTML = "";

        const list = Array.isArray(chartListAll) ? chartListAll : [];

        // chartListAll 안에 treatList들을 평탄화
        const treats = [];
        for (let i = 0; i < list.length; i++) {
          const item = list[i];
          const tl = item && item.treatList;
          if (Array.isArray(tl)) {
            for (let j = 0; j < tl.length; j++) {
              treats.push(tl[j]);
            }
          }
        }

        if (treats.length === 0) {
          body.innerHTML =
            '<tr><td colspan="8" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          return;
        }

        let html = "";
        for (let i = 0; i < treats.length; i++) {
          const treat = treats[i] || {};

          const method =
            treat.pretreatmentDetailMethod !== undefined &&
            treat.pretreatmentDetailMethod !== null &&
            String(treat.pretreatmentDetailMethod).trim() !== ""
              ? treat.pretreatmentDetailMethod
              : "치료";

          const code = normalizeTreatStatus(treat.pretreatmentDetailStatus);
          const badge = treatStatusBadgeHtml(code);

          html +=
            "" +
            "<tr>" +
            "<td>" +
            (i + 1) +
            "</td>" +
            "<td>" +
            safe(method) +
            "</td>" +
            "<td>" +
            safe(treat.treatmentCode) +
            "</td>" +
            "<td>" +
            safe(treat.treatmentName) +
            "</td>" +
            "<td>" +
            safe(treat.pretreatmentDetailDose) +
            "</td>" +
            "<td>" +
            safe(treat.pretreatmentDetailFreq) +
            "</td>" +
            "<td>" +
            safe(treat.pretreatmentDetailDay) +
            "</td>" +
            "<td>" +
            badge +
            "</td>" +
            "</tr>";
        }

        body.innerHTML = html;
      }

      /* =========================
		   약제 처방 렌더링 (JSP에서 절대 안 터짐)
		========================= */
      function renderDrugList(chartListAll) {
        const body = document.getElementById("drug-list-body");
        if (!body) return;

        body.innerHTML = "";

        const list = Array.isArray(chartListAll) ? chartListAll : [];

        // chartListAll 안에 drugList들을 평탄화 + 주사 제외
        const drugs = [];
        for (let i = 0; i < list.length; i++) {
          const item = list[i];
          const dl = item && item.drugList;
          if (Array.isArray(dl)) {
            for (let j = 0; j < dl.length; j++) {
              const d = dl[j];
              const method = String(d?.predrugDetailMethod || "").trim();

              if (method !== "주사") {
                // ✅ 여기서 주사 필터
                drugs.push(d);
              }
            }
          }
        }

        if (drugs.length === 0) {
          body.innerHTML =
            '<tr><td colspan="7" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          return;
        }

        let html = "";
        for (let i = 0; i < drugs.length; i++) {
          const drug = drugs[i] || {};

          html +=
            "" +
            "<tr>" +
            "<td>" +
            (i + 1) +
            "</td>" +
            "<td>" +
            safe(drug.drugCode) +
            "</td>" +
            "<td>" +
            safe(drug.drugName) +
            "</td>" +
            "<td>" +
            safe(drug.predrugDetailDose) +
            "</td>" +
            "<td>" +
            safe(drug.predrugDetailFreq) +
            "</td>" +
            "<td>" +
            safe(drug.predrugDetailDay) +
            "</td>" +
            "<td>" +
            safe(drug.predrugDetailMethod) +
            "</td>" +
            "</tr>";
        }

        body.innerHTML = html;
      }

      /* =========================
		   수술 처방 렌더링
		   - PredetailVO.chartListAll(혹은 predetailList) 안의 operList를 평탄화해서 출력
		========================= */
      function renderOpList(chartListAll) {
        var body = document.getElementById("opTable-list-body");
        if (!body) return;

        if (!Array.isArray(chartListAll) || chartListAll.length === 0) {
          body.innerHTML =
            '<tr><td colspan="3" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          return;
        }

        // ✅ 핵심: MyBatis collection property = operList
        var ops = [];
        for (var i = 0; i < chartListAll.length; i++) {
          var item = chartListAll[i] || {};

          var list = item.operList || item.operlist || item.oper || null; // 혹시 케이스 다른 방어
          if (list && !Array.isArray(list)) list = [list];

          if (Array.isArray(list)) {
            for (var j = 0; j < list.length; j++) {
              ops.push(list[j]);
            }
          }
        }

        if (ops.length === 0) {
          body.innerHTML =
            '<tr><td colspan="3" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          return;
        }

        // ✅ 조인 결과로 중복 뜰 수 있어서 제거
        var seen = {};
        var uniq = [];
        for (var k = 0; k < ops.length; k++) {
          var o = ops[k] || {};
          var key =
            String(o.operationNo || "") +
            "|" +
            String(o.operationCode || "") +
            "|" +
            String(o.operationName || "");
          key = key.trim();
          if (!key) key = "idx_" + k;
          if (seen[key]) continue;
          seen[key] = true;
          uniq.push(o);
        }

        var html = "";
        for (var x = 0; x < uniq.length; x++) {
          var op = uniq[x] || {};
          html +=
            "" +
            "<tr>" +
            "<td>" +
            (x + 1) +
            "</td>" +
            "<td>" +
            safe(op.operationCode) +
            "</td>" +
            "<td>" +
            safe(op.operationName) +
            "</td>" +
            "</tr>";
        }

        body.innerHTML = html;
      }
      
      
      /* =========================
	      검사 처방 렌더링
	      - PredetailVO.chartListAll 안의 examList(PREEXAMINATION_DETAIL)를 평탄화해서 출력
	      - tbody: #exam-list-body
	   ========================= */
	   function renderExamOrderList(chartListAll) {
	     var body = document.getElementById("exam-list-body");
	     if (!body) return;
	
	     if (!Array.isArray(chartListAll) || chartListAll.length === 0) {
	       body.innerHTML =
	         '<tr><td colspan="6" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
	       return;
	     }
	
	     // ✅ 핵심: MyBatis collection property = examList
	     var exams = [];
	     for (var i = 0; i < chartListAll.length; i++) {
	       var item = chartListAll[i] || {};
	
	       var list = item.examList || item.examlist || item.exam || null; // 방어
	       if (list && !Array.isArray(list)) list = [list];
	
	       if (Array.isArray(list)) {
	         for (var j = 0; j < list.length; j++) {
	           exams.push(list[j]);
	         }
	       }
	     }
	
	     if (exams.length === 0) {
	       body.innerHTML =
	         '<tr><td colspan="6" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
	       return;
	     }
	
	     // ✅ 조인 결과 중복 제거(검사번호 + 처방상세키 + 코드/명 기준)
	     var seen = {};
	     var uniq = [];
	     for (var k = 0; k < exams.length; k++) {
	       var e = exams[k] || {};
	
	       // XML 기반 필드명(VO 매핑에 따라 다를 수 있어서 최대한 커버)
	       var key =
	         String(e.preexaminationDetailNo || e.preexaminationNo || e.predetailNo || "") +
	         "|" +
	         String(e.examinationNo || "") +
	         "|" +
	         String(e.examinationCode || "") +
	         "|" +
	         String(e.examinationName || "") +
	         "|" +
	         String(e.preexaminationDetailSite || "");
	
	       key = key.trim();
	       if (!key) key = "idx_" + k;
	
	       if (seen[key]) continue;
	       seen[key] = true;
	       uniq.push(e);
	     }
	
	     // ✅ 상태 텍스트/배지(너가 이미 만든 함수 재사용 가능)
	     // - normalizeExamStatus / examStatusText / examStatusBadgeHtml 를 이미 너 코드에 만들어둔 상태라면 그대로 씀
	     // - 없으면 최소 텍스트로라도 찍히게 fallback
	     function statusHtml(code) {
	       if (typeof examStatusBadgeHtml === "function") return examStatusBadgeHtml(code);
	       if (typeof examStatusText === "function") return examStatusText(code);
	       return safe(code, "-");
	     }
	
	     var html = "";
	     for (var x = 0; x < uniq.length; x++) {
	       var e = uniq[x] || {};
	
	       // ✅ SQL 컬럼 기반 매핑(VO/alias에 따라 내려오는 키가 다를 수 있으니 다중 fallback)
	       var examName = e.examinationName || e.examName || "-";        // E1.EXAMINATION_NAME
	       var site     = e.preexaminationDetailSite || e.examSite || "-"; // ED.PREEXAMINATION_DETAIL_SITE
	       var lr       = e.preexaminationDetailLaterality || "-";   // (SQL엔 없음 → VO에 있으면 표시)
	       var fileNo   = e.attachmentNo || e.attachmentNO || "";        // ED.ATTACHMENT_NO
	       var st       = e.preexaminationDetailStatus || e.examStatus || ""; // ED.PREEXAMINATION_DETAIL_STATUS
	
	       // 파일 표시(attachmentNo 있으면 "있음", 없으면 "-")
	    // 첨부 아이콘(SVG) 문자열
	       const fileSvg = `
	    	   <svg
               class="content-group-icon"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
             >
               <path
                 d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"
               ></path>
               <polyline points="14 2 14 8 20 8"></polyline>
             </svg>
	       `;
	       

	       // 파일 표시(attachmentNo 있으면 아이콘, 없으면 "-")
	       var fileText = (String(fileNo ?? "").trim() !== "") ? fileSvg : "-";

	
	       html += ""
	         + "<tr>"
	         +   "<td>" + (x + 1) + "</td>"
	         +   "<td>" + safe(examName, "-") + "</td>"
	         +   "<td>" + safe(site, "-") + "</td>"
	         +   "<td>" + safe(lr, "-") + "</td>"
	         +   "<td>" + safe(fileText, "-") + "</td>"
	         +   "<td>" + statusHtml(st) + "</td>"
	         + "</tr>";
	     }
	
	     body.innerHTML = html;
	   }
	
	          
	      

      //내원 이력 스코프
      function switchTabScoped(event, tabId, scopeId) {
		  const clickedTab = event.currentTarget;
		
		  // 버튼 active
		  const tabContainer = clickedTab.closest(".tabs");
		  if (tabContainer) {
		    tabContainer.querySelectorAll(".tab").forEach(t => t.classList.remove("active"));
		    clickedTab.classList.add("active");
		  }
		
		  // 컨텐츠 active (scope 안에서만)
		  const scopeEl = document.getElementById(scopeId);
		  if (!scopeEl) return;
		
		  scopeEl.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
		
		  const target = scopeEl.querySelector("#" + tabId);
		  if (target) target.classList.add("active");
		}

      
      //탭 전환 잘 좀 돼라
     function resetVisitTabs() {
		  const btns = document.querySelectorAll("#center-panel .tabs-text .tab");
		  if (btns.length >= 2) {
		    btns[0].classList.add("active");
		    btns[1].classList.remove("active");
		  }
		
		  const scope = document.getElementById("visit-tabs-scope");
		  if (!scope) return;
		
		  scope.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
		  const tab11 = document.getElementById("tab11");
		  if (tab11) tab11.classList.add("active");
		}




      
   // ✅ 내원이력 렌더링 (XML: PredetailVO 기반)
      function renderHistory(visitHistory) {
		  var area = document.getElementById("history-list");
		  if (!area) return;
		
		  var list = Array.isArray(visitHistory) ? visitHistory : [];
		  if (list.length === 0) {
		    area.innerHTML = empty("내원이력이 없습니다.");
		    return;
		  }
		
		  var html = "";
		  for (var i = 0; i < list.length; i++) {
		    var x = list[i] || {};
		
		    var chartNoVal = x.chartNo || "";
		    var date = x.chartDate || "-";
		    var doctor = x.employeeName || "-";
		    var cnt = Number(x.predetailCnt || 0);
		    var done = cnt > 0;
		
		    var badgeHtml = done
		      ? '<span class="badge badge-success text-xs">진료 완료</span>'
		      : '<span class="badge badge-default text-xs">진료 전</span>';
		
		    var clickAttr = "";
		    if (String(chartNoVal).trim() !== "") {
		      clickAttr = ' onclick="loadHistory(\'' + String(chartNoVal) + '\')"';
		    }
		
		    html += ''
		      + '<div class="border rounded-md px-3 py-2 mb-2 cursor-pointer hover:bg-gray-50"' + clickAttr + '>'
		      +   '<div class="flex items-center justify-between">'
		      +     '<div class="flex items-center gap-2">'
		      +       '<span class="text-sm font-medium text-gray-800">' + date + '</span>'
		      +       badgeHtml
		      +     '</div>'
		      +     '<div class="flex items-center gap-1 text-sm text-gray-600">'
		      +       '<i class="icon icon-doctor icon-md icon-muted"></i>'
		      +       '<span><b>' + doctor + '</b></span>'
		      +     '</div>'
		      +   '</div>'
		      + '</div>';
		  }
		
		  area.innerHTML = html;
		}
		

   	  
   	  
   	  
   	  // ✅ 내원이력 항목 클릭 시: chartNo로 상세 재조회하고 우측 패널에 렌더링
      async function loadHistory(chartNo) {
        try {
          if (!currentPatient || !currentPatient.patientNo) return;
          if (!registrationNo) return;

          // ✅ 과거 차트 보기 모드 ON
          historyMode = true;

          // 현재 환자의 과거 chartNo로 재조회
          const url =
			  CTX + "/nurse/patientDetail/" + encodeURIComponent(currentPatient.patientNo) +
			  "?chartNo=" + encodeURIComponent(chartNo);


          const res = await axios.get(url, { headers: getApiHeaders() });
          const d = res.data || {};

          // 우측 패널: 과거차트 상세 렌더링
          renderClinicNote(d.chartListAll || []);
          renderOrders(d.chartList || []);
          renderDiagnosis(d.diagnosisList || []);
          renderTreatList(d.chartListAll || []);
          renderDrugList(d.chartListAll || []);
          renderOpList(d.chartListAll || []);

          // ✅ 우측 패널 열기(조건 무시)
          const msg = document.getElementById("right-empty-msg");
          if (msg) msg.innerHTML = "내원이력 조회 중입니다.";

          toggleRightPanel();
        } catch (e) {
          console.error("loadHistory error:", e);
          sweetAlert("error", "내원이력 상세 조회 실패", "확인");
        }
      }
		
		
      function normalizeExamStatus(v) {
    	  if (v === undefined || v === null) return "";

    	  var s = String(v).trim();

    	  // 한글로 내려오는 경우도 방어
    	  if (s === "완료") return "001";
    	  if (s === "대기") return "002";
    	  if (s === "진료중") return "003";
    	  if (s === "중단") return "004";

    	  // 숫자로 오면 001~로 보정 (1,2,3,4 같은 케이스)
    	  if (/^\d+$/.test(s)) s = s.padStart(3, "0");

    	  return s;
    	}

    	function examStatusText(code) {
    	  var c = normalizeExamStatus(code);

    	  if (c === "001") return "완료";
    	  if (c === "002") return "대기";
    	  if (c === "003") return "진료중";
    	  if (c === "004") return "중단";

    	  // 5번째 상태 있으면 여기 추가
    	  // if (c === "005") return "..."

    	  return c || "-";
    	}

    	function examStatusBadgeHtml(code) {
    	  var c = normalizeExamStatus(code);
    	  var text = examStatusText(c);

    	  // ✅ 프로젝트에 이미 존재하는 badge 스타일로 확실하게 표시
    	  var cls = "tag tag-default text-xs";
    	  if (c === "001") cls = "tag tag-success text-xs";
    	  else if (c === "002") cls = "tag tag-danger text-xs";
    	  else if (c === "003") cls = "tag tag-warning text-xs";
    	  else if (c === "004") cls = "tag tag-default text-xs";

    	  return '<span class="' + cls + '">' + text + "</span>";
    	}

		
      /* =========================
	      검사 결과 렌더링
	   ========================= */
	   function renderExamList(chartListAll){
	     var area = document.getElementById("exam-list");
	     if(!area) return;
	
	     var list = Array.isArray(chartListAll) ? chartListAll : [];
	
	     // 🔹 모든 predetail 안의 examList를 평탄화
	     var exams = [];
	     for(var i=0; i<list.length; i++){
	       var p = list[i];
	       if(p && Array.isArray(p.examList)){
	         for(var j=0; j<p.examList.length; j++){
	           exams.push(p.examList[j]);
	         }
	       }
	     }
	
	     // ❗ 검사 결과 없음
	     if(exams.length === 0){
	       area.innerHTML =
	         '<div class="empty-state empty-state-sm h-full flex flex-col items-center justify-center">' +
	         	'<svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'+
				    '<line x1="8" y1="6" x2="21" y2="6"></line>'+
				    '<line x1="8" y1="12" x2="21" y2="12"></line>'+
				    '<line x1="8" y1="18" x2="21" y2="18"></line>'+
				    '<line x1="3" y1="6" x2="3.01" y2="6"></line>'+
				    '<line x1="3" y1="12" x2="3.01" y2="12"></line>'+
				    '<line x1="3" y1="18" x2="3.01" y2="18"></line>' +
				'</svg>' +
	           '<div class="text-lg font-bold text-gray-500">목록 없음</div>' +
	           '<div class="text-sm text-gray-400 mt-1">등록된 검사결과가 없습니다.</div>' +
	         '</div>';
	       return;
	     }
	
	     // 🔹 (추후 확장용) 검사 결과가 있을 경우
	     var html = "";
	     for(var k=0; k<exams.length; k++){
	       var e = exams[k] || {};
	
	       var badge = examStatusBadgeHtml(e.preexaminationDetailStatus);

	       html += ''
	         + '<div class="border rounded-md px-3 py-2 mb-2">'
	         +   '<div class="flex justify-between items-center">'
	         +     '<div>'
	         +       '<div class="font-medium text-gray-800">' + (e.examinationName || '-') + '</div>'
	         +       '<div class="text-xs text-gray-500">' + (e.examinationCode || '') + '</div>'
	         +     '</div>'
	         +     badge
	         +   '</div>'
	         + '</div>';

	     }
	
	     area.innerHTML = html;
	   }
      


      /* =========================
	   Right Panel Condition (FIX)
	========================= */
      function toggleRightPanel() {
        const rightEmpty = document.getElementById("right-empty");
        const rightView = document.getElementById("right-view");
        if (!rightEmpty || !rightView) return;

        const s =
          currentPatient?.registrationVO?.registrationStatus ??
          currentPatient?.registrationStatus ??
          "";
        const statusLabel = normalizeStatus(s); // "진료중" 등으로 정규화
        const isTreating = statusLabel === "진료중";

        // ✅ 기본은 항상 "빈 화면" 먼저 세팅(잔상 방지)
        rightEmpty.classList.remove("hidden");
        rightView.classList.add("hidden");

     // ✅ 내원이력 상세보기 모드면 조건 없이 우측 패널을 보여줌
        if (historyMode) {
          rightEmpty.classList.add("hidden");
          rightView.classList.remove("hidden");
          return;
        }

        // ✅ "진료중"이면서 "우측에 표시할 데이터가 있으면" 우측 패널을 보여줌
        // (vitalExists 조건은 더 이상 우측 표시의 필수조건이 아님)
        if (isTreating && rightDataExists) {
          rightEmpty.classList.add("hidden");
          rightView.classList.remove("hidden");
          return;
        }

        // ✅ 그 외는 empty + 잔상 제거
        resetRightViewContents();

      }
      
      

      /** 우측 상세 영역(오더/상병/처방 등)을 "기본 상태"로 되돌려 잔상 제거 */
      function resetRightViewContents() {
        // 오더/상병/처방 테이블을 기본 문구로 리셋
        const orderBody = document.getElementById("order-list-body");
        if (orderBody)
          orderBody.innerHTML =
            '<tr><td colspan="5" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';

        const diagBody = document.getElementById("diagnosis-list-body");
        if (diagBody)
          diagBody.innerHTML =
            '<tr><td colspan="5" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';

        const treatBody = document.getElementById("treat-list-body");
        if (treatBody)
          treatBody.innerHTML =
            '<tr><td colspan="8" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';

        const drugBody = document.getElementById("drug-list-body");
        if (drugBody)
          drugBody.innerHTML =
            '<tr><td colspan="7" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';

        const opBody = document.getElementById("opTable-list-body");
        if (opBody)
          opBody.innerHTML =
            '<tr><td colspan="3" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';

        const note = document.getElementById("clinicNote");
        if (note) note.value = "진료 기록이 작성되어 있지 않습니다.";

        // 처치 완료 버튼/힌트도 기본 상태로 (원하면 유지해도 됨)
        const hint = document.getElementById("complete-hint");
        if (hint)
          hint.innerHTML = "※ <b>진료중</b> 상태에서만 처치 완료가 가능합니다.";
      }
      
      
      
      /* =========================
	      검사 상태 정규화
	      PREEXAMINATION_DETAIL_STATUS 기준
	   ========================= */
	   function normalizeExamStatus(v) {
	     if (v === undefined || v === null) return "002"; // 기본 대기
	
	     const s = String(v).trim();
	
	     // 코드 그대로
	     if (s === "001" || s === "002") return s;
	
	     // 혹시 한글로 내려오는 경우 방어(프로젝트에서 쓰는 용어 있으면 추가해도 됨)
	     if (s === "완료") return "001";
	     if (s === "대기") return "002";
	
	     return "002";
	   }

   /* =========================
      chartListAll 평탄화 유틸
   ========================= */
   function flattenTreats(chartListAll) {
     const list = Array.isArray(chartListAll) ? chartListAll : [];
     const treats = [];
     for (let i = 0; i < list.length; i++) {
       const tl = list[i]?.treatList;
       if (Array.isArray(tl)) for (let j = 0; j < tl.length; j++) treats.push(tl[j]);
     }
     return treats;
   }

   function flattenExams(chartListAll) {
     const list = Array.isArray(chartListAll) ? chartListAll : [];
     const exams = [];
     for (let i = 0; i < list.length; i++) {
       const el = list[i]?.examList;
       if (Array.isArray(el)) for (let j = 0; j < el.length; j++) exams.push(el[j]);
     }
     return exams;
   }

   /* =========================
      ✅ 처치완료 활성화 조건(확장판)
      - 오더(chartList): predrugDetailStatus 모두 001
      - 치료(treatList): pretreatmentDetailStatus 모두 001
      - 검사(examList): PREEXAMINATION_DETAIL_STATUS(= preexaminationDetailStatus) 모두 001
      - 항목이 "없으면" 통과(기존 정책 유지)
   ========================= */
   function getIncompleteReasons(data) {
     const reasons = [];

     const orders = Array.isArray(data?.chartList) ? data.chartList : [];
     if (orders.length > 0) {
       for (let i = 0; i < orders.length; i++) {
         const code = normalizeDrugStatus(orders[i]?.predrugDetailStatus);
         if (code !== "001") { reasons.push("투약/처치(오더)"); break; }
       }
     }

     const treats = flattenTreats(data?.chartListAll);
     if (treats.length > 0) {
       for (let i = 0; i < treats.length; i++) {
         const code = normalizeTreatStatus(treats[i]?.pretreatmentDetailStatus);
         if (code !== "001") { reasons.push("치료 처방"); break; }
       }
     }

     const exams = flattenExams(data?.chartListAll);
     if (exams.length > 0) {
       for (let i = 0; i < exams.length; i++) {
         // ✅ 여기: PREEXAMINATION_DETAIL_STATUS (VO에서는 보통 preexaminationDetailStatus로 옴)
         const code = normalizeExamStatus(exams[i]?.preexaminationDetailStatus);
         if (code !== "001") { reasons.push("검사 내역"); break; }
       }
     }

     return reasons;
   }

   function isAllDoneForCompleteTreatment(data) {
     return getIncompleteReasons(data).length === 0;
   }

      

      //처치 완료 버튼 실행 조건 필터링
      function isAllOrdersDone(orderList) {
        if (!Array.isArray(orderList) || orderList.length === 0) return true; // 오더 없으면 통과(정책)

        for (var i = 0; i < orderList.length; i++) {
          var o = orderList[i] || {};
          var code = normalizeDrugStatus(o.predrugDetailStatus); // 네가 이미 만든 함수 재사용 (001/002 변환)
          if (code !== "001") return false; // 하나라도 완료 아니면 실패
        }
        return true;
      }

      //버튼 활성화/비활성화 조건
      function updateCompleteTreatmentButton(data) {
		  const btn = document.getElementById("btn-complete-treatment");
		  const hint = document.getElementById("complete-hint");
		  if (!btn) return;
		
		  // ✅ [추가] 우측 패널(진료기록/오더/상병/처방)이 "전부 비어있으면" 처치완료 비활성
		  const hasData =
		    (typeof hasRightPanelData === "function") ? hasRightPanelData(data) : true;
		
		  if (!hasData) {
		    btn.disabled = true;
		    btn.classList.add("opacity-50");
		    btn.style.cursor = "not-allowed";
		
		    if (hint) {
		      hint.innerHTML =
		        "※ 처치 완료 불가: <b>진료/처방 데이터가 없습니다.</b> (진료기록/오더/상병/처방 중 최소 1개 이상 존재해야 합니다.)";
		    }
		    return; // ✅ 여기서 종료
		  }
		
		  // ---- 기존 로직 유지 ----
		  const reasons = getIncompleteReasons(data); // ["투약/처치(오더)", "치료 처방", "검사 내역"] 등
		  const ok = reasons.length === 0;
		
		  if (ok) {
		    btn.disabled = false;
		    btn.classList.remove("opacity-50");
		    btn.classList.add("btn-primary");
		    btn.style.cursor = "pointer";
		
		    if (hint) hint.innerHTML = "※ <b>처치 완료</b> 버튼을 눌러 진료를 종료하세요.";
		  } else {
		    btn.disabled = true;
		    btn.classList.add("opacity-50");
		    btn.style.cursor = "not-allowed";
		
		    if (hint) {
		      hint.innerHTML =
		        "※ 처치 완료 조건 미충족: <b>" + reasons.join(", ") +
		        "</b> 의 모든 상태가 <b>완료</b>여야 합니다.";
		    }
		  }
		}



      //'처치 완료' 처리 수행
      async function completeTreatment(btn) {
        try {
          if (!currentPatient || !registrationNo) {
            sweetAlert("warning", "환자를 먼저 선택해주세요.", "확인");
            return;
          }

          // 현재 환자 재조회 후 orderList 검사
          const url =
            CTX +
            "/nurse/patientDetail/" +
            encodeURIComponent(currentPatient.patientNo) +
            "?registrationNo=" +
            encodeURIComponent(registrationNo || "") +
            (chartNo ? "&chartNo=" + encodeURIComponent(chartNo) : "");

          const res = await axios.get(url, { headers: getApiHeaders() });
          const d = res.data || {};
          const orderList = d.chartList || [];
          
       // ✅ [추가] 우측 패널 데이터 자체가 없으면 처치완료 불가(서버 기준 최종 방어)
          if (!hasRightPanelData(d)) {
            sweetAlert(
              "warning",
              "진료/처방 데이터가 없어 처치 완료를 할 수 없습니다.\n\n(진료기록/오더/상병/처방 중 최소 1개 이상 필요)",
              "확인"
            );
            updateCompleteTreatmentButton(d); // 버튼/힌트 즉시 동기화
            return;
          }


          if (!isAllDoneForCompleteTreatment(d)) {
        	  const reasons = getIncompleteReasons(d);

        	  sweetAlert(
        	    "warning",
        	    "아직 완료되지 않은 항목이 있습니다.\n\n미완료: " + reasons.join(", ") + "\n\n모든 항목이 '완료(001)'여야 처치 완료가 가능합니다.",
        	    "확인"
        	  );

        	  // ✅ 버튼/힌트 즉시 갱신
        	  updateCompleteTreatmentButton(d);
        	  return;
        	}


          if (btn) btn.disabled = true;

          // ✅ registrationStatus 를 004(수납대기)로 변경
          await axios.post(
            CTX + "/nurse/updateStatus",
            { registrationNo: registrationNo, status: "004" },
            { headers: getApiHeaders() },
          );

          sweetAlert(
            "success",
            "처치 완료! <br>상태가 수납대기로 변경되었습니다.",
            "확인",
          );

          // ✅ 리스트만 갱신하고, 화면은 닫기
          await loadPatientList();

          // ✅ 여기서 환자 상세 닫기(중앙/우측 초기화)
          closeInfoView();
        } catch (e) {
          console.error("completeTreatment error:", e);
          sweetAlert(
            "warning",
            "처치 완료 처리 중 오류 (콘솔/네트워크 확인)",
            "확인",
          );
        } finally {
          if (btn) btn.disabled = false;
        }
      }

      /* =========================================================
		   closeInfoView() - 의사페이지 방식 그대로, 간호사 페이지 DOM/상태에 맞춘 버전
		   - X 버튼 onclick="closeInfoView()" 에서 바로 호출됨
		   - 목적:
		     1) 가운데 환자 상세 패널 닫고(empty-view로)
		     2) 우측 패널 잔상 제거 + right-empty로
		     3) 선택 환자/접수/차트/바이탈 상태 전역값 초기화
		     4) 바이탈 입력칸/메모/내원이력 등도 초기화
		========================================================= */

      function closeInfoView() {
        // 1) 전역 상태 초기화
        currentPatient = null;
        registrationNo = null;
        chartNo = null;
        vitalExists = false;

        // 2) 가운데 패널: 상세 숨기고 empty-view 표시
        const emptyView = document.getElementById("empty-view");
        const detailView = document.getElementById("detail-view");
        if (detailView) detailView.style.display = "none";
        if (emptyView) emptyView.style.display = "flex";

        // 3) 가운데 상세 내용(환자 기본 정보) 비우기
        setTextSafe("view-employeeName", "");
        setTextSafe("view-patient-no", "");
        setTextSafe("view-patient-name", "");
        setTextSafe("view-age-gen", "");
        setTextSafe("view-birth", "");
        setTextSafe("view-regno1", "");
        setTextSafe("view-regno2", "");
        setTextSafe("view-tel", "");
        setTextSafe("view-addr", "");
        setTextSafe("view-registration-insurance", "");

        // 4) 바이탈 입력 초기화
        fillVitalInputs(null);

        // 5) 메모 초기화
        const memoEl = document.getElementById("input-memo");
        if (memoEl) memoEl.value = "";
        setMemoBaseline("");

        // 6) 내원이력 초기화
        const historyArea = document.getElementById("history-list");
        if (historyArea) historyArea.innerHTML = "";

        // 7) 우측 패널: 항상 빈화면으로 + 잔상 제거
        const rightEmpty = document.getElementById("right-empty");
        const rightView = document.getElementById("right-view");
        if (rightEmpty) rightEmpty.classList.remove("hidden");
        if (rightView) rightView.classList.add("hidden");

        // 네가 이미 만들어둔 잔상 제거 함수 재사용
        if (typeof resetRightViewContents === "function") {
          resetRightViewContents();
        } else {
          // 혹시 함수명이 바뀌었을 때 안전장치(최소 리셋)
          const orderBody = document.getElementById("order-list-body");
          if (orderBody)
            orderBody.innerHTML =
              '<tr><td colspan="5" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          const diagBody = document.getElementById("diagnosis-list-body");
          if (diagBody)
            diagBody.innerHTML =
              '<tr><td colspan="5" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          const treatBody = document.getElementById("treat-list-body");
          if (treatBody)
            treatBody.innerHTML =
              '<tr><td colspan="8" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          const drugBody = document.getElementById("drug-list-body");
          if (drugBody)
            drugBody.innerHTML =
              '<tr><td colspan="7" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          const opBody = document.getElementById("opTable-list-body");
          if (opBody)
            opBody.innerHTML =
              '<tr><td colspan="3" class="text-center">조회하신 정보가 존재하지 않습니다.</td></tr>';
          const note = document.getElementById("clinicNote");
          if (note) note.value = "진료 기록이 작성되어 있지 않습니다.";
        }
      }

      /* 작은 헬퍼: 요소 없을 때 에러 방지 */
      function setTextSafe(id, text) {
        const el = document.getElementById(id);
        if (el) el.textContent = text ?? "";
      }
    </script>
  </body>
</html>
