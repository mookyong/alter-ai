# 8부. Graphify 적용: 프로젝트 지식 그래프 생성 및 OpenCode와 연계하기

이번 장에서는 Graphify를 사용해 프로젝트 문서와 구조를 지식 그래프로 만들고, OpenCode와 함께 활용하는 방법을 정리합니다.

이번 장의 핵심은 다음입니다.

```text
Graphify는 문서와 구조의 연결 관계를 시각화한다.
PL은 그래프를 보고 누락 문서, 연결 약점, 중심 문서를 파악한다.
OpenCode는 그래프 결과를 참고해 문서 점검과 요약을 더 정확하게 수행한다.
```

---

## 1. 이번 장의 목표

이번 장을 완료하면 다음을 이해하고 사용할 수 있습니다.

| 항목 | 목표 |
| --- | --- |
| Graphify 역할 | 문서, 폴더, 링크, 키워드의 관계를 그래프로 표현 |
| 생성 범위 | `docs/`, `scripts/`, `dbt_project/` 중심의 연결 파악 |
| 제외 범위 | `data/`, 개인 메모, 대용량 첨부는 제외 |
| 결과 해석 | 중심 문서, 고립 문서, 연결 부족 영역 파악 |
| OpenCode 연계 | 그래프 결과를 바탕으로 문서 점검/요약 정확도 향상 |

---

## 2. Graphify를 사용하는 이유

문서가 많아지면 단순 파일 목록만으로는 구조를 파악하기 어렵습니다.

예를 들어 다음 질문에 답하려면 연결 관계가 필요합니다.

```text
어떤 문서가 기준 문서인가?
어떤 회의록이 이슈 문서와 연결되는가?
어떤 설계 문서가 실행 문서와 이어지는가?
어떤 문서가 고립되어 누락 관리 대상인가?
```

Graphify는 이런 관계를 한 번에 보여주는 용도입니다.

```text
Graphify = 프로젝트 문서/구조의 연결 관계 지도
```

---

## 3. 그래프 생성 대상과 제외 대상

Graphify는 모든 파일을 무조건 포함하지 않습니다.

권장 대상은 다음입니다.

```text
docs/
scripts/
dbt_project/
.opencode/
.vscode/
README.md
AGENTS.md
opencode.jsonc
```

제외 대상은 다음입니다.

```text
data/
docs/91_attachments/
docs/98_private_notes/
docs/99_archive/
.git/
graphify-out/
.code-review-graph/
dbt_project/target/
logs/
```

제외 이유는 아래와 같습니다.

| 대상 | 제외 이유 |
| --- | --- |
| `data/` | 표/CSV/Excel 같은 데이터 파일은 그래프 연결 가치가 낮음 |
| `docs/91_attachments/` | 이미지/PDF 첨부가 많아 노이즈가 커짐 |
| `docs/98_private_notes/` | 개인 메모는 그래프에 올리지 않음 |
| `docs/99_archive/` | 과거/폐기 문서는 현재 운영 그래프와 분리 |
| `.git/` | 버전 관리 내부 데이터는 분석 대상 아님 |

---

## 4. Graphify 전 점검

Graphify를 실행하기 전에 다음을 확인합니다.

```text
1. 제외 폴더가 올바른지
2. 문서 링크가 충분한지
3. 공식 문서와 개인 메모가 분리되어 있는지
4. 대용량 첨부가 제외되는지
5. 현재 문서 구조가 최신인지
```

OpenCode command로는 다음을 사용할 수 있습니다.

```text
/graphify-check
```

이 command는 다음 확인에 적합합니다.

| 확인 항목 | 설명 |
| --- | --- |
| 제외 폴더 | 그래프에 들어가면 안 되는 폴더가 맞는지 |
| 대용량 파일 | PDF, 이미지, Excel이 과도하게 포함되지 않는지 |
| 개인 메모 | 비공개 메모가 그래프에 포함되지 않는지 |
| 링크 밀도 | 핵심 문서 간 연결이 충분한지 |
| 문서 최신성 | 주요 관리 문서가 최신 버전인지 |

---

## 5. Graphify 실행 흐름

실행 흐름은 다음처럼 생각하면 됩니다.

```text
대상 범위 확인
  ↓
Graphify 실행
  ↓
그래프 결과 검토
  ↓
고립 문서/중심 문서 확인
  ↓
문서 보강 또는 인덱스 보완
```

예상 산출물은 다음과 같습니다.

```text
graphify-out/graph_report.md
graphify-out/graph.png
graphify-out/node_list.md
graphify-out/link_summary.md
```

실제 산출물 이름은 환경에 따라 다를 수 있습니다.

---

## 6. 그래프에서 보는 핵심 포인트

Graphify 결과를 볼 때는 아래 항목부터 확인합니다.

| 확인 포인트 | 의미 |
| --- | --- |
| 중심 문서 | 가장 많이 연결된 기준 문서 |
| 고립 문서 | 링크가 거의 없어 관리가 필요한 문서 |
| 군집 | 같은 주제끼리 묶인 영역 |
| 연결 단절 | 회의록에서 관리 문서로 이어지지 않는 구간 |
| 반복 링크 | 같은 문서를 여러 곳에서 참조하는 구조 |

PL 관점에서는 다음 질문이 중요합니다.

```text
어떤 문서가 기준 허브인가?
어떤 문서가 빠져 있나?
어떤 경로로 회의 내용이 관리 문서로 흘러가는가?
어떤 영역이 문서 연결이 약한가?
```

