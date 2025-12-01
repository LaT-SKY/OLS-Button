#!/usr/bin/env bash

# ============================================================================
# Git 智能管理工具 v2.1 (Linux Bash 版)
# 作者: LaT-SKY（Linux移植版由 ChatGPT 生成）
# 修改日期: 2025-08-04
# ============================================================================

# --- 工具函数 ---

pause() {
    echo
    read -rp "按回车键继续..."
}

check_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo
        echo "[错误] 当前目录不是一个 Git 仓库！"
        echo "请进入一个 Git 仓库目录，或在高级设置中初始化仓库。"
        pause
        return 1
    fi
    return 0
}

check_for_changes() {
    has_changes=0
    git diff --quiet --exit-code || has_changes=1
    git diff --cached --quiet --exit-code || has_changes=1

    # 未跟踪文件
    if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        has_changes=1
    fi
}

# ============================================================================
# 主菜单
# ============================================================================

main_menu() {
    clear
    echo "*******************************************************"
    echo
    echo "                Git 智能工作流向导"
    echo
    echo "*******************************************************"
    echo "  [核心流程]"
    echo
    echo "    1. 存盘并同步改动"
    echo "    2. 获取团队最新代码"
    echo "    3. 开始一个新任务"
    echo
    echo "  [辅助功能]"
    echo
    echo "    4. 查看我的工作进度"
    echo "    5. 实用工具..."
    echo "    6. 高级设定..."
    echo "    7. 退出"
    echo
    echo "*******************************************************"

    read -rp "请选择操作 (1-7): " choice
    case "$choice" in
        1) save_and_sync ;;
        2) get_latest_code ;;
        3) start_new_task ;;
        4) check_progress ;;
        5) utility_menu ;;
        6) advanced_menu ;;
        7) exit 0 ;;
        *) echo "无效输入"; pause ;;
    esac

    main_menu
}

# ============================================================================
# 核心功能
# ============================================================================

save_and_sync() {
    clear
    check_git_repo || return
    echo "******** 存盘并同步改动 ********"
    echo

    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "当前分支: $current_branch"
    echo

    check_for_changes
    if [[ $has_changes -eq 0 ]]; then
        echo "没有检测到新的文件改动。"
        read -rp "仍要尝试 push 本地提交吗? (Y/N): " force
        [[ "$force" =~ ^[Yy]$ ]] || return
        git push origin "$current_branch"
        pause
        return
    fi

    read -rp "请输入本次提交描述: " commit_msg
    if [[ -z "$commit_msg" ]]; then
        echo "[错误] 描述不能为空！"
        pause
        return
    fi

    git add .
    git commit -m "$commit_msg"

    echo
    echo "正在 push 到远程仓库..."
    git push origin "$current_branch"
    if [[ $? -ne 0 ]]; then
        echo "[提示] 推送失败，可能需要设置 upstream"
        read -rp "是否设置 upstream 并重试？(Y/N): " up
        [[ "$up" =~ ^[Yy]$ ]] && git push -u origin "$current_branch"
    fi

    pause
}

get_latest_code() {
    clear
    check_git_repo || return

    echo "******** 获取团队最新代码 ********"
    echo
    read -rp "确认要拉取最新代码吗? (Y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || return

    echo
    echo "拉取 main 分支..."
    git checkout main && git pull origin main || {
        echo "[提示] 尝试 master..."
        git checkout master && git pull origin master || {
            echo "[错误] main/master 均更新失败"
            pause
            return
        }
    }

    echo "更新完成！"
    pause
}

start_new_task() {
    clear
    check_git_repo || return

    echo "******** 开始一个新任务 ********"
    git branch -a
    echo
    read -rp "请输入新任务分支名（或已有分支名）: " branch_name

    [[ -z "$branch_name" ]] && echo "分支名不能为空！" && pause && return

    if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        git checkout "$branch_name"
    else
        git checkout -b "$branch_name"
    fi

    pause
}

check_progress() {
    clear
    check_git_repo || return

    echo "******** 文件状态 ********"
    git status
    echo
    echo "******** 最近提交 ********"
    git log --oneline -10 --graph --decorate

    pause
}

# ============================================================================
# 实用工具菜单
# ============================================================================

utility_menu() {
    clear
    echo "******** 实用工具 ********"
    echo "1. 撤销上一次提交"
    echo "2. 暂存工作进度"
    echo "3. 清理本地已合并分支"
    echo "4. 生成 .gitignore 文件"
    echo "5. 返回"
    echo

    read -rp "请选择 (1-5): " choice
    case "$choice" in
        1) undo_last_commit ;;
        2) stash_menu ;;
        3) clean_local_branches ;;
        4) generate_gitignore_menu ;;
        5) return ;;
    esac

    utility_menu
}


