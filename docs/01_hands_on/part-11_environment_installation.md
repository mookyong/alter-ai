# 11부. 개발 환경 설치 및 초기 설정

이 문서는 WSL 기반 개발 환경을 빠르게 구성하기 위한 설치 절차를 정리한 문서입니다.

---

## 1. WSL 설치

```bash
wsl --list
wsl -l -o
wsl --install -d Ubuntu-26.04
wsl -d Ubuntu-26.04
```

최신 버전으로 우분투를 설치해서 사용합니다. 현재 테스트 환경에서 별다른 이슈사항은 발견하지 못했습니다.


### 기본 패키지 및 로케일 설정

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install language-pack-ko -y
sudo locale-gen ko_KR.UTF-8
```

---

## 2. Miniconda 설치

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

source ~/.bashrc
conda --version
```

---

## 3. Docker 설치

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

sudo usermod -aG docker $USER

docker compose version
```

---

## 4. Node.js 설치

```bash
sudo apt update
sudo apt install -y nodejs npm
node -v
npm -v

sudo npm install -g opencode-ai
opencode --version
```

---

## 5. VSCode 확장

- WSL
- Gray Matter
- Excalidraw
- vscode-dbt
- Todo Tree
- sqlfluff
- SQL Notebook
- Python
- Prettier - Code formatter
- Power User for dbt
- Markmap
- Markdown Preview Mermaid Support
- Markdown PDF
- Markdown Notes
- Markdown All in One
- GitLens - Git supercharged
- Front Matter CMS
- Foam
- Excel Viewer
- DuckDB
- dbt formatter
- vscode-pdf

---

## 6. Markdown to PDF

```bash
wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt update
sudo apt install -y /tmp/google-chrome.deb
which google-chrome

sudo apt install -y fonts-noto-cjk fonts-noto-color-emoji
```

VSCode에서 `Ctrl + Shift + P`를 누르고 `Preferences: Open Remote Settings (JSON)`을 연 뒤 아래 설정을 추가합니다.

```json
{
  "markdown-pdf.executablePath": "/usr/bin/google-chrome",
  "markdown-pdf.chromium.autoDownload": false
}
```

---

## 7. 기타 도구

- 알PDF
- Obsidian

---

## 8. WSL 내보내기와 가져오기

```bash
wsl -l -v
wsl --terminate Ubuntu-26.04
wsl --shutdown
wsl --export Ubuntu-26.04 Ubuntu-26.04.tar

wsl --import [새이름] [설치할경로] [백업파일경로]
wsl --import dbt-ai-core-20260527 ./dbt-ai-core-20260527 Ubuntu-26.04.tar

wsl -d dbt-ai-core-20260527
```

---

## 9. WSL 삭제

```bash
wsl --unregister Ubuntu-26.04
```

---

## 10. VSCode 시작하기

```bash
code .
```

---

## 11. 프로젝트 폴더 Git 연동 설정

```bash
git init
git config --global core.autocrlf true
git config user.name mookyongkim
git config user.email mookyongkim@gmail.com
git remote add origin https://github.com/mookyong/alter-ai.git
git checkout -b wsl-vscode-obsidian-opencode-graphify-pl
```

---

## 12. Linux Obsidian 설치

```bash
sudo apt update
sudo apt install -y x11-apps
xeyes

sudo apt update
sudo apt install -y ./obsidian*.deb
which obsidian
obsidian --version
obsidian
```

---

## 13. docs 폴더만 Git 연동하는 방법

Windows Git을 설치한 뒤 브랜치를 체크아웃합니다.

```bash
git clone -b wsl-vscode-obsidian-opencode-graphify-pl --single-branch https://github.com/mookyong/alter-ai.git
cd alter-ai
git sparse-checkout disable
git sparse-checkout init --no-cone
git sparse-checkout set /docs/
```

---

## 14. Obsidian Git 설정

1. Obsidian Settings > Community plugins > Obsidian Git 설치
2. Enabled 켜기

### Obsidian Git 연동 절차

1. https://hyundoil.tistory.com/464 참조
2. Stage -> Commit -> Push

```bash
cd alter-ai
git config user.name "mookyongkim"
git config user.email "mookyongkim@gmail.com"
```

GitHub 연동 인증 절차가 필요합니다.
