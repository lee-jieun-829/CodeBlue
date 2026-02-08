<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="h-full flex flex-col">
    <div class="content-header mb-3">
            <div class="content-header-title text-lg">
                퇴원 오더 관리
                <div style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-top:4px;">
                    의사의 최종 퇴원 오더를 확인하고, 환자 상태를 '퇴원 대기'로 변경하여 원무과 수납 시스템으로 데이터를 이관합니다.
                </div>
            </div>
        </div>
    
    <div class="callout callout-info mb-6">
        <div class="callout-title font-bold text-lg">퇴원 지시 있음</div>
        <div class="callout-content mt-2 space-y-1">
            <p class="text-sm">담당의: <strong>Dr. 장우선</strong></p>
            <p class="text-base font-bold text-blue-700">퇴원 예정일: 2025년 12월 17일 14:00</p>
        </div>
    </div>   

    <div class="mt-auto">
    	<button class="btn btn-warning-light"> 환자 상태 '수납 대기'로 변경 (원무과 이관)</button>        
    </div>
</div>