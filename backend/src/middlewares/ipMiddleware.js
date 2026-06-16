import db from "../database.js";
import ipRangeCheck from "ip-range-check";
import requestIp from "request-ip";

export const checkIpWhitelist = (req, res, next) => {
  const clientIp = requestIp.getClientIp(req);
  const row = db
    .prepare("SELECT value FROM settings WHERE key = 'allowed_ip_range'")
    .get();

  // 설정이 없거나 비어있으면 모든 접속 허용 (초기 상태)
  if (!row || !row.value || row.value.trim() === "") {
    return next();
  }

  // 허용 리스트 배열로 변환 (쉼표로 구분)
  const allowedIps = row.value.split(",").map((ip) => ip.trim());

  allowedIps.push("127.0.0.1");
  allowedIps.push("::1");

  // ipRangeCheck(확인할IP, 허용목록) -> 하나라도 맞으면 true 반환
  const isAllowed = ipRangeCheck(clientIp, allowedIps);

  if (isAllowed) {
    next();
  } else {
    console.warn(`⛔ 차단된 IP 접속 시도: ${clientIp}`);
    res
      .status(403)
      .json({ message: `접속이 허용되지 않은 IP입니다. (${clientIp})` });
  }
};
