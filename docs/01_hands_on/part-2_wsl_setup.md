# 2부. WSL 환경에서 프로젝트 생성 및 압축 해제하기

이번 장에서는 팀원이 실제 PC에서 테스트할 수 있도록 WSL 기준 작업 공간을 만들고, 템플릿 압축 파일을 해제한 뒤 VSCode로 여는 과정을 진행합니다.

---

## 1. 이번 장의 목표

이번 장을 완료하면 아래 상태가 됩니다.

```text
WSL 내부에 프로젝트 폴더 생성
        ↓
템플릿 압축 파일 해제
        ↓
Git 초기화
        ↓
VSCode WSL Remote로 프로젝트 열기
        ↓
기본 폴더 구조 확인
```

최종 위치는 아래처럼 가정합니다.

```bash
~/workspace/gsr-migration-ai-pl
```

---

## 2. WSL에서 프로젝트를 관리하는 이유

Windows + WSL 환경에서는 프로젝트를 어디에 두는지가 중요합니다.

추천 위치는 WSL 내부입니다.

```bash
/home/<wsl-user>/workspace/gsr-migration-ai-pl
```

즉, 아래처럼 작업하는 것을 추천합니다.

```bash
~/workspace/gsr-migration-ai-pl
```

비추천 위치는 Windows 파일시스템입니다.

```bash
/mnt/c/Users/<WindowsUser>/Documents/gsr-migration-ai-pl
```

이 위치도 사용할 수는 있지만, WSL에서 Git, shell, Python, dbt, 검색 명령을 자주 사용할 경우 성능이 떨어질 수 있습니다.

| 위치         | 예시                    | 추천도 | 이유                   |
| ---------- | --------------------- | --: | -------------------- |
| WSL 내부     | `~/workspace/project` |  높음 | Linux 도구 사용 성능이 좋음   |
| Windows 폴더 | `/mnt/c/Users/...`    |  낮음 | WSL에서 파일 접근이 느릴 수 있음 |

---

## 3. 사전 준비 확인

WSL 터미널에서 아래 명령을 실행합니다.

```bash
pwd
```

현재 위치가 아래처럼 나오면 WSL 내부입니다.

```bash
/home/<wsl-user>
```

아래처럼 나오면 Windows 파일시스템입니다.

```bash
/mnt/c/Users/<WindowsUser>
```

이번 실습은 WSL 내부에서 진행합니다.

---

## 4. 작업 공간 만들기

WSL 터미널에서 실행합니다.

```bash
mkdir -p ~/workspace
cd ~/workspace
```

현재 위치를 확인합니다.

```bash
pwd
```

예상 결과:

```bash
/home/<wsl-user>/workspace
```

---

## 5. 템플릿 압축 파일 준비

앞서 받은 템플릿 파일 이름은 다음과 같습니다.

```text
gsr-migration-ai-pl-template.zip
```

보통 Windows 다운로드 폴더에 있을 가능성이 높습니다.

Windows 다운로드 폴더는 WSL에서 대개 아래 경로로 접근합니다.

```bash
/mnt/c/Users/<WindowsUser>/Downloads/
```

예를 들어 Windows 사용자명이 `dharma6872`라면 다음과 같습니다.

```bash
/mnt/c/Users/dharma6872/Downloads/
```

파일이 있는지 확인합니다.

```bash
ls /mnt/c/Users/<WindowsUser>/Downloads/gsr-migration-ai-pl-template.zip
```

실제 사용자명으로 바꾸어 실행합니다.

예시:

```bash
ls /mnt/c/Users/dharma6872/Downloads/gsr-migration-ai-pl-template.zip
```

---

## 6. 압축 해제하기

`~/workspace` 위치에서 압축을 풉니다.

```bash
cd ~/workspace
unzip /mnt/c/Users/<WindowsUser>/Downloads/gsr-migration-ai-pl-template.zip
```

예시:

```bash
cd ~/workspace
unzip /mnt/c/Users/dharma6872/Downloads/gsr-migration-ai-pl-template.zip
```

압축을 풀면 아래 폴더가 생깁니다.

```text
gsr-migration-ai-pl-template/
```

실제 프로젝트명으로 바꾸고 싶다면 폴더명을 변경합니다.

```bash
mv gsr-migration-ai-pl-template gsr-migration-ai-pl
cd gsr-migration-ai-pl
```

