import { execFile } from "child_process";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

const OLLAMA_BASE_URL = process.env.OLLAMA_BASE_URL || "http://127.0.0.1:11434";
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || "gemma3:4b";
const MAX_TEXT_LENGTH = 12000;

const runCommand = async (command, args, options = {}) => {
  const { stdout } = await execFileAsync(command, args, {
    maxBuffer: 10 * 1024 * 1024,
    timeout: 60000,
    ...options,
  });
  return stdout;
};

const normalizeWhitespace = (value) =>
  String(value || "")
    .replace(/\r/g, "\n")
    .replace(/[\t ]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim();

const extractTextFromPdf = async (filePath) => {
  try {
    const text = await runCommand("pdftotext", ["-layout", "-enc", "UTF-8", filePath, "-"]);
    return normalizeWhitespace(text).slice(0, MAX_TEXT_LENGTH);
  } catch (error) {
    console.warn("PDF 텍스트 추출 실패:", error.message);
    return "";
  }
};

export const extractCertificateText = async (filePath, ext) => {
  if (ext.toLowerCase() !== ".pdf") return "";
  return extractTextFromPdf(filePath);
};

const stripJsonFence = (value) =>
  String(value || "")
    .trim()
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/```$/i, "")
    .trim();

const normalizeDate = (value) => {
  const raw = String(value || "").trim();
  if (!raw || raw === "-") return "";

  const iso = raw.match(/(20\d{2})[-./년\s]+(\d{1,2})[-./월\s]+(\d{1,2})/);
  if (iso) {
    const [, year, month, day] = iso;
    return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
  }

  const compact = raw.match(/(20\d{2})(\d{2})(\d{2})/);
  if (compact) {
    const [, year, month, day] = compact;
    return `${year}-${month}-${day}`;
  }

  return raw;
};

export const extractCourseMetadata = async (certificateText) => {
  const text = normalizeWhitespace(certificateText);
  if (!text) {
    return { courseName: "", courseDate: "", error: "수료증에서 머신 리더블 텍스트를 추출하지 못했습니다." };
  }

  const prompt = `다음은 교육 수료증 PDF에서 머신 리더블 텍스트로 추출한 내용입니다.\n수료증의 실제 강의명과 강의날짜만 찾아 JSON으로 답하세요.\n\n규칙:\n- JSON 외 다른 설명은 쓰지 마세요.\n- 강의명은 수료증에 적힌 교육/강의/과정명을 의미합니다.\n- 강의날짜는 실제 수강일, 교육일, 이수일, 수료일 중 수료증에 가장 명확히 표시된 날짜입니다.\n- 날짜는 가능하면 YYYY-MM-DD 형식으로 답하세요.\n- 찾을 수 없으면 빈 문자열을 넣으세요.\n\n응답 형식:\n{"courseName":"","courseDate":""}\n\n수료증 텍스트:\n${text}`;

  try {
    const response = await fetch(`${OLLAMA_BASE_URL}/api/generate`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: OLLAMA_MODEL,
        prompt,
        stream: false,
        format: "json",
        options: { temperature: 0 },
      }),
    });

    if (!response.ok) {
      throw new Error(`Ollama 응답 오류: HTTP ${response.status}`);
    }

    const data = await response.json();
    const parsed = JSON.parse(stripJsonFence(data.response));

    return {
      courseName: String(parsed.courseName || parsed.lectureName || "").trim(),
      courseDate: normalizeDate(parsed.courseDate || parsed.lectureDate || ""),
      error: "",
    };
  } catch (error) {
    return { courseName: "", courseDate: "", error: error.message };
  }
};

export const analyzeCertificate = async (filePath, ext) => {
  const certificateText = await extractCertificateText(filePath, ext);
  const metadata = await extractCourseMetadata(certificateText);

  return {
    certificateText,
    courseName: metadata.courseName,
    courseDate: metadata.courseDate,
    error: metadata.error,
  };
};
