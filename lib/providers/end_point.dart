const String NO_INTERNET_CONNECTION = "no_internet_connection";
const String CONNECTIVITY_ENDPOINT = "www.google.com";
// network
// const String BASE_URL = "http://192.168.0.136:8000/api/"; // for netwo rk
// const String MEDIA_LINK = "http://192.168.0.136:8000/media/";
// const String MEDIA_LINK_NO_SLASH = "http://192.168.0.136:8000";
// const String CHAT_SOCKET_LINK = 'ws://192.168.0.136:8000/' + "ws/chat/"; //Simulator
// simulator
// const String BASE_URL = "http://127.0.0.1:8000/api/"; // for simulator
// const String MEDIA_LINK = "http://127.0.0.1:8000/media/";
// const String MEDIA_LINK_NO_SLASH = "http://127.0.0.1:8000";
// const String CHAT_SOCKET_LINK = 'ws://127.0.0.1:8000/' + "ws/chat/"; //Simulator
// emulator
const String BASE_URL = "http://10.0.2.2:8000/api/"; // for emulator
const String MEDIA_LINK = "http://10.0.2.2:8000/media/";
const String MEDIA_LINK_NO_SLASH = "http://10.0.2.2:8000";
const String CHAT_SOCKET_LINK = 'ws://10.0.2.2:8000/' + "ws/chat/"; //emulator

// USER URL
const String LOGIN_URL = BASE_URL + "token/custom/";
const String REGISTER_URL = BASE_URL + "user/register/";
const String USER_BASIC_INFO = BASE_URL + "user/basic/info/";

// GENERAL URL
const String DOCTOR_TITLE_URL = BASE_URL + "public/title/";
const String CITY_URL = BASE_URL + "public/city/";
const String DISTRICT_URL = BASE_URL + "public/district/";
const String CARE_SERVICE_LIST = BASE_URL + "public/care/service/";
const String CITY_DISTRICT_LIST = BASE_URL + "public/city/district/list/";
const String EDUCATION_SUB_LIST = BASE_URL + "public/education/sub/list/";
const String OPT_VERIFICATION = BASE_URL + "user/otp/";

// DOCTOR URL
const String VIEW_DOCTOR_PROFILE_PLUS = BASE_URL + "doctor/view/profile/";
const String CLINIC_BRIEF = BASE_URL + "doctor/clinic/brief/";
const String BOOKED_APPT_LIST = BASE_URL + "doctor/booked/appt/";
const String MY_PATIENT_LIST = BASE_URL + "doctor/patient/list/";
const String CLINIC_ALL_APPT = BASE_URL + "doctor/appt/list/";
const String CLINIC_LIST = BASE_URL + "doctor/clinic/list/";
const String EXPERIENCE_LIST = BASE_URL + "doctor/experience/list/";
const String BIO_GET_POST = BASE_URL + "doctor/bio/list/";
const String AWARD_GET_POST = BASE_URL + "doctor/award/list/";
const String PATIENT_BOOKED_COMPLETED_APPT = BASE_URL + "doctor/patient/detail/";
const String PATIENT_MEDICAL_RECORD = BASE_URL + "doctor/patient/record/";
const String PATIENT_USER_DEATAIL = BASE_URL + "doctor/patient/";
const String APPT_FEEDBACK_GET_POST = BASE_URL + "doctor/appt/feedback/";
const String FEEDBACK_DELETE_UPDATE = BASE_URL + "doctor/feedback/";
const String NOTE_GET = BASE_URL + "doctor/note/list/";
const String NOTE_DELETE = BASE_URL + "doctor/note/";
const String CHANGE_PASS = BASE_URL + "doctor/change/pass/";
const String APPT_DETAIL_PLUS = BASE_URL + "doctor/appt/detail/";
const String BASIC_INFO = BASE_URL + "doctor/basic/info/4/";
const String PROFILE_SUBMISSION = BASE_URL + "doctor/profile/submission/";

// Chat
const String CHAT_GET_POST = BASE_URL + "chat/";
const String CHAT_USER_LIST = BASE_URL + "chat/user/list/";
