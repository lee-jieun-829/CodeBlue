import api from "./axios";

/**
 * 관리자 통계 API
 * - 연도기준 월별 외래&입원 업무량(CNT) + 수납금액(AMOUNT)
 * - 성별/연령별 인구통계
 * - 초진&재진 환자 통계
*/

const STATS = "/admin/stats";

// 연도기준 월별 외래&입원 업무량(CNT) + 수납금액(AMOUNT)
export const getYearsStats=(params = {}) => {
    console.log("[API.YearsStatsChart params]", params);
    return api.get(`${STATS}/yearstats`, {params});
}

// 성별&연령별 환자 통계
export const getDemographicsStats = (params = {}) => {
    console.log("[API.getDemographicStats params]", params);
    return api.get(`${STATS}/demographics`, {params});
}

// 일별 신규/재방문 환자 추이 (파라미터: { year: 2026, month: 3 })
export const getDailyPatientStats = (params = {}) => {
    console.log("[API.getDailyPatientStats params]", params);
    return api.get(`${STATS}/dailyPatients`, {params});
}