현재 위치를 확인합니다.

```bash
pwd
```

예상 결과:

```bash
/home/<wsl-user>/workspace/gsr-migration-ai-pl
```

---

## 7. 폴더 구조 확인

프로젝트 루트에서 아래 명령을 실행합니다.

```bash
ls -la
```

다음과 유사한 구조가 보여야 합니다.

```text
README.md
AGENTS.md
opencode.jsonc
docs
data
scripts
dbt_project
.opencode
.vscode
.code-review-graphignore
.gitattributes
.gitignore
```

조금 더 보기 좋게 확인하려면 `tree` 명령을 사용할 수 있습니다.

```bash
sudo apt update
sudo apt install -y tree
tree -L 2
```

예상 결과:

```text
.
├── AGENTS.md
├── README.md
├── data
├── dbt_project
├── docs
├── opencode.jsonc
├── scripts
└── .opencode
```

---

## 8. WSL 초기 설정 스크립트 실행

템플릿에는 WSL 환경에서 기본 확인을 돕는 스크립트가 있다고 가정합니다.

```bash
./scripts/shell/bootstrap_wsl.sh
```

실행 권한이 없다는 메시지가 나오면 아래 명령을 먼저 실행합니다.

```bash
chmod +x ./scripts/shell/*.sh
./scripts/shell/bootstrap_wsl.sh
```

이 스크립트에서 확인할 항목은 다음입니다.

| 확인 항목 | 설명 |
| --- | --- |
| 현재 경로 | 프로젝트가 WSL 내부에 있는지 확인 |
| Git 설치 여부 | Git 사용 가능 여부 확인 |
| VSCode CLI | `code .` 명령 사용 가능 여부 확인 |
| 줄바꿈 설정 | Git `core.autocrlf`, `core.eol` 확인 |
| 기본 폴더 존재 | `docs`, `.opencode`, `.vscode` 확인 |

스크립트가 없거나 실행이 안 되면 수동으로 아래 명령을 실행해도 됩니다.

```bash
git --version
code --version
pwd
ls docs
ls .opencode
```

---

## 9. Git 초기화하기

프로젝트 루트에서 실행합니다.

```bash
git init
git status
```

처음 전체 파일을 추가합니다.

```bash
git add .
git commit -m "Initial PL documentation workspace"
```

만약 Git 사용자 정보가 설정되어 있지 않다는 메시지가 나오면 아래처럼 설정합니다.

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

다시 커밋합니다.

```bash
git add .
git commit -m "Initial PL documentation workspace"
```

---

## 10. WSL Git 줄바꿈 설정

Windows와 WSL을 함께 쓰면 줄바꿈 문제가 발생할 수 있습니다.

WSL에서는 아래 설정을 추천합니다.

```bash
git config --global core.autocrlf input
git config --global core.eol lf
```

현재 설정 확인:

```bash
git config --global --get core.autocrlf
git config --global --get core.eol
```

예상 결과:

```text
input
lf
```

프로젝트에는 `.gitattributes`를 두어 Markdown, SQL, Shell, Python 파일의 줄바꿈을 안정적으로 관리합니다.

예시:

```gitattributes
* text=auto

*.md text eol=lf
*.sql text eol=lf
*.sh text eol=lf
*.py text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.json text eol=lf
*.csv text eol=lf
```

---

## 11. VSCode로 프로젝트 열기

프로젝트 루트에서 실행합니다.

```bash
code .
```

VSCode가 열리면 왼쪽 아래 상태 표시줄을 확인합니다.

정상이라면 다음과 비슷하게 표시됩니다.

```text
WSL: Ubuntu
```

이 표시가 중요합니다.

| 표시 | 의미 |
| --- | --- |
| `WSL: Ubuntu` | WSL Remote로 정상 접속 |
| 표시 없음 | Windows 로컬 폴더로 열린 것일 수 있음 |
| `Dev Container` | 컨테이너 환경으로 열린 상태 |

이번 실습에서는 `WSL: Ubuntu` 상태를 기준으로 진행합니다.

---

## 12. VSCode에서 확인할 폴더

VSCode Explorer에서 아래 항목을 확인합니다.

```text
docs/
.opencode/
.vscode/
scripts/
data/
dbt_project/
```

먼저 열어볼 파일은 다음입니다.