undo_last_commit() {
    check_git_repo || return
    read -rp "确定撤销最后一次提交？(Y/N): " c
    [[ "$c" =~ ^[Yy]$ ]] || return

    git reset --soft HEAD~1
    echo "已撤销最后一次提交"
    pause
}

stash_menu() {
    clear
    echo "******** 暂存工作进度 ********"
    git stash list
    echo "1. 暂存当前改动"
    echo "2. 恢复最近暂存"
    echo "3. 返回"
    read -rp "请选择: " c

    case "$c" in
        1) git stash && echo "已暂存" && pause ;;
        2) git stash pop && echo "已恢复" && pause ;;
        3) return ;;
    esac
}

clean_local_branches() {
    check_git_repo || return

    echo "搜索已合并分支..."
    for br in $(git branch --merged main | grep -v "main"); do
        read -rp "删除已合并分支 $br ? (Y/N): " d
        [[ "$d" =~ ^[Yy]$ ]] && git branch -d "$br"
    done

    pause
}

generate_gitignore_menu() {
    clear
    echo "1. 通用"
    echo "2. C++"
    echo "3. Python"
    echo "4. Node.js"
    echo "5. 返回"
    read -rp "选择模板: " t

    case "$t" in
        1) write_gitignore "general" ;;
        2) write_gitignore "cpp" ;;
        3) write_gitignore "python" ;;
        4) write_gitignore "nodejs" ;;
        5) return ;;
    esac

    echo ".gitignore 生成完成！"
    pause
}

write_gitignore() {
    case "$1" in
        general)
            cat > .gitignore <<EOF
.DS_Store
*.log
*.tmp
EOF
            ;;
        cpp)
            cat > .gitignore <<EOF
.vs/
Debug/
Release/
*.obj
*.exe
*.dll
EOF
            ;;
        python)
            cat > .gitignore <<EOF
__pycache__/
*.pyc
env/
venv/
EOF
            ;;
        nodejs)
            cat > .gitignore <<EOF
node_modules/
dist/
build/
EOF
            ;;
    esac
}

# ============================================================================
# 高级设置菜单
# ============================================================================

advanced_menu() {
    clear
    echo "******** 高级设定 ********"
    echo "1. 创建标签"
    echo "2. 合并分支"
    echo "3. 删除分支"
    echo "4. 远程管理"
    echo "5. 初始化仓库"
    echo "6. 配置用户信息"
    echo "7. 返回"
    read -rp "请选择: " c

    case "$c" in
        1) create_tag ;;
        2) merge_branch ;;
        3) delete_branch ;;
        4) remote_menu ;;
        5) init_repo ;;
        6) config_user ;;
        7) return ;;
    esac

    advanced_menu
}

create_tag() {
    check_git_repo || return
    read -rp "标签名: " tag
    read -rp "附注信息（可空）: " msg

    if [[ -n "$msg" ]]; then
        git tag -a "$tag" -m "$msg"
    else
        git tag "$tag"
    fi

    read -rp "推送到远程？(Y/N): " p
    [[ "$p" =~ ^[Yy]$ ]] && git push origin "$tag"

    pause
}

merge_branch() {
    check_git_repo || return
    current=$(git rev-parse --abbrev-ref HEAD)
    echo "当前分支: $current"

    read -rp "输入需要合并到当前分支的分支名: " src
    git merge "$src"
    pause
}

delete_branch() {
    check_git_repo || return
    git branch -a
    read -rp "要删除的分支: " d
    git branch -d "$d" || echo "删除失败，可用 -D 强制删除"
    pause
}

remote_menu() {
    clear
    echo "******** 远程仓库管理 ********"
    echo "1. 查看"
    echo "2. 添加"
    echo "3. 修改URL"
    echo "4. 返回"
    read -rp "选择: " c

    case "$c" in
        1) git remote -v; pause ;;
        2)
            read -rp "名称: " n
            read -rp "URL: " u
            git remote add "$n" "$u"
            pause
            ;;
        3)
            git remote -v
            read -rp "要修改的名称: " n
            read -rp "新 URL: " u
            git remote set-url "$n" "$u"
            pause
            ;;
        4) return ;;
    esac
}

init_repo() {
    if [[ -d ".git" ]]; then
        echo "当前目录已是仓库"
    else
        git init
        echo "仓库已初始化"
    fi
    pause
}

config_user() {
    git config user.name
    git config user.email
    read -rp "新用户名（空则跳过）: " u
    [[ -n "$u" ]] && git config --global user.name "$u"
    read -rp "新邮箱（空则跳过）: " e
    [[ -n "$e" ]] && git config --global user.email "$e"
    pause
}

# ============================================================================
# 主入口
# ============================================================================
main_menu

