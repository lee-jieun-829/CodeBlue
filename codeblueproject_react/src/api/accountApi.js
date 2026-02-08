import api from "./axios";

/**
 * 관리자 계정 관리 API
 * - "/admin/" 시작, api는 이미 axios에서 설정했음 (여기서 사용시 중복됨!!!)
 * - 역할 : 목록, 생성, 수정, 삭제(퇴사), 검색, 엑셀 일괄 다운로드, 엑셀 일괄 등록
*/

const EMPLOYEE = "/admin/employees";

/**
 * 전체 등록된 직원 조회 (메인 화면) + filter
 * filter : position (직책) / sort (정렬) / keyword (검색어)
 */
export const getEmployee = (params = {}) => {
  console.log("[API.getEmployee params]", params);
  return api.get(EMPLOYEE, { params });
};

//  계정 상세보기
export const getEmployeeDetail = (employeeNo) => {
    return api.get(`${EMPLOYEE}/${employeeNo}`);
};

// 계정 생성 (헤더 지운 이유 : axios가 formdata 보고 알아서 처리해줌)
export const createEmployee = (formData) => {
    return api.post(EMPLOYEE, formData);
};

//  계정 수정
export const updateEmployee = (employeeNo, formData) => {
    return api.post(`${EMPLOYEE}/${employeeNo}/update`, formData);
};

// 계정 삭제 (퇴사 처리)
export const retireEmployee = (employeeNo) => {
    return api.post(`${EMPLOYEE}/${employeeNo}/retire`);
};

// 엑셀 일괄 등록 (헤더 지운 이유 : axios가 formdata 보고 알아서 처리해줌)
export const uploadExcel = (formData) => {
  return api.post(`${EMPLOYEE}/excel/upload`, formData);
};

/**
 * 엑셀 다운로드
 * - 파일 데이터(Binary)를 받으니까 'blob' 타입 설정 (설정 안하면 엑셀 파일 깨짐)
 */
export const downloadExcel = async (params) => {
  return api.get(`${EMPLOYEE}/excel/download`,{
    params,
    responseType : "blob"
  });
};

// 전체 배정관리
export const getLocationList = (params = {}) => {
  return api.get(`${EMPLOYEE}/location`, { params });
};

// 특정 직원 배정 조회
export const getEmployeeLocation = (employeeNo) => {
  console.log({employeeNo});
  return api.get(`${EMPLOYEE}/location/${employeeNo}`);
};

// 배정 수정 & 저장
export const saveEmployeeLocation = (data) => {
  return api.post(`${EMPLOYEE}/location/save`, data);
};