```text
README.md
AGENTS.md
docs/000_HOME.md
docs/002_PROJECT_DASHBOARD.md
opencode.jsonc
```

---

## 13. Windows 탐색기에서 WSL 프로젝트 위치 확인하기

Windows 탐색기에서도 WSL 파일을 볼 수 있습니다.

WSL 터미널에서 아래 명령을 실행합니다.

```bash
explorer.exe .
```

그러면 Windows 탐색기가 현재 WSL 프로젝트 폴더를 엽니다.

경로는 대략 아래와 같은 형태입니다.

```text
\\wsl.localhost\Ubuntu\home\<wsl-user>\workspace\gsr-migration-ai-pl
```

이 경로는 다음 장에서 Obsidian Vault를 열 때 사용합니다.

---

## 14. Obsidian Vault 경로 미리 확인

Obsidian은 프로젝트 전체가 아니라 `docs` 폴더만 열 예정입니다.

WSL에서 `docs`의 Windows 경로를 확인합니다.

```bash
wslpath -w docs
```

예상 결과:

```text
\\wsl.localhost\Ubuntu\home\<wsl-user>\workspace\gsr-migration-ai-pl\docs
```

이 경로를 복사해둡니다.

다음 장에서 Obsidian에서 이 폴더를 Vault로 열 것입니다.

---

## 15. 이번 장 실습 결과 확인

이번 장이 끝나면 아래 상태여야 합니다.

| 항목 | 확인 방법 | 기대 결과 |
| --- | --- | --- |
| 프로젝트 위치 | `pwd` | `/home/<user>/workspace/gsr-migration-ai-pl` |
| 폴더 구조 | `ls -la` | `docs`, `.opencode`, `.vscode` 존재 |
| Git 초기화 | `git status` | Git repository 상태 표시 |
| 첫 커밋 | `git log --oneline` | 초기 커밋 1개 이상 |
| VSCode 연결 | VSCode 좌하단 | `WSL: Ubuntu` 표시 |
| Obsidian 경로 | `wslpath -w docs` | `\\wsl...docs` 경로 출력 |

---

## 16. 자주 발생하는 문제

### 16.1 `unzip: command not found`

`unzip`이 설치되어 있지 않은 경우입니다.

```bash
sudo apt update
sudo apt install -y unzip
```

다시 실행합니다.

```bash
unzip /mnt/c/Users/<WindowsUser>/Downloads/gsr-migration-ai-pl-template.zip
```

### 16.2 `code: command not found`

VSCode의 WSL CLI가 연결되지 않은 경우입니다.

해결 방법:

1. Windows에서 VSCode 실행
2. 확장 메뉴에서 `WSL` 또는 `Remote Development` 설치
3. WSL 터미널을 새로 열기
4. 다시 실행

```bash
code .
```

### 16.3 VSCode가 Windows 폴더로 열린다

VSCode 좌하단에 `WSL: Ubuntu`가 보이지 않으면 WSL Remote로 열린 것이 아닐 수 있습니다.

해결 방법:

WSL 터미널에서 프로젝트 폴더로 이동한 뒤 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
code .
```

### 16.4 Git 커밋 시 사용자 정보 오류

오류 예시:

```text
Author identity unknown
```

해결:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

다시 커밋합니다.

```bash
git add .
git commit -m "Initial PL documentation workspace"
```

### 16.5 Windows 다운로드 경로를 모르겠음

Windows 사용자명을 확인하기 어렵다면 WSL에서 아래를 실행해볼 수 있습니다.

```bash
ls /mnt/c/Users
```

출력된 사용자 폴더 중 본인 계정을 확인한 뒤 Downloads 경로를 찾습니다.

```bash
ls /mnt/c/Users/<WindowsUser>/Downloads
```

---

## 17. 이번 장 핵심 정리

이번 장에서 가장 중요한 원칙은 다음입니다.

```text
프로젝트는 WSL 내부에 둔다.
VSCode는 WSL Remote로 프로젝트 루트를 연다.
Git은 WSL Git을 기준으로 사용한다.
Obsidian은 다음 장에서 docs 폴더만 Vault로 연다.
```

여기까지 완료되면 기본 작업 공간은 준비된 상태입니다.

다음 장에서는 **3부. VSCode 확장 설치 및 문서관리 설정하기**를 진행합니다.