---

## 7. 문서 구조와 그래프 해석

이 프로젝트에서는 아래 구조가 이상적입니다.

```text
회의록 → issue/risk/decision/action → dashboard → report
      ↘                         ↘
       mapping/validation        index/home
```

그래프에서 기대하는 모습은 다음입니다.

| 구조 | 기대 모습 |
| --- | --- |
| 회의록 | 이슈, 리스크, 결정, 액션 문서와 연결 |
| 관리 문서 | dashboard, report와 연결 |
| 설계 문서 | scope, design, validation과 연결 |
| 홈/인덱스 | 모든 주요 문서의 진입점 역할 |

만약 `000_HOME.md`나 `001_DOCUMENT_INDEX.md`가 중심에서 벗어나 있다면 구조 보완이 필요합니다.

---

## 8. Graphify와 OpenCode 연계

Graphify 결과를 OpenCode에 입력하면 더 정확한 점검이 가능합니다.

예시:

```text
@docs-curator Graphify 결과를 기준으로 고립 문서와 인덱스 누락 항목을 정리해줘.
```

또는:

```text
@pl-orchestrator Graphify 결과를 바탕으로 오늘 PL이 먼저 확인해야 할 문서를 정리해줘.
```

이 방식의 장점은 다음입니다.

| 장점 | 설명 |
| --- | --- |
| 맥락 축소 | 전체 문서를 다 읽지 않고도 핵심 연결만 확인 |
| 누락 탐지 | 연결이 끊긴 문서를 쉽게 찾음 |
| 우선순위 정리 | 중심 문서부터 보게 됨 |
| 리뷰 정확도 향상 | OpenCode가 더 좁은 범위로 판단 가능 |

---

## 9. 실습 예시

Graphify 실행 후 다음과 같은 결과를 얻었다고 가정합니다.

```text
중심 문서: 002_PROJECT_DASHBOARD.md
강한 연결: issue_register.md, risk_register.md, decision_log.md, action_items.md
고립 가능 문서: 04_design/mapping/mapping_policy.md
```

이 경우 PL의 조치는 다음과 같습니다.

| 결과 | 조치 |
| --- | --- |
| 중심 문서가 dashboard에 집중 | 정상, 운영 허브로 유지 |
| 관리 문서 연결이 강함 | 정상, 회의→관리 흐름이 유지됨 |
| mapping_policy가 고립됨 | 관련 회의록/이슈/검증 문서 연결 보강 |

즉, 그래프는 단순 시각화가 아니라 문서 품질 점검 도구입니다.

---

## 10. Graphify 결과 반영 방법

그래프 결과를 보고 아래 항목을 수정할 수 있습니다.

```text
001_DOCUMENT_INDEX.md 보강
000_HOME.md 바로가기 추가
회의록에 관련 문서 링크 추가
설계 문서에 회의/검증 링크 추가
고립 문서를 상위 관리 문서와 연결
```

반영 우선순위는 다음과 같습니다.

| 우선순위 | 조치 |
| --- | --- |
| High | 홈/인덱스 누락 보완 |
| High | 회의록과 관리 문서 연결 보강 |
| Medium | 설계/검증 문서 간 링크 보강 |
| Low | 중복 링크 정리 |

---

## 11. OpenCode와 함께 쓰는 방식

Graphify 결과를 본 뒤 OpenCode에 다음처럼 요청할 수 있습니다.

```text
@docs-curator graphify-out/graph_report.md를 기준으로 인덱스에 빠진 문서와 고립 문서를 정리해줘.
```

```text
@pl-orchestrator graphify 결과를 기준으로 PL이 오늘 먼저 봐야 할 문서를 우선순위로 정리해줘.
```

```text
@report-writer graphify 결과를 참고해서 주간보고의 문서 체계 현황을 정리해줘.
```

이렇게 하면 문서 관리가 감이 아니라 구조 기반으로 바뀝니다.

---

## 12. 자주 발생하는 문제

### 12.1 그래프가 너무 복잡함

대응:

```text
제외 폴더를 늘린다.
개인 메모와 첨부파일을 제외한다.
기준 문서만 먼저 그래프로 본다.
```

### 12.2 중요한 문서가 고립됨

대응:

```text
000_HOME.md와 001_DOCUMENT_INDEX.md에 링크를 추가한다.
회의록, 이슈, 리스크, 결정, 액션과 연결한다.
관련 설계/검증 문서에 상호 링크를 추가한다.
```

### 12.3 그래프 결과가 현재 문서와 맞지 않음

대응:

```text
문서 수정 후 다시 그래프를 생성한다.
오래된 archive 문서가 포함되지 않았는지 확인한다.
```

---

## 13. 이번 장 핵심 정리

```text
Graphify는 문서와 구조의 연결 관계를 시각화한다.
중심 문서, 고립 문서, 연결 단절을 확인한다.
data, private_notes, attachments는 제외한다.
graphify-check로 실행 전 점검한다.
Graphify 결과는 OpenCode의 문서 점검 정확도를 높인다.
```

운영 흐름은 다음과 같습니다.

```text
대상 범위 확인
  ↓
/graphify-check
  ↓
Graphify 실행
  ↓
그래프 결과 검토
  ↓
docs-curator / pl-orchestrator에 반영 요청
  ↓
문서 링크 보강
```

다음 장에서는 **9부. code-review-graph 적용: 코드 변경 영향도 분석하기**를 진행합니다.
