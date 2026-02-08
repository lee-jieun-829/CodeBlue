<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<!-- 전제 환자 목록 스크롤 적용을 위해 따로 분리 -->
                    <!-- tab content 적용해야 함 -->
                    <div class="flex-1 overflow-auto" style="margin-right: -1rem;"> 
                        <div class="card-group">

                            <!-- 접수대기 -->
                            <div class="card">
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-cash">접수대기</div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>

                            <!-- 진료중 -->
                            <div class="card overflow-visible"> <!--환자호출 해야 할 때 overflow-visible 클래스 붙여야만 환자호출 button 출력-->
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-going">진료중</div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>


                            <!-- 진료 대기 -->
                            <div class="card overflow-visible"> <!--환자호출 해야 할 때 overflow-visible 클래스 붙여야만 환자호출 button 출력-->
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-default" onclick="toggleDropdown(event, 'dropdown1')">진료대기</div>
                                        <div class="dropdown-menu" id="dropdown1">
                                            <a href="#" class="dropdown-item">
                                                <span class="dropdown-item-text">환자 호출</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>

                            <!-- 대기 -->
                            <div class="card overflow-visible"> <!--환자호출 해야 할 때 overflow-visible 클래스 붙여야만 환자호출 button 출력-->
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-default" onclick="toggleDropdown(event, 'dropdown1')">대기</div>
                                        <div class="dropdown-menu" id="dropdown1">
                                            <a href="#" class="dropdown-item">
                                                <span class="dropdown-item-text">환자 호출</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>
                            <!-- 대기 -->
                            <div class="card overflow-visible"> <!--환자호출 해야 할 때 overflow-visible 클래스 붙여야만 환자호출 button 출력-->
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-default" onclick="toggleDropdown(event, 'dropdown1')">대기</div>
                                        <div class="dropdown-menu" id="dropdown1">
                                            <a href="#" class="dropdown-item">
                                                <span class="dropdown-item-text">환자 호출</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>
                            <!-- 대기 -->
                            <div class="card overflow-visible"> <!--환자호출 해야 할 때 overflow-visible 클래스 붙여야만 환자호출 button 출력-->
                                <div class="card-header py-1 flex justify-between">
                                    <h4 class="card-title text-sm">1215002</h4>
                                    <div class="relative">
                                        <div class="status-default" onclick="toggleDropdown(event, 'dropdown1')">대기</div>
                                        <div class="dropdown-menu" id="dropdown1">
                                            <a href="#" class="dropdown-item">
                                                <span class="dropdown-item-text">환자 호출</span>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="flex items-center">
                                        <h3 class="text-base font-bold mb-1">김유정</h3>
                                        <p class="description text-sm mb-1 ml-3">M / 30세 (950203)</p>
                                    </div>
                                    <span class="badge badge-default">건강보험</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                </div>
</body>
</